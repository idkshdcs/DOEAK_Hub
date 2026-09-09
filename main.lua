-- ============================================================
-- doeak hub - Auto Farm Blox Fruit
-- UI tự tạo, không phụ thuộc thư viện
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- ============================================================
-- DỮ LIỆU ĐẢO
-- ============================================================

local ISLAND_DATA = {
    -- Sea 1
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
    -- Sea 2
    {name = "Kingdom of Rose", minLevel = 700, maxLevel = 850, sea = 2, questNPC = "Kingdom of Rose Quest Giver", mobs = {"Raider", "Merc"}},
    {name = "Green Zone", minLevel = 875, maxLevel = 925, sea = 2, questNPC = "Green Zone Quest Giver", mobs = {"Green Zone Enemy"}},
    {name = "Graveyard", minLevel = 950, maxLevel = 975, sea = 2, questNPC = "Graveyard Quest Giver", mobs = {"Zombie"}},
    {name = "Snow Mountain", minLevel = 1000, maxLevel = 1050, sea = 2, questNPC = "Snow Mountain Quest Giver", mobs = {"Winter Enemy"}},
    {name = "Cursed Ship", minLevel = 1000, maxLevel = 1325, sea = 2, questNPC = "Cursed Ship Quest Giver", mobs = {"Cursed Crew"}},
    {name = "Hot and Cold", minLevel = 1100, maxLevel = 1200, sea = 2, questNPC = "Hot and Cold Quest Giver", mobs = {"Elemental Enemy"}},
    {name = "Ice Castle", minLevel = 1350, maxLevel = 1400, sea = 2, questNPC = "Ice Castle Quest Giver", mobs = {"Ice Enemy"}},
    {name = "Forgotten Island", minLevel = 1425, maxLevel = 1475, sea = 2, questNPC = "Forgotten Island Quest Giver", mobs = {"Dark Step Enemy"}},
    -- Sea 3
    {name = "Port Town", minLevel = 1500, maxLevel = 1575, sea = 3, questNPC = "Port Town Quest Giver", mobs = {"Pirate Millionaire", "Pistol Billionaire"}},
    {name = "Hydra Island", minLevel = 1575, maxLevel = 1700, sea = 3, questNPC = "Hydra Island Quest Giver", mobs = {"Dragon Crew Warrior", "Dragon Crew Archer", "Female Islander", "Giant Islander"}},
    {name = "Great Tree", minLevel = 1700, maxLevel = 1775, sea = 3, questNPC = "Great Tree Quest Giver", mobs = {"Marine Commodore", "Marine Rear Admiral"}},
    {name = "Floating Turtle", minLevel = 1775, maxLevel = 2000, sea = 3, questNPC = "Floating Turtle Quest Giver", mobs = {"Fishman Raider", "Fishman Captain", "Forest Pirate", "Mythological Pirate"}},
    {name = "Haunted Castle", minLevel = 1975, maxLevel = 2075, sea = 3, questNPC = "Haunted Castle Quest Giver", mobs = {"Haunted Enemy"}},
    {name = "Sea of Treats", minLevel = 2075, maxLevel = 2275, sea = 3, questNPC = "Sea of Treats Quest Giver", mobs = {"Treat Enemy"}},
    {name = "Tiki Outpost", minLevel = 2450, maxLevel = 2700, sea = 3, questNPC = "Tiki Outpost Quest Giver", mobs = {"Tiki Enemy"}}
}

-- ============================================================
-- BIẾN TRẠNG THÁI FARM
-- ============================================================

local farmEnabled = false
local farmThread = nil
local questMode = "Có Quest"   -- "Có Quest" hoặc "Không Quest"
local attackDelay = 0.5
local isFarming = false
local currentTarget = nil

-- ============================================================
-- UI TẠO BẰNG TAY
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "doeakHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Shadow
local MainShadow = Instance.new("Frame")
MainShadow.Size = UDim2.new(0, 380, 0, 480)
MainShadow.Position = UDim2.new(0.5, -190, 0.5, -240)
MainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.BackgroundTransparency = 0.3
MainShadow.BorderSizePixel = 0
MainShadow.Parent = ScreenGui
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 12)
shadowCorner.Parent = MainShadow

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 12, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = MainShadow
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 20, 55)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -60, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🐉 doeak hub"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Content Area
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -55)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, 0)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = ContentFrame
local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 10)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Parent = Scroll

-- ===== HÀM TẠO UI COMPONENTS =====

local function CreateLabel(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 30)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(240, 240, 255)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Scroll
    return lbl
end

local function CreateToggle(labelText, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(30, 20, 55)
    frame.Parent = Scroll
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(240, 240, 255)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 26)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -13)
    toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(50, 255, 100) or Color3.fromRGB(80, 80, 80)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = frame
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = defaultValue and UDim2.new(0, 26, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBtn
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle

    local state = defaultValue
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(50, 255, 100) or Color3.fromRGB(80, 80, 80)
        TweenService:Create(circle, TweenInfo.new(0.25), {
            Position = state and UDim2.new(0, 26, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        }):Play()
        if callback then callback(state) end
    end)

    return frame
end

local function CreateDropdown(labelText, options, defaultOption, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(30, 20, 55)
    frame.Parent = Scroll
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(240, 240, 255)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.55, 0, 0, 30)
    dropdown.Position = UDim2.new(0.43, 0, 0.5, -15)
    dropdown.BackgroundColor3 = Color3.fromRGB(18, 12, 35)
    dropdown.Text = defaultOption or options[1]
    dropdown.TextColor3 = Color3.fromRGB(240, 240, 255)
    dropdown.TextSize = 12
    dropdown.Font = Enum.Font.Gotham
    dropdown.Parent = frame
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropdown

    local expanded = false
    local optionFrame = nil

    dropdown.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            optionFrame = Instance.new("Frame")
            optionFrame.Size = UDim2.new(0.55, 0, 0, #options * 30)
            optionFrame.Position = UDim2.new(0.43, 0, 0.5, 15)
            optionFrame.BackgroundColor3 = Color3.fromRGB(18, 12, 35)
            optionFrame.Parent = frame
            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 6)
            optCorner.Parent = optionFrame

            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 2)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = optionFrame

            for _, opt in ipairs(options) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -4, 0, 28)
                btn.Position = UDim2.new(0, 2, 0, 0)
                btn.BackgroundColor3 = Color3.fromRGB(30, 20, 55)
                btn.Text = opt
                btn.TextColor3 = Color3.fromRGB(240, 240, 255)
                btn.TextSize = 12
                btn.Font = Enum.Font.Gotham
                btn.Parent = optionFrame
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = btn

                btn.MouseButton1Click:Connect(function()
                    dropdown.Text = opt
                    if callback then callback(opt) end
                    expanded = false
                    if optionFrame then optionFrame:Destroy() end
                end)
            end
        else
            if optionFrame then optionFrame:Destroy() end
        end
    end)

    return frame
end

local function CreateSlider(labelText, minVal, maxVal, defaultVal, increment, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(30, 20, 55)
    frame.Parent = Scroll
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0, 5, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. ": " .. defaultVal
    lbl.TextColor3 = Color3.fromRGB(240, 240, 255)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, -10, 0, 20)
    sliderBtn.Position = UDim2.new(0, 5, 0, 28)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(18, 12, 35)
    sliderBtn.Text = ""
    sliderBtn.Parent = frame
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBtn

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBtn
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local currentVal = defaultVal
    sliderBtn.MouseButton1Click:Connect(function()
        local newVal = math.random(math.floor(minVal/increment), math.floor(maxVal/increment)) * increment
        newVal = math.floor(newVal / increment) * increment
        if newVal < minVal then newVal = minVal end
        if newVal > maxVal then newVal = maxVal end
        currentVal = newVal
        lbl.Text = labelText .. ": " .. newVal
        fill.Size = UDim2.new((newVal - minVal) / (maxVal - minVal), 0, 1, 0)
        if callback then callback(newVal) end
    end)

    return frame
end

local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Scroll
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ===== XÂY DỰNG UI =====

CreateLabel("🐉 doeak hub - Auto Farm", Color3.fromRGB(180, 100, 255))
CreateLabel("Level hiện tại: " .. player.Level, Color3.fromRGB(150, 200, 255))

-- Toggle Auto Farm
local toggleFarm = CreateToggle("Bật Auto Farm", false, function(state)
    farmEnabled = state
    if state then
        if not farmThread then
            farmThread = task.spawn(function()
                while farmEnabled do
                    local success, err = pcall(function()
                        FarmTick()
                    end)
                    if not success then
                        warn("Lỗi farm: " .. tostring(err))
                    end
                    task.wait(0.1)
                end
            end)
        end
    else
        if farmThread then
            task.cancel(farmThread)
            farmThread = nil
        end
        StopFarm()
    end
end)

-- Dropdown Quest Mode
local questDropdown = CreateDropdown("Chế độ Quest", {"Có Quest", "Không Quest"}, "Có Quest", function(val)
    questMode = val
end)

-- Slider Delay đánh
local delaySlider = CreateSlider("Delay đánh (giây)", 0.3, 5, 0.5, 0.1, function(val)
    attackDelay = val
end)

-- Button về đảo an toàn
CreateButton("Về đảo an toàn", function()
    GoToSafeZone()
end)

-- ============================================================
-- LOGIC AUTO FARM
-- ============================================================

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

local function getIslandPosition(islandName)
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child.Name and child.Name:lower():find(islandName:lower()) then
            local root = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head")
            if root then
                return root.Position
            end
        end
    end
    return nil
end

local function moveTo(position)
    if not hrp then return end
    local distance = (position - hrp.Position).Magnitude
    if distance < 2 then return end
    
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

local function findNearestMob()
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

local function gatherMobs(targetPoint, radius)
    local gathered = {}
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
    return gathered
end

local function attackMob(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return false end
    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return false end
    
    -- Vị trí an toàn: bay lên cao 15 studs
    local safePosition = mobRoot.Position + Vector3.new(0, 15, 0)
    moveTo(safePosition)
    
    local startTime = tick()
    while tick() - startTime < attackDelay do
        if not mob or not mob:FindFirstChild("Humanoid") or mob:FindFirstChild("Humanoid").Health <= 0 then
            break
        end
        -- Mô phỏng tấn công (có thể thay bằng remote click nếu biết)
        local fakeAttack = Instance.new("Part")
        fakeAttack.Size = Vector3.new(2, 2, 2)
        fakeAttack.CFrame = mobRoot.CFrame + Vector3.new(0, 5, 0)
        fakeAttack.Parent = Workspace
        game:GetService("Debris"):AddItem(fakeAttack, 0.1)
        task.wait(0.1)
    end
    
    return true
end

function FarmTick()
    local level = player.Level
    local island = getIslandForLevel(level)
    if not island then
        warn("Không tìm thấy đảo phù hợp với level " .. level)
        task.wait(1)
        return
    end
    
    local islandPos = getIslandPosition(island.name)
    if not islandPos then
        warn("Không tìm thấy vị trí đảo " .. island.name)
        task.wait(1)
        return
    end
    moveTo(islandPos)
    
    local mob = findNearestMob()
    if not mob then
        local gathered = gatherMobs(islandPos, 100)
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

function StopFarm()
    isFarming = false
    if currentTarget then
        currentTarget = nil
    end
end

function GoToSafeZone()
    local level = player.Level
    local island = getIslandForLevel(level)
    if not island then return end
    local pos = getIslandPosition(island.name)
    if pos then
        moveTo(pos)
    end
end

-- ============================================================
-- DRAG SYSTEM
-- ============================================================

local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainShadow.Position
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
        MainShadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============================================================
-- INSERT KEY TOGGLE
-- ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainShadow.Visible = not MainShadow.Visible
    end
end)

-- ============================================================
-- STARTUP
-- ============================================================

print("✅ doeak hub loaded! Press Insert to toggle GUI.")
