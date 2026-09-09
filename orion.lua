-- ============================================================
-- orion.lua - Giao diện Orion cho doeak hub
-- ============================================================

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local player = game.Players.LocalPlayer
local farmEnabled = false
local farmThread = nil

-- Tạo cửa sổ chính
local Window = OrionLib:MakeWindow({
    Name = "🐉 doeak hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "doeak_hub"
})

-- ===== TAB: AUTO FARM =====
local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "⚔️",
    PremiumOnly = false
})

-- Khu vực thông tin
FarmTab:AddParagraph({
    Name = "Thông tin",
    Content = "Level hiện tại: " .. player.Level
})

-- Toggle bật/tắt farm
FarmTab:AddToggle({
    Name = "Bật Auto Farm",
    Default = false,
    Callback = function(Value)
        farmEnabled = Value
        if Value then
            -- Gọi hàm farm từ auto_farm.lua
            if not farmThread then
                farmThread = task.spawn(function()
                    while farmEnabled do
                        local success, err = pcall(function()
                            _G.FarmTick()
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
            _G.StopFarm()
        end
    end
})

-- Chọn chế độ Quest
FarmTab:AddDropdown({
    Name = "Chế độ Quest",
    Default = "Có Quest",
    Options = {"Có Quest", "Không Quest"},
    Callback = function(Value)
        _G.QuestMode = Value
    end
})

-- Thanh trượt delay đánh
FarmTab:AddSlider({
    Name = "Delay đánh (giây)",
    Min = 0.3,
    Max = 5,
    Default = 0.5,
    Increment = 0.1,
    Callback = function(Value)
        _G.AttackDelay = Value
    end
})

-- Nút về đảo an toàn
FarmTab:AddButton({
    Name = "Về đảo an toàn",
    Callback = function()
        _G.GoToSafeZone()
    end
})

-- ===== TAB: THÔNG TIN =====
local InfoTab = Window:MakeTab({
    Name = "Thông tin",
    Icon = "ℹ️",
    PremiumOnly = false
})

InfoTab:AddParagraph({
    Name = "Hướng dẫn",
    Content = "1. Bật Auto Farm\n2. Chọn chế độ Quest\n3. Điều chỉnh delay đánh\n4. Farm sẽ tự động tìm quái phù hợp với level"
})

-- ===== KHAI BÁO BIẾN TOÀN CỤC =====
_G.QuestMode = "Có Quest"
_G.AttackDelay = 0.5
_G.GoToSafeZone = function() end -- Sẽ được gán từ auto_farm.lua
_G.FarmTick = function() end    -- Sẽ được gán từ auto_farm.lua
_G.StopFarm = function() end    -- Sẽ được gán từ auto_farm.lua

OrionLib:Init()