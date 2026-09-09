-- ============================================================
-- main.lua - Điều phối cho doeak hub
-- ============================================================

print("🐉 Loading doeak hub...")

-- Load các module
local loadSuccess, loadErr = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/idkshdcs/DOEAK_Hub/main/orion.lua"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/idkshdcs/DOEAK_Hub/main/auto_farm.lua"))()
end)

if not loadSuccess then
    warn("Lỗi load module: " .. tostring(loadErr))
    return
end

print("✅ doeak hub loaded successfully!")
print("Press Insert to toggle GUI")
