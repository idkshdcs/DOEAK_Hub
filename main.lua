-- ============================================================
-- main.lua - doeak hub (UI tự tạo + auto farm tích hợp)
-- ============================================================

print("🐉 Loading doeak hub...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- ===== DỮ LIỆU ĐẢO =====
local ISLAND_DATA = {
    -- Sea 1
    {name = "Jungle", minLevel = 10, maxLevel = 30},
    {name = "Pirate Village", minLevel = 30, maxLevel = 60},
    {name = "Desert", minLevel = 60, maxLevel = 90},
    {name = "Frozen Village", minLevel = 90, maxLevel = 120},
    {name = "Marine Fortress", minLevel = 120, maxLevel = 150},
    {name = "Skylands", minLevel = 150, maxLevel = 200},
    {name = "Prison", minLevel = 190, maxLevel = 275},
    {name = "Colosseum", minLevel = 225, maxLevel = 300},
    {name = "Magma Village", minLevel = 300, maxLevel = 375},
    {name = "Underwater City", minLevel = 375, maxLevel = 450},
    {name = "Fountain City", minLevel = 625, maxLevel = 700},
    -- Sea 2
    {name = "Kingdom of Rose", minLevel = 700, maxLevel = 850},
    {name = "Green Zone", minLevel = 875, maxLevel = 925},
    {name = "Graveyard", minLevel = 950, maxLevel = 975},
    {name = "Snow Mountain", minLevel = 1000, maxLevel = 1050},
    {name = "Cursed Ship", minLevel = 1000, maxLevel = 1325},
    {name = "Hot and Cold", minLevel = 1100, maxLevel = 1200},
    {name = "Ice Castle", minLevel = 1350, maxLevel = 1400},
    {name = "Forgotten Island", minLevel = 1425, maxLevel = 1475},
    -- Sea 3
    {name = "Port Town", minLevel = 1500, maxLevel = 1575},
    {name = "Hydra Island", minLevel = 1575, maxLevel = 1700},
    {name = "Great Tree", minLevel = 1700, maxLevel = 1775},
    {name = "Floating Turtle", minLevel = 1775, maxLevel = 2000},
    {name = "Haunted Castle", minLevel = 1975, maxLevel = 2075},
    {name = "Sea of Treats", minLevel = 2075, maxLevel = 2275},
    {name = "Tiki Outpost", minLevel = 2450, maxLevel = 2700}
}

-- ===== BIẾN TOÀN CỤC =====
local farmEnabled = false
local farmThread = nil
local attackDelay = 0.5
local questMode = "Có Quest"

-- ===== UI (TỰ TẠO) =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "doeakHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 30, 70)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🐉 doeak hub"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
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

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -10, 1, -50)
Content.Position = UDim2.new(0, 5, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 25, 55)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Content
local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = Sidebar

local TabList = Instance.new("Frame")
TabList.Size = UDim2.new(1, -10, 1, -10)
TabList.Position = UDim2.new(0, 5, 0, 5)
TabList.BackgroundTransparency = 1
TabList.Parent = Sidebar

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 8)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = TabList

-- Right Panel
local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1, -130, 1, 0)
RightPanel.Position = UDim2.new(0, 130, 0, 0)
RightPanel.BackgroundColor3 = Color3.fromRGB(25, 20, 50)
RightPanel.BackgroundTransparency = 0.5
RightPanel.BorderSizePixel = 0
RightPanel.Parent = Content
local rightCorner = Instance.new("UICorner")
rightCorner.CornerRadius = UDim.new(0, 8)
rightCorner.Parent = RightPanel

local PanelContainer = Instance.new("ScrollingFrame")
PanelContainer.Size = UDim2.new(1, -20, 1, -20)
PanelContainer.Position = UDim2.new(0, 10, 0, 10)
PanelContainer.BackgroundTransparency = 1
PanelContainer.ScrollBarThickness = 3
PanelContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
PanelContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
PanelContainer.Parent = RightPanel
local panelLayout = Instance.new("UIListLayout")
panelLayout.Padding = UDim.new(0, 12)
panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
panelLayout.Parent = PanelContainer

-- ===== TAB SYSTEM =====
local tabs = {}
local currentTab = nil

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(20, 15, 40)
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = TabList
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1, 0, 0, 0)
    panel.AutomaticSize = Enum.AutomaticSize.Y
    panel.BackgroundTransparency = 1
    panel.Visible = false
    panel.Parent = PanelContainer
    local panelLayoutInner = Instance.new("UIListLayout")
    panelLayoutInner.Padding = UDim.new(0, 10)
    panelLayoutInner.SortOrder = Enum.SortOrder.LayoutOrder
    panelLayoutInner.Parent = panel

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Panel.Visible = false
            TweenService:Create(t.Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 15, 40)}):Play()
        end
        panel.Visible = true
        currentTab = name
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 60, 140)}):Play()
    end)

    tabs[name] = {Button = btn, Panel = panel}
    return panel
end

-- ===== TẠO CÁC TAB =====
local FarmTab = CreateTab("Auto Farm", "⚔️")
local InfoTab = CreateTab("Thông tin", "ℹ️")

-- ===== HÀM TẠO UI COMPONENT =====
local function AddLabel(parent, text, color, size)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(220, 220, 240)
    lbl.TextSize = size or 14
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function AddToggle(parent, label, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 220, 240)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 60, 0, 28)
    toggleBtn.Position = UDim2.new(1, -65, 0.5, -14)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 80)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleBtn

    local state = default
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 80)
        toggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)

    return toggleBtn
end

local function AddDropdown(parent, label, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(1, 0, 0, 25)
    dropdown.Position = UDim2.new(0, 0, 0, 20)
    dropdown.BackgroundColor3 = Color3.fromRGB(30, 25, 60)
    dropdown.Text = default or options[1] or ""
    dropdown.TextColor3 = Color3.new(1, 1, 1)
    dropdown.TextSize = 13
    dropdown.Font = Enum.Font.Gotham
    dropdown.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = dropdown

    local currentOption = default or options[1] or ""
    local menuOpen = false
    dropdown.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        if menuOpen then
            -- Tạo dropdown list
            local list = Instance.new("Frame")
            list.Size = UDim2.new(1, 0, 0, #options * 28)
            list.Position = UDim2.new(0, 0, 0, 25)
            list.BackgroundColor3 = Color3.fromRGB(20, 15, 45)
            list.BorderSizePixel = 0
            list.ZIndex = 10
            list.Parent = frame
            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 6)
            listCorner.Parent = list

            for i, opt in ipairs(options) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 28)
                btn.BackgroundTransparency = 1
                btn.Text = opt
                btn.TextColor3 = opt == currentOption and Color3.fromRGB(180, 100, 255) or Color3.fromRGB(200, 200, 220)
                btn.TextSize = 13
                btn.Font = Enum.Font.Gotham
                btn.Parent = list
                btn.MouseButton1Click:Connect(function()
                    currentOption = opt
                    dropdown.Text = opt
                    callback(opt)
                    list:Destroy()
                    menuOpen = false
                end)
            end
        else
            for _, child in pairs(frame:GetChildren()) do
                if child:IsA("Frame") and child ~= frame and child ~= dropdown then
                    child:Destroy()
                end
            end
        end
    end)

    return dropdown
end

local function AddSlider(parent, label, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. tostring(default)
    lbl.TextColor3 = Color3.fromRGB(220, 220, 240)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 0, 25)
    sliderBtn.Position = UDim2.new(0, 0, 0, 22)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 70)
    sliderBtn.Text = ""
    sliderBtn.Parent = frame
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBtn

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBtn
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false
    local mouse = player:GetMouse()
    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    sliderBtn.MouseButton1Up:Connect(function()
        dragging = false
    end)
    mouse.Move:Connect(function()
        if dragging then
            local x = math.clamp((mouse.X - sliderBtn.AbsolutePosition.X) / sliderBtn.AbsoluteSize.X, 0, 1)
            local val = min + (max - min) * x
            val = math.round(val / 0.1) * 0.1
            fill.Size = UDim2.new(x, 0, 1, 0)
            lbl.Text = label .. ": " .. tostring(val)
            callback(val)
        end
    end)

    return sliderBtn
end

-- ===== NỘI DUNG TAB AUTO FARM =====
-- Info level
AddLabel(FarmTab, "Level hiện tại: " .. tostring(player.Level), Color3.fromRGB(100, 200, 255), 14)

-- Toggle Farm
AddToggle(FarmTab, "Bật Auto Farm", false, function(val)
    farmEnabled = val
    if val then
        if not farmThread then
            farmThread = task.spawn(function()
                while farmEnabled do
                    pcall(FarmTick)
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

-- Dropdown Quest
AddDropdown(FarmTab, "Chế độ Quest", {"Có Quest", "Không Quest"}, "Có Quest", function(val)
    questMode = val
end)

-- Slider delay
AddSlider(FarmTab, "Delay đánh (s)", 0.3, 5, 0.5, function(val)
    attackDelay = val
end)

-- Button về đảo
AddButton(FarmTab, "Về đảo an toàn", function()
    GoToSafeZone()
end)

-- ===== NỘI DUNG TAB THÔNG TIN =====
AddLabel(InfoTab, "🐉 doeak hub v1.0", Color3.fromRGB(180, 100, 255), 18)
AddLabel(InfoTab, "Auto Farm Blox Fruit", Color3.fromRGB(200, 200, 220), 14)
AddLabel(InfoTab, "Hướng dẫn:", Color3.fromRGB(180, 180, 200), 14)
AddLabel(InfoTab, "1. Bật Auto Farm", Color3.fromRGB(160, 160, 180), 13)
AddLabel(InfoTab, "2. Chọn chế độ Quest", Color3.fromRGB(160, 160, 180), 13)
AddLabel(InfoTab, "3. Điều chỉnh delay đánh", Color3.fromRGB(160, 160, 180), 13)
AddLabel(InfoTab, "4. Farm tự động tìm đảo phù hợp", Color3.fromRGB(160, 160, 180), 13)

-- ===== LOGIC AUTO FARM =====
local function getIslandForLevel(level)
    local best = nil
    for _, island in ipairs(ISLAND_DATA) do
        if level >= island.minLevel and level <= island.maxLevel then
            if not best or island.maxLevel < best.maxLevel then
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
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local distance = (position - hrp.Position).Magnitude
    if distance < 2 then return end

    local speed = 250
    local duration = distance / speed
    if duration < 0.05 then duration = 0.05 end

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(position)})
    tween:Play()
    tween.Completed:Wait()
end

local function findNearestMob()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
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

local function attackMob(mob)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not mob or not mob:FindFirstChild("HumanoidRootPart") then return false end
    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
    if not mobRoot then return false end

    local safePosition = mobRoot.Position + Vector3.new(0, 15, 0)
    moveTo(safePosition)

    local startTime = tick()
    while tick() - startTime < attackDelay do
        if not mob or not mob:FindFirstChild("Humanoid") or mob:FindFirstChild("Humanoid").Health <= 0 then
            break
        end
        -- Mô phỏng tấn công (thực tế cần remote)
        task.wait(0.1)
    end
    return true
end

function FarmTick()
    local level = player.Level
    local island = getIslandForLevel(level)
    if not island then
        task.wait(1)
        return
    end

    local islandPos = getIslandPosition(island.name)
    if not islandPos then
        task.wait(1)
        return
    end
    moveTo(islandPos)

    local mob = findNearestMob()
    if not mob then
        task.wait(0.5)
        return
    end

    attackMob(mob)
end

function StopFarm()
    -- Dừng farm
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

-- ===== DRAG SYSTEM =====
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

-- ===== PHÍM TẮT INSERT =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ===== MỞ TAB MẶC ĐỊNH =====
task.wait(0.1)
if tabs["Auto Farm"] then
    tabs["Auto Farm"].Button.MouseButton1Click:Fire()
end

print("✅ doeak hub loaded successfully!")
print("Press Insert to toggle GUI")
