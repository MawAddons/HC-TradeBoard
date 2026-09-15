-- Run from the workspace root with Lua 5.1+ (the addon remains Lua 5.0 compatible).
table.getn = table.getn or function(value) return #value end
string.gfind = string.gfind or string.gmatch
local now = 1000
local openedWhisper, clickedItem, tooltipItem
local Frame = {}
Frame.__index = function(self, key)
    local methods = {
        SetScript = function(object, name, callback) object.scripts[name] = callback end,
        SetText = function(object, text) object.text = text end,
        SetTexture = function(object, texture) object.texture = texture end,
        Show = function(object) object.shown = true end,
        Hide = function(object) object.shown = false end,
        IsShown = function(object) return object.shown end,
        Enable = function(object) object.enabled = true end,
        Disable = function(object) object.enabled = false end,
        CreateTexture = function() return CreateFrame("Texture") end,
        CreateFontString = function() return CreateFrame("FontString") end,
        SetHyperlink = function(object, link) tooltipItem = link end,
    }
    if methods[key] then return methods[key] end
    if string.find(key, "^[A-Z]") then return function() end end
    return nil
end
function CreateFrame() return setmetatable({ scripts = {}, shown = true }, Frame) end
function GetTime() return now end
function UnitName() return "Me" end
function GetItemInfo() return nil end
function IsShiftKeyDown() return nil end
function SetItemRef(link) clickedItem = link end
function SendChatMessage() error("guild notifications must not send chat") end
function SendAddonMessage() error("guild notifications must not share guild chat") end
UIParent = CreateFrame()
GameTooltip = CreateFrame()

dofile("HC-Tradeboard/Core.lua")
dofile("HC-Tradeboard/Network.lua")
dofile("HC-Tradeboard/GuildLoot.lua")
local TB = TradeBoard
TB.OpenWorldWhisper = function(self, name) openedWhisper = name end
local function link(id, name) return "|cff1eff00|Hitem:" .. id .. ":0:0:0|h[" .. name .. "]|h|r" end
local cloak = link(1, "Ancient Cloak of Agility")
local sphere = link(2, "Sorcerer Sphere of the Eagle")
local ring = link(3, "Widow's Kiss")

assert(not TB:CaptureGuildLootMessage("I looted " .. cloak, "Frank"), "ordinary loot chatter created a popup")
assert(not TB:CaptureGuildLootMessage("WTB " .. cloak, "Buyer"), "buy request created a giveaway")
assert(not TB:CaptureGuildLootMessage("Anyone need " .. cloak, "Me"), "own guild message created a popup")
assert(TB:CaptureGuildLootMessage("Anyone need anything? " .. cloak .. " 49+-", "Frank"), "screenshot offer was not detected")
assert(TB.GuildLoot.active.kind == "GIVE" and TB.GuildLoot.active.sender == "Frank", "offer metadata is incorrect")
assert(TB:CaptureGuildLootMessage(sphere, "Frank"), "item-only followup was not included")
assert(TB:CaptureGuildLootMessage(ring, "Frank"), "second item-only followup was not included")
assert(table.getn(TB.GuildLoot.active.links) == 3, "followups did not merge into active offer")
assert(not TB:CaptureGuildLootMessage(ring, "Frank"), "duplicate offer was not suppressed")
assert(not TB:CaptureGuildLootMessage(sphere, "Other"), "another sender inherited the offer context")
assert(not TB:CaptureGuildLootMessage("I crafted " .. link(4, "Free Action Potion"), "Crafter"), "item-name keyword triggered a giveaway")
assert(TB:CaptureGuildLootMessage("wTs " .. sphere .. " 2g", "Seller"), "case-insensitive sale was not detected")
assert(table.getn(TB.GuildLoot.queue) == 1, "second seller was not queued")

local frame = TB.GuildLoot.frame
this = frame.rows[1]
this.scripts.OnEnter()
assert(tooltipItem == "item:1:0:0:0", "hover did not show item tooltip")
this.scripts.OnClick()
assert(clickedItem == "item:1:0:0:0", "click did not open item")
frame.whisper.scripts.OnClick()
assert(openedWhisper == "Frank", "whisper action used wrong author")
frame.dismiss.scripts.OnClick()
assert(TB.GuildLoot.active.sender == "Seller", "dismiss did not advance queue")
now = now + 61
this = frame
frame.scripts.OnUpdate()
assert(not TB.GuildLoot.active and not frame.shown, "popup did not expire")
assert(not TB:CaptureGuildLootMessage(link(5, "Stale Followup"), "Frank"), "stale offer context accepted a followup")

TB:SetGuildLootEnabled(false)
assert(not TB:CaptureGuildLootMessage("FREE " .. cloak, "Frank"), "disabled notifications captured guild offers")
TB:SetGuildLootEnabled(true)
assert(TB:CaptureGuildLootMessage("FREE " .. cloak, "Frank"), "notifications did not re-enable")
assert(not TB:CaptureGuildLootMessage("Congrats!", "Frank"), "unrelated chatter created a popup")
assert(not TB:CaptureGuildLootMessage(sphere, "Frank"), "unrelated chatter did not end continuation")
TB:ClearGuildLoot()
assert(not TB:CaptureGuildLootMessage("Anyone want anything?", "Frank"), "plain introduction created an empty offer")
assert(TB:CaptureGuildLootMessage(sphere, "Frank"), "plain introduction did not establish continuation")

TB:ClearGuildLoot()
local i
for i = 1, 140 do TB:CaptureGuildLootMessage("WTS " .. link(i, "Item " .. i), "Seller" .. i) end
assert(table.getn(TB.GuildLoot.queue) <= 20, "offer queue is unbounded")
assert(table.getn(TB.GuildLoot.recent) <= 100, "duplicate cache is unbounded")
assert(table.getn(TB.GuildLoot.contexts) <= 32, "followup context is unbounded")
TB:ClearGuildLoot()
print("HC TradeBoard guild loot smoke test passed")
