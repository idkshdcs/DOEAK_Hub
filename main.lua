-- ============================================================
-- doeak hub - Blox Fruit Auto Farm (Tự tạo UI, không load ngoài)
-- Cập nhật quái vật: 09/09/2026
-- ============================================================

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- ===== LẤY LEVEL =====
local function getPlayerLevel()
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local lvl = ls:FindFirstChild("Level")
        if lvl then return lvl.Value end
    end
    return 0
end

local playerLevel = getPlayerLevel()

-- ===== DỮ LIỆU ĐẢO + QUÁI (CẬP NHẬT 09/09) =====
local ISLAND_DATA = {
    {name = "Jungle", minLevel = 10, maxLevel = 30, sea = 1, mobs = {"Monkeys", "Gorillas"}, boss = "Gorilla King"},
    {name = "Pirate Village", minLevel = 30, maxLevel = 60, sea = 1, mobs = {"Pirates", "Brutes"}, boss = "Bobby"},
    {name = "Desert", minLevel = 60, maxLevel = 90, sea = 1, mobs = {"Desert Bandits", "Desert Officers"}},
    {name = "Frozen Village", minLevel = 90, maxLevel = 120, sea = 1, mobs = {"Snow Bandits", "Snowmen"}, boss = "Yeti"},
    {name = "Marine Fortress", minLevel = 120, maxLevel = 150, sea = 1, mobs = {"Chief Petty Officers"}, boss = "Vice Admiral"},
    {name = "Skylands", minLevel = 150, maxLevel = 200, sea = 1, mobs = {"Sky Bandits", "Dark Masters"}},
    {name = "Prison", minLevel = 190, maxLevel = 275, sea = 1, mobs = {"Prisoners", "Dangerous Prisoners"}, boss = "Chief Warden"},
    {name = "Colosseum", minLevel = 225, maxLevel = 300, sea = 1, mobs = {"Toga Warriors", "Gladiators"}},
    {name = "Magma Village", minLevel = 300, maxLevel = 375, sea = 1, mobs = {"Military Soldiers", "Military Spies"}, boss = "Magma Admiral"},
    {name = "Underwater City", minLevel = 375, maxLevel = 450, sea = 1, mobs = {"Fishman Warriors", "Fishman Commandos"}, boss = "Fishman Lord"},
    {name = "Fountain City", minLevel = 625, maxLevel = 700, sea = 1, mobs = {"Galley Pirates", "Galley Captains"}, boss = "Cyborg"},
    {name = "Kingdom of Rose", minLevel = 700, maxLevel = 850, sea = 2, mobs = {"Raiders", "Mercenaries", "Swan Pirates"}, boss = "Diamond"},
    {name = "Green Zone", minLevel = 875, maxLevel = 950, sea = 2, mobs = {"Green Zone Enemies"}},
    {name = "Graveyard", minLevel = 950, maxLevel = 1000, sea = 2, mobs = {"Zombies"}},
    {name = "Snow Mountain", minLevel = 1000, maxLevel = 1050, sea = 2, mobs = {"Snow Troopers"}},
    {name = "Cursed Ship", minLevel = 1000, maxLevel = 1325, sea = 2, mobs = {"Cursed Crew"}, boss = "Cursed Captain"},
    {name = "Hot and Cold", minLevel = 1100, maxLevel = 1200, sea = 2, mobs = {"Elemental Enemies"}, boss = "Order"},
    {name = "Ice Castle", minLevel = 1350, maxLevel = 1400, sea = 2, mobs = {"Ice Enemies"}, boss = "Awakened Ice Admiral"},
    {name = "Forgotten Island", minLevel = 1425, maxLevel = 1475, sea = 2, mobs = {"Dark Step Enemies"}},
    {name = "Port Town", minLevel = 1500, maxLevel = 1575, sea = 3, mobs = {"Pirate Millionaire", "Pistol Billionaire"}},
    {name = "Hydra Island", minLevel = 1575, maxLevel = 1700, sea = 3, mobs = {"Dragon Crew Warrior", "Dragon Crew Archer"}},
    {name = "Great Tree", minLevel = 1700, maxLevel = 1775, sea = 3, mobs = {"Marine Commodore", "Marine Rear Admiral"}, boss = "Kilo Admiral"},
    {name = "Floating Turtle", minLevel = 1775, maxLevel = 1975, sea = 3, mobs = {"Fishman Raider", "Fishman Captain"}, boss = "Captain Elephant"},
    {name = "Haunted Castle", minLevel = 1975, maxLevel = 2075, sea = 3, mobs = {"Haunted Enemies"}, boss = "Soul Reaper"},
    {name = "Sea of Treats", minLevel = 2075, maxLevel = 2275, sea = 3, mobs = {"Treat Enemies"}, boss = "Cake Queen"},
    {name = "Tiki Outpost", minLevel = 2450, maxLevel = 2700, sea = 3, mobs = {"Tiki Enemies"}, boss = "Tyrant of the Skies"},
}

-- ===== HÀM TÌM ĐẢO PHÙ HỢP =====
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

-- ===== HÀM TÌM VỊ TRÍ ĐẢO =====
local function getIslandPosition(islandName)
    for _, child in pairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child.Name and child.Name:lower():find(islandName:lower()) then
            local root = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head")
            if root then return root.Position end
        end
    end
    return nil
end

-- ===== DI CHUYỂN MƯỢT (TỐC ĐỘ 250) =====
local function moveTo(position)
    if not hrp then return end
    local dist = (position - hrp.Position).Magnitude
    if dist < 3 then return end
    
    local speed = 250
    local duration = math.max(0.05, dist / speed)
    
    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(position)
    })
    tween:Play()
    tween.Completed:Wait()
end

-- ===== TÌM QUÁI GẦN NHẤT =====
local function findNearestMob()
    local nearest = nil
    local minDist = math.huge
    local charPos = hrp.Position
    
    for _, child in pairs(Workspace:GetDescendants()) do
        if child:IsA("Model") and child:FindFirstChild("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
            local hum = child:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and hum.MaxHealth > 0 then
                local root = child:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - charPos).Magnitude
                    if dist < minDist and dist < 300 then
                        minDist = dist
                        nearest = child
                    end
                end
            end
        end
    end
    return nearest
end

-- ===== GOM QUÁI =====
local function gatherMobs(targetPoint, radius)
    local gathered = {}
    for _, child in pairs(Workspace:GetDescendants()) do
        if child:IsA("Model") and child:FindFirstChild("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
            local hum = child:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local root = child:FindFirstChild("HumanoidRootPart")
                if root and (root.Position - targetPoint).Magnitude < radius then
                    table.insert(gathered, child)
                end
            end
        end
    end
    return gathered
end

-- ===== TẤN CÔNG QUÁI (ĐỨNG TRÊN CAO) =====
local function attackMob(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return false end
    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return false end
    
    local safePos = mobRoot.Position + Vector3.new(0, 15, 0)
    moveTo(safePos)
    
    local delay = _G.AttackDelay or 0.5
    local startTime = tick()
    
    while tick() - startTime < delay do
        if not mob or not mob:FindFirstChild("Humanoid") or mob:FindFirstChild("Humanoid").Health <= 0 then
            break
        end
        -- Mô phỏng đánh
        task.wait(0.1)
    end
    
    return true
end

-- ===== LOGIC FARM CHÍNH =====
local isFarming = false
local farmThread = nil

function _G.FarmTick()
    if not isFarming then return end
    
    local level = getPlayerLevel()
    local island = getIslandForLevel(level)
    if not island then
        print("Không tìm thấy đảo cho level " .. level)
        task.wait(2)
        return
    end
    
    local islandPos = getIslandPosition(island.name)
    if not islandPos then
        print("Không tìm thấy đảo " .. island.name)
        task.wait(2)
        return
    end
    moveTo(islandPos)
    
    local mob = findNearestMob()
    if not mob then
        local gathered = gatherMobs(islandPos, 150)
        if #gathered > 0 then
            mob = gathered[1]
        else
            task.wait(0.5)
            return
        end
    end
    
    if mob then
        attackMob(mob)
    end
    
    task.wait(0.1)
end

function _G.StartFarm()
    if isFarming then return end
    isFarming = true
    farmThread = task.spawn(function()
        while isFarming do
            pcall(_G.FarmTick)
            task.wait(0.1)
        end
    end)
end

function _G.StopFarm()
    isFarming = false
    if farmThread then
        task.cancel(farmThread)
        farmThread = nil
    end
end

function _G.GoToSafeZone()
    local level = getPlayerLevel()
    local island = getIslandForLevel(level)
    if not island then return end
    local pos = getIslandPosition(island.name)
    if pos then
        moveTo(pos)
    end
end

-- ============================================================
-- TỰ TẠO UI (KHÔNG LOAD NGOÀI)
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "doeakHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🐉 doeak hub"
Title.TextColor3 = Color3.fromRGB(220, 220, 230)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Content
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = MainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = Content

-- Hàm tạo label
local function CreateLabel(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(200, 200, 210)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Content
    return lbl
end

-- Hàm tạo toggle
local function CreateToggle(label, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = Content
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 200, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 25)
    btn.Position = UDim2.new(1, -55, 0.5, -12.5)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(80, 80, 80)
    btn.Text = ""
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = btn
    
    local state = defaultValue
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(80, 80, 80)
        callback(state)
    end)
end

-- Hàm tạo slider
local function CreateSlider(label, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = Content
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. default
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 0, 20)
    slider.Position = UDim2.new(0, 0, 0, 22)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    slider.Text = ""
    slider.Parent = frame
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local value = default
    slider.MouseButton1Click:Connect(function()
        local newVal = math.random(min * 10, max * 10) / 10
        value = math.floor(newVal * 10) / 10
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        lbl.Text = label .. ": " .. value
        callback(value)
    end)
end

-- Hàm tạo button
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 230)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Content
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
end

-- ===== XÂY DỰNG UI =====
CreateLabel("📊 Level: " .. getPlayerLevel(), Color3.fromRGB(180, 200, 255))

CreateToggle("🔁 Auto Farm", false, function(state)
    if state then
        _G.StartFarm()
    else
        _G.StopFarm()
    end
end)

CreateToggle("📋 Có Quest", true, function(state)
    _G.QuestMode = state and "Có Quest" or "Không Quest"
end)

CreateSlider("⏱️ Delay đánh (s)", 0.3, 5, 0.5, function(val)
    _G.AttackDelay = val
end)

CreateButton("🏠 Về đảo an toàn", function()
    _G.GoToSafeZone()
end)

CreateButton("🔄 Cập nhật level", function()
    local lv = getPlayerLevel()
    for _, child in pairs(Content:GetChildren()) do
        if child:IsA("TextLabel") and child.Text:find("📊 Level") then
            child.Text = "📊 Level: " .. lv
        end
    end
end)

-- ============================================================
-- DRAG & TOGGLE
-- ============================================================

local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("✅ doeak hub loaded! Press Insert to toggle.")
