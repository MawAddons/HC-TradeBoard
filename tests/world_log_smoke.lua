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
dofile("HC-Tradeboard/Network.lua")

local TB = TradeBoard
TradeBoardDB = nil
TB:InitializeWorldLog()

TB:CaptureWorldMessage("ordinary conversation", "Chatter", "World")
assert(table.getn(TB.WorldLog) == 0, "non-WTS/LFW message was captured")
TB:CaptureWorldMessage("WTS cloth", "Seller", "General")
assert(table.getn(TB.WorldLog) == 0, "non-World message was captured")

local link = "|cff1eff00|Hitem:2589:0:0:0|h[Linen Cloth]|h|r"
TB:CaptureWorldMessage("wTs " .. link .. " cheap", "Seller", "1. World")
assert(table.getn(TB.WorldLog) == 1, "WTS message was not captured")
assert(TB.WorldLog[1].type == "WTS", "WTS type was not classified")
assert(TB.WorldLog[1].items[1] == link, "item hyperlink was not retained")

TB:CaptureWorldMessage("lfw alchemist", "Crafter", "World")
assert(table.getn(TB.WorldLog) == 2 and TB.WorldLog[2].type == "LFW", "LFW message was not captured")
TB:RememberWorldPerson("Crafter", "Potion Club", 42)
assert(TB.WorldLog[2].guild == "Potion Club" and TB.WorldLog[2].level == 42, "known peer metadata was not applied")

TB:CaptureWorldMessage("wTb linen cloth", "Buyer", "World")
assert(table.getn(TB.WorldLog) == 3 and TB.WorldLog[3].type == "WTB", "case-insensitive WTB message was not captured")

TB.State.worldType = "WTS"
TB.State.worldSearch = "seller"
assert(table.getn(TB:GetFilteredWorldLog()) == 1, "World log filtering failed")

local friends = { shown = true }
function friends:IsShown() return self.shown end
FriendsFrame = friends
function HideUIPanel(frame) frame.shown = false end
function GetNumWhoResults() return 1 end
function GetWhoInfo() return "Buyer", "Buyers Guild", 37 end
TB.PendingWhoName = "buyer"
TB.addonWhoShouldClose = 1
TB:NetworkOnEvent("WHO_LIST_UPDATE")
assert(TB.closeWhoOnNextUpdate, "Who close was not deferred until after Blizzard's event handler")
TB:CloseAddonWhoFrame()
assert(not FriendsFrame:IsShown(), "addon-triggered Who window was not closed")
assert(TB.WorldLog[3].guild == "Buyers Guild" and TB.WorldLog[3].level == 37, "Who result did not enrich WTB data")

print("HC TradeBoard World log smoke test passed")
