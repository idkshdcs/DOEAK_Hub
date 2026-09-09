-- ============================================================
-- doeak hub - Auto Farm Blox Fruit (gộp 1 file)
-- ============================================================

local player = game.Players.LocalPlayer
local level = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Level")
local playerLevel = level and level.Value or 0

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

-- ===== DỮ LIỆU ĐẢO =====
local ISLAND_DATA = {
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
    {name = "Kingdom of Rose", minLevel = 700, maxLevel = 850},
    {name = "Green Zone", minLevel = 875, maxLevel = 925},
    {name = "Graveyard", minLevel = 950, maxLevel = 975},
    {name = "Snow Mountain", minLevel = 1000, maxLevel = 1050},
    {name = "Cursed Ship", minLevel = 1000, maxLevel = 1325},
    {name = "Hot and Cold", minLevel = 1100, maxLevel = 1200},
    {name = "Ice Castle", minLevel = 1350, maxLevel = 1400},
    {name = "Forgotten Island", minLevel = 1425, maxLevel = 1475},
    {name = "Port Town", minLevel = 1500, maxLevel = 1575},
    {name = "Hydra Island", minLevel = 1575, maxLevel = 1700},
    {name = "Great Tree", minLevel = 1700, maxLevel = 1775},
    {name = "Floating Turtle", minLevel = 1775, maxLevel = 2000},
    {name = "Haunted Castle", minLevel = 1975, maxLevel = 2075},
    {name = "Sea of Treats", minLevel = 2075, maxLevel = 2275},
    {name = "Tiki Outpost", minLevel = 2450, maxLevel = 2700},
}

-- ===== HÀM TÌM ĐẢO =====
local function getIslandForLevel(level)
    for _, island in ipairs(ISLAND_DATA) do
        if level >= island.minLevel and level <= island.maxLevel then
            return island
        end
    end
    return nil
end

-- ===== HÀM TÌM VỊ TRÍ ĐẢO =====
local function getIslandPosition(islandName)
    for _, child in pairs(workspace:GetChildren()) do
        if child:IsA("Model") and child.Name:lower():find(islandName:lower()) then
            local root = child:FindFirstChild("HumanoidRootPart")
            if root then return root.Position end
        end
    end
    return nil
end

-- ===== LOGIC FARM =====
local isFarming = false
local farmThread = nil

function _G.FarmTick()
    if not isFarming then return end
    local island = getIslandForLevel(playerLevel)
    if not island then return end
    local pos = getIslandPosition(island.name)
    if not pos then return end
    print("Farming at", island.name)
    -- Thêm code di chuyển, tấn công quái ở đây
end

function _G.StartFarm()
    if isFarming then return end
    isFarming = true
    farmThread = task.spawn(function()
        while isFarming do
            pcall(_G.FarmTick)
            task.wait(0.5)
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
    local island = getIslandForLevel(playerLevel)
    if not island then return end
    local pos = getIslandPosition(island.name)
    if pos then
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(pos)
        end
    end
end

-- ===== TẠO UI =====
local Window = Rayfield:CreateWindow({
    Name = "🐉 doeak hub",
    LoadingTitle = "Đang tải...",
    LoadingSubtitle = "by doeak",
    ConfigurationSaving = { Enabled = true, FolderName = "doeak_hub", FileName = "settings" },
    KeySystem = false
})

local FarmTab = Window:CreateTab("Auto Farm", "https://i.imgur.com/5Y7K1Qf.png")

FarmTab:CreateParagraph({
    Title = "Thông tin",
    Content = "Level hiện tại: " .. playerLevel
})

FarmTab:CreateToggle({
    Name = "Bật Auto Farm",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            _G.StartFarm()
        else
            _G.StopFarm()
        end
    end
})

FarmTab:CreateDropdown({
    Name = "Chế độ Quest",
    Options = {"Có Quest", "Không Quest"},
    CurrentOption = "Có Quest",
    Callback = function(Value)
        _G.QuestMode = Value
    end
})

FarmTab:CreateSlider({
    Name = "Delay đánh (giây)",
    Range = {0.3, 5},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(Value)
        _G.AttackDelay = Value
    end
})

FarmTab:CreateButton({
    Name = "Về đảo an toàn",
    Callback = function()
        _G.GoToSafeZone()
    end
})

Rayfield:LoadConfiguration()
print("✅ doeak hub loaded! Press Insert to toggle GUI.")
