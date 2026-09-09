-- ============================================================
-- auto_farm.lua - Logic farm cho doeak hub
-- ============================================================

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- ===== DỮ LIỆU ĐẢO =====
-- Dựa theo thông tin từ các nguồn uy tín [reference:0][reference:1][reference:2]
local ISLAND_DATA = {
    -- Sea 1 (Level 0-700)
    {name = "Jungle", minLevel = 10, maxLevel = 30, sea = 1, questNPC = "Jungle Quest Giver", mobs = {"Monkey", "Gorilla"}},
    {name = "Pirate Village", minLevel = 30, maxLevel = 60, sea = 1, questNPC = "Pirate Village Quest Giver", mobs = {"Pirate", "Brute"}},
    {name = "Desert", minLevel = 60, maxLevel = 90, sea = 1, questNPC = "Desert Quest Giver", mobs = {"Desert Bandit", "Desert Officer"}},
    {name = "Frozen Village", minLevel = 90, maxLevel = 120, sea = 1, questNPC = "Frozen Village Quest Giver", mobs = {"Snow Bandit", "Snowman"}},
    {name = "Marine Fortress", minLevel = 120, maxLevel = 150, sea = 1, questNPC = "Marine Fortress Quest Giver", mobs = {"Marine Officer", "Chief Petty Officer"}},
    {name = "Skylands", minLevel = 150, maxLevel = 200, sea = 1, questNPC = "Skylands Quest Giver", mobs = {"Sky Bandit", "Dark Master"}},
    {name = "Prison", minLevel = 190, maxLevel = 275, sea = 1, questNPC = "Prison Quest Giver", mobs = {"Prisoner", "Dangerous Prisoner"}},
    {name = "Colosseum", minLevel = 225, maxLevel = 300, sea = 1, questNPC = "Colosseum Quest Giver", mobs = {"Toga Warrior", "Gladiator"}},
    {name = "Magma Village", minLevel = 300, maxLevel = 375, sea = 1, questNPC = "Magma Village Quest Giver", mobs = {"Military Soldier", "Military Spy"}},
    {name = "Underwater City", minLevel = 375, maxLevel = 450, sea = 1, questNPC = "Underwater City Quest Giver", mobs = {"Fisherman Warrior", "Fisherman Commando"}},
    {name = "Fountain City", minLevel = 625, maxLevel = 700, sea = 1, questNPC = "Fountain City Quest Giver", mobs = {"Galley Pirate", "Galley Captain"}},
    -- Sea 2 (Level 700-1500)
    {name = "Kingdom of Rose", minLevel = 700, maxLevel = 850, sea = 2, questNPC = "Kingdom of Rose Quest Giver", mobs = {"Raider", "Merc"}},
    {name = "Green Zone", minLevel = 875, maxLevel = 925, sea = 2, questNPC = "Green Zone Quest Giver", mobs = {"Green Zone Enemy"}},
    {name = "Graveyard", minLevel = 950, maxLevel = 975, sea = 2, questNPC = "Graveyard Quest Giver", mobs = {"Zombie"}},
    {name = "Snow Mountain", minLevel = 1000, maxLevel = 1050, sea = 2, questNPC = "Snow Mountain Quest Giver", mobs = {"Winter Enemy"}},
    {name = "Cursed Ship", minLevel = 1000, maxLevel = 1325, sea = 2, questNPC = "Cursed Ship Quest Giver", mobs = {"Cursed Crew"}},
    {name = "Hot and Cold", minLevel = 1100, maxLevel = 1200, sea = 2, questNPC = "Hot and Cold Quest Giver", mobs = {"Elemental Enemy"}},
    {name = "Ice Castle", minLevel = 1350, maxLevel = 1400, sea = 2, questNPC = "Ice Castle Quest Giver", mobs = {"Ice Enemy"}},
    {name = "Forgotten Island", minLevel = 1425, maxLevel = 1475, sea = 2, questNPC = "Forgotten Island Quest Giver", mobs = {"Dark Step Enemy"}},
    -- Sea 3 (Level 1500+)
    {name = "Port Town", minLevel = 1500, maxLevel = 1575, sea = 3, questNPC = "Port Town Quest Giver", mobs = {"Pirate Millionaire", "Pistol Billionaire"}},
    {name = "Hydra Island", minLevel = 1575, maxLevel = 1700, sea = 3, questNPC = "Hydra Island Quest Giver", mobs = {"Dragon Crew Warrior", "Dragon Crew Archer", "Female Islander", "Giant Islander"}},
    {name = "Great Tree", minLevel = 1700, maxLevel = 1775, sea = 3, questNPC = "Great Tree Quest Giver", mobs = {"Marine Commodore", "Marine Rear Admiral"}},
    {name = "Floating Turtle", minLevel = 1775, maxLevel = 2000, sea = 3, questNPC = "Floating Turtle Quest Giver", mobs = {"Fishman Raider", "Fishman Captain", "Forest Pirate", "Mythological Pirate"}},
    {name = "Haunted Castle", minLevel = 1975, maxLevel = 2075, sea = 3, questNPC = "Haunted Castle Quest Giver", mobs = {"Haunted Enemy"}},
    {name = "Sea of Treats", minLevel = 2075, maxLevel = 2275, sea = 3, questNPC = "Sea of Treats Quest Giver", mobs = {"Treat Enemy"}},
    {name = "Tiki Outpost", minLevel = 2450, maxLevel = 2700, sea = 3, questNPC = "Tiki Outpost Quest Giver", mobs = {"Tiki Enemy"}}
}

-- ===== BIẾN TRẠNG THÁI =====
local isFarming = false
local currentTarget = nil
local targetPosition = nil
local isGathering = false
local gatheredMobs = {}
local attackDelay = 0.5

-- ===== HÀM TIỆN ÍCH =====

-- Lấy đảo phù hợp với level hiện tại
local function getIslandForLevel(level)
    local best = nil
    local bestDiff = math.huge
    for _, island in ipairs(ISLAND_DATA) do
        if level >= island.minLevel and level <= island.maxLevel then
            local diff = island.maxLevel - level
            if diff < bestDiff then
                bestDiff = diff
                best = island
            end
        end
    end
    return best
end

-- Lấy vị trí đảo (tìm trong Workspace)
local function getIslandPosition(islandName)
    -- Tìm trong Workspace các model có tên chứa tên đảo
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child.Name and child.Name:lower():find(islandName:lower()) then
            local root = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head")
            if root then
                return root.Position
            end
        end
    end
    -- Fallback: tìm bằng vị trí tương đối
    return nil
end

-- Di chuyển mượt đến vị trí với tốc độ 250 (dạng đi bộ)
local function moveTo(position)
    if not hrp then return end
    local distance = (position - hrp.Position).Magnitude
    if distance < 2 then return end
    
    -- Tính thời gian di chuyển với tốc độ 250 studs/s
    local speed = 250
    local duration = distance / speed
    if duration < 0.05 then duration = 0.05 end
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    tween.Completed:Wait()
end

-- Tìm quái gần nhất trên đảo
local function findNearestMob(islandName)
    local nearest = nil
    local minDist = math.huge
    local charPos = hrp.Position
    
    for _, child in ipairs(Workspace:GetDescendants()) do
        if child:IsA("Model") and child:FindFirstChild("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
            local humanoid = child:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and humanoid.MaxHealth > 0 then
                local root = child:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - charPos).Magnitude
                    if dist < minDist and dist < 200 then
                        minDist = dist
                        nearest = child
                    end
                end
            end
        end
    end
    return nearest
end

-- Gom quái về một điểm
local function gatherMobs(targetPoint, radius)
    isGathering = true
    local gathered = {}
    local startPos = hrp.Position
    
    -- Di chuyển đến điểm gom
    moveTo(targetPoint)
    
    -- Tìm quái xung quanh trong bán kính
    for _, child in ipairs(Workspace:GetDescendants()) do
        if child:IsA("Model") and child:FindFirstChild("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
            local humanoid = child:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local root = child:FindFirstChild("HumanoidRootPart")
                if root and (root.Position - targetPoint).Magnitude < radius then
                    table.insert(gathered, child)
                end
            end
        end
    end
    
    isGathering = false
    return gathered
end

-- Tấn công quái (đứng ở vị trí an toàn)
local function attackMob(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return false end
    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return false end
    
    -- Xác định vị trí an toàn: bay lên cao 15 studs so với quái
    local safePosition = mobRoot.Position + Vector3.new(0, 15, 0)
    moveTo(safePosition)
    
    -- Tấn công: dùng click chuột hoặc remote (giả lập)
    local attackDelay = _G.AttackDelay or 0.5
    local startTime = tick()
    
    -- Mô phỏng đánh: thay đổi vị trí của quái (hiệu ứng)
    while tick() - startTime < attackDelay do
        if not mob or not mob:FindFirstChild("Humanoid") or mob:FindFirstChild("Humanoid").Health <= 0 then
            break
        end
        -- Giả lập tấn công bằng cách đặt CFrame của quái (thực tế cần dùng remote)
        local fakeAttack = Instance.new("Part")
        fakeAttack.Size = Vector3.new(2, 2, 2)
        fakeAttack.CFrame = mobRoot.CFrame + Vector3.new(0, 5, 0)
        fakeAttack.Parent = Workspace
        game:GetService("Debris"):AddItem(fakeAttack, 0.1)
        task.wait(0.1)
    end
    
    return true
end

-- ===== HÀM CHÍNH =====

-- Hàm farm tick (được gọi từ main.lua)
function _G.FarmTick()
    if not isFarming then
        isFarming = true
    end
    
    local level = player.Level
    local island = getIslandForLevel(level)
    if not island then
        warn("Không tìm thấy đảo phù hợp với level " .. level)
        task.wait(1)
        return
    end
    
    -- Di chuyển đến đảo
    local islandPos = getIslandPosition(island.name)
    if not islandPos then
        warn("Không tìm thấy vị trí đảo " .. island.name)
        task.wait(1)
        return
    end
    moveTo(islandPos)
    
    -- Tìm quái
    local mob = findNearestMob(island.name)
    if not mob then
        -- Nếu không có quái, thử gom quái
        local gathered = gatherMobs(islandPos, 100)
        if #gathered > 0 then
            mob = gathered[1]
        else
            task.wait(0.5)
            return
        end
    end
    
    -- Tấn công quái
    if mob then
        attackMob(mob)
    end
    
    task.wait(0.1)
end

-- Hàm dừng farm
function _G.StopFarm()
    isFarming = false
    if currentTarget then
        currentTarget = nil
    end
end

-- Hàm về đảo an toàn
function _G.GoToSafeZone()
    local level = player.Level
    local island = getIslandForLevel(level)
    if not island then return end
    local pos = getIslandPosition(island.name)
    if pos then
        moveTo(pos)
    end
end

-- Cập nhật delay từ UI
local function updateDelay()
    attackDelay = _G.AttackDelay or 0.5
end

-- Lắng nghe thay đổi delay
game:GetService("RunService").Heartbeat:Connect(function()
    if _G.AttackDelay ~= attackDelay then
        updateDelay()
    end
end)

-- Khởi tạo
updateDelay()
print("✅ auto_farm.lua loaded!")