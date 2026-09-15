-- Headless construction smoke test for the WoW 1.12 UI layout.
table.getn = table.getn or function(value) return #value end
string.gfind = string.gfind or string.gmatch
math.mod = math.mod or math.fmod
math.atan2 = math.atan2 or math.atan

local Frame = {}
Frame.__index = function(self, key)
    local methods = {
        SetWidth = function(object, value) object.width = value end,
        SetHeight = function(object, value) object.height = value end,
        GetWidth = function(object) return rawget(object, "width") or 100 end,
        GetHeight = function(object) return rawget(object, "height") or 100 end,
        SetText = function(object, value) object.textValue = value or "" end,
        GetText = function(object) return object.textValue or "" end,
        GetStringWidth = function(object) return string.len(object.textValue or "") * 6 end,
        SetScript = function(object, event, callback) object.scripts[event] = callback end,
        GetScript = function(object, event) return object.scripts[event] end,
        Show = function(object) object.shown = true end,
        Hide = function(object) object.shown = false end,
        IsShown = function(object) return object.shown end,
        Enable = function(object) object.enabled = true end,
        Disable = function(object) object.enabled = false end,
        GetFrameLevel = function() return 1 end,
        GetEffectiveScale = function() return 1 end,
        GetCenter = function() return 500, 400 end,
        GetTop = function() return 500 end,
        GetID = function() return 1 end,
        CreateTexture = function(object) return setmetatable({ scripts = {}, shown = true, parent = object }, Frame) end,
        CreateFontString = function(object) return setmetatable({ scripts = {}, shown = true, parent = object, textValue = "" }, Frame) end,
    }
    if methods[key] then return methods[key] end
    return function() end
end

function CreateFrame(frameType, name, parent)
    local frame = setmetatable({ scripts = {}, shown = true, parent = parent, frameType = frameType }, Frame)
    if name then _G[name] = frame end
    return frame
end

UIParent = CreateFrame("Frame", "UIParent")
Minimap = CreateFrame("Frame", "Minimap", UIParent)
GameTooltip = CreateFrame("Frame", "GameTooltip", UIParent)
ChatFrameEditBox = CreateFrame("EditBox", "ChatFrameEditBox", UIParent)
DEFAULT_CHAT_FRAME = CreateFrame("Frame", "ChatFrame1", UIParent)
UISpecialFrames = {}
SlashCmdList = {}

function getglobal(name) return _G[name] end
function UnitName() return "Tester" end
function UnitLevel() return 30 end
function UnitFactionGroup() return "Alliance" end
function GetGuildInfo() return "Test Guild" end
function GetTime() return 1000 end
function time() return 2000000000 end
function date() return "09-15 12:00" end
function GetCursorPosition() return 500, 400 end
function GetNumSkillLines() return 0 end
function GetChannelName() return 0 end
function GetContainerNumSlots() return 0 end
function GetItemInfo(link) return "Linen Cloth", link, 2, 10, 5, "Trade Goods", "Cloth", 20, "", "Interface\\Icons\\INV_Fabric_Linen_01" end
function IsShiftKeyDown() return nil end
function CursorHasItem() return nil end
function ClearCursor() end
function ChatFrame_OpenChat() end
function AddFriend() end
function ChatFrame_RemoveChannel() end

dofile("HC-Tradeboard/Core.lua")
dofile("HC-Tradeboard/Network.lua")
dofile("HC-Tradeboard/UI.lua")

local TB = TradeBoard
assert(TB.Frames.main.width == 1180 and TB.Frames.main.height == 720, "main window did not use approved larger layout")
assert(table.getn(TB.Frames.resultRows) == 10, "Browse did not create ten rows")
assert(table.getn(TB.Frames.myListingRows) == 9, "My Listings did not create nine rows")
assert(table.getn(TB.Frames.professionRows) == 10, "Professions did not create ten rows")
assert(table.getn(TB.Frames.worldLogRows) == 10, "World Trade did not create ten rows")
assert(TB.Frames.browseScrollbar and TB.Frames.worldScrollbar and TB.Frames.professionScrollbar, "classic scrollbars were not created")

local link = "|cff1eff00|Hitem:2589:0:0:0|h[Linen Cloth]|h|r"
TB.Listings = {{ id = "one", owner = "Seller", trader = "Seller", itemLink = link, name = "Linen Cloth", texture = "x", quality = 2, requiredLevel = 5, itemLevel = 10, quantity = 20, totalPrice = 20000, traderLevel = 30, class = "Mage", guild = "Guild", orderType = "SELL", category = "Trade Goods", tags = {}, online = 1 }}
TB:RebuildListingIndex()
TB:UpdateBrowse()
assert(TB.Frames.resultRows[1].price:GetText() == "2g 0s 0c", "Browse did not display total price")
assert(TB.Frames.resultRows[1].whoButton.trader == "Seller", "Browse Who button was not linked to seller")

TB.MyListings = { TB.Listings[1] }
TB:UpdateMyListings()
assert(TB.Frames.myListingRows[1].price:GetText() == "2g 0s 0c", "My Listings did not display total price")

TB.Services = {{ owner = "Crafter", trader = "Crafter", guild = "Crafters", profession = "Enchanting", rank = 300, maxRank = 300, note = "Crusader", source = "CHAT", level = 60, class = "Priest", online = 1 }}
TB:RebuildServiceIndex()
TB:UpdateProfessions()
assert(TB.Frames.professionRows[1].source:GetText() == "Chat", "Profession chat source was not displayed")
assert(TB.Frames.professionRows[1].whoButton.trader == "Crafter", "Profession Who button was not linked to crafter")

TB.Chains = { TB:BuildChainFromSaved({ name = "Test Chain", members = { "Tester" } }, "Tester", 1) }
TB.State.selectedChain = 1
TB:UpdateTradeChains()
assert(TB.Frames.chainWhoButton.trader == "Tester", "Trade Chain owner Who button was not populated")

TradeBoardDB = { worldLog = {}, worldPeople = {} }
TB.WorldLog = TradeBoardDB.worldLog
TB:CaptureWorldMessage("WTS " .. link .. " 2g", "Seller", "World")
TB:UpdateWorldLog()
assert(TB.Frames.worldLogRows[1].whoButton.sender == "Seller", "World Who button was not linked to sender")

print("HC TradeBoard UI smoke test passed")
