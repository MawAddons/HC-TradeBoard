-- Standalone logic smoke test; run from the workspace root with Lua 5.0/5.1.
table.getn = table.getn or function(value) return #value end
string.gfind = string.gfind or string.gmatch
math.mod = math.mod or math.fmod

function UnitName() return "Tester" end
function UnitLevel() return 30 end
function GetGuildInfo() return "Test Guild" end
function GetTime() return 1000 end
function time() return 2000000000 end

dofile("HC-Tradeboard/Core.lua")

local TB = TradeBoard
TradeBoardDB = nil
TB:InitializeWorldLog()

TB:CaptureWorldMessage("ordinary conversation", "Chatter", "World")
assert(table.getn(TB.WorldLog) == 0, "non-WTS/LFW message was captured")
TB:CaptureWorldMessage("WTS cloth", "Seller", "General")
assert(table.getn(TB.WorldLog) == 0, "non-World message was captured")

local link = "|cff1eff00|Hitem:2589:0:0:0|h[Linen Cloth]|h|r"
TB:CaptureWorldMessage("WTS " .. link .. " cheap", "Seller", "1. World")
assert(table.getn(TB.WorldLog) == 1, "WTS message was not captured")
assert(TB.WorldLog[1].type == "WTS", "WTS type was not classified")
assert(TB.WorldLog[1].items[1] == link, "item hyperlink was not retained")

TB:CaptureWorldMessage("LFW alchemist", "Crafter", "World")
assert(table.getn(TB.WorldLog) == 2 and TB.WorldLog[2].type == "LFW", "LFW message was not captured")
TB:ApplyWhoResult("Crafter", "Potion Club", 42)
assert(TB.WorldLog[2].guild == "Potion Club" and TB.WorldLog[2].level == 42, "who metadata was not applied")

TB.State.worldType = "WTS"
TB.State.worldSearch = "seller"
assert(table.getn(TB:GetFilteredWorldLog()) == 1, "World log filtering failed")

print("HC TradeBoard World log smoke test passed")
