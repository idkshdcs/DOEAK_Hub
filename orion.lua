-- ============================================================
-- orion.lua - Giao diện Rayfield cho doeak hub
-- ============================================================

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
local player = game.Players.LocalPlayer
local farmEnabled = false
local farmThread = nil

-- Tạo cửa sổ chính
local Window = Rayfield:CreateWindow({
    Name = "🐉 doeak hub",
    Icon = "https://i.imgur.com/5Y7K1Qf.png", -- icon tùy chọn
    LoadingTitle = "Đang tải doeak hub...",
    LoadingSubtitle = "by doeak",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "doeak_hub",
        FileName = "settings"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false,
    KeySettings = {
        Title = "doeak hub",
        Subtitle = "Nhập key",
        Note = "Liên hệ tác giả để lấy key",
        FileName = "key",
        SaveKey = false,
        Key = {"key1", "key2"} -- để trống nếu không dùng key
    }
})

-- ===== TAB: AUTO FARM =====
local FarmTab = Window:CreateTab("Auto Farm", "https://i.imgur.com/5Y7K1Qf.png")

-- Khu vực thông tin
FarmTab:CreateParagraph({
    Title = "Thông tin",
    Content = "Level hiện tại: " .. player.Level
})

-- Toggle bật/tắt farm
FarmTab:CreateToggle({
    Name = "Bật Auto Farm",
    CurrentValue = false,
    Callback = function(Value)
        farmEnabled = Value
        if Value then
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
FarmTab:CreateDropdown({
    Name = "Chế độ Quest",
    Options = {"Có Quest", "Không Quest"},
    CurrentOption = "Có Quest",
    Callback = function(Value)
        _G.QuestMode = Value
    end
})

-- Thanh trượt delay đánh
FarmTab:CreateSlider({
    Name = "Delay đánh (giây)",
    Range = {0.3, 5},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(Value)
        _G.AttackDelay = Value
    end
})

-- Nút về đảo an toàn
FarmTab:CreateButton({
    Name = "Về đảo an toàn",
    Callback = function()
        _G.GoToSafeZone()
    end
})

-- ===== TAB: THÔNG TIN =====
local InfoTab = Window:CreateTab("Thông tin", "https://i.imgur.com/5Y7K1Qf.png")

InfoTab:CreateParagraph({
    Title = "Hướng dẫn sử dụng",
    Content = "1. Bật Auto Farm\n2. Chọn chế độ Quest\n3. Điều chỉnh delay đánh\n4. Farm sẽ tự động tìm quái phù hợp với level"
})

-- ===== KHAI BÁO BIẾN TOÀN CỤC =====
_G.QuestMode = "Có Quest"
_G.AttackDelay = 0.5
_G.GoToSafeZone = function() end
_G.FarmTick = function() end
_G.StopFarm = function() end

-- Khởi chạy Rayfield
Rayfield:LoadConfiguration()

print("✅ Rayfield UI loaded!")
