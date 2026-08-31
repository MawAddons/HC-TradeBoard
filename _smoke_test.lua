table.getn = function(value)
    return #value
end
string.gfind = string.gmatch
math.mod = function(left, right)
    return left % right
end

local apiTime = 100
local wallTime = 100000
function UnitLevel()
    return 60
end
function UnitName()
    return "Receiver"
end
function GetGuildInfo()
    return "Receiver Guild"
end
function GetTime()
    return apiTime
end
function time()
    return wallTime
end
function GetItemInfo()
    return nil
end

assert(loadfile("TradeBoard/Core.lua"))()
assert(loadfile("TradeBoard/Network.lua"))()

TradeBoardDB = {}

local source = {
    id = "7",
    itemLink = "|cff0070dd|Hitem:100:0:0:0|h[Test Item]|h|r",
    texture = "Interface\\Icons\\INV_Shield_05",
    quality = 3,
    requiredLevel = 40,
    itemLevel = 45,
    quantity = 2,
    unitPrice = 12345,
    traderLevel = 60,
    guild = "Crafters United",
    orderType = "SELL",
    category = "Armor",
    tags = { Plate = 1 },
}
local message = TradeBoard:BuildListingMessage(source)
assert(#message <= 250)
local fields = {}
for value in string.gmatch(message .. "~", "(.-)~") do
    table.insert(fields, value)
end
TradeBoard:HandleListingMessage(fields, "Seller")
assert(#TradeBoard.Listings == 1)
assert(TradeBoard.Listings[1].guild == "Crafters United")
assert(TradeBoard.Listings[1].texture == source.texture)
assert(TradeBoard.Listings[1].online == 1)
assert(TradeBoard.Listings[1].lastSeenAt == wallTime)

local serviceMessage = TradeBoard.PROTOCOL .. "~S~Alchemy~300~300~Flasks~Crafters United"
local serviceFields = {}
for value in string.gmatch(serviceMessage .. "~", "(.-)~") do
    table.insert(serviceFields, value)
end
TradeBoard:HandleServiceMessage(serviceFields, "Seller")
assert(#TradeBoard.Services == 1)
assert(TradeBoard.Services[1].guild == "Crafters United")

apiTime = 1000
wallTime = 114400
TradeBoard:ExpireRemoteData()
assert(#TradeBoard.Listings == 1)
assert(#TradeBoard.Services == 1)
assert(not TradeBoard.Listings[1].online)
assert(not TradeBoard.Services[1].online)
assert(TradeBoard:FormatLastSeen(100000) == "4h")
assert(#TradeBoardDB.remoteListings == 1)
assert(#TradeBoardDB.remoteServices == 1)

TradeBoard.Listings = {}
TradeBoard.ListingIndex = {}
TradeBoard.Services = {}
TradeBoard.ServiceIndex = {}
TradeBoard:LoadRemoteCache()
assert(#TradeBoard.Listings == 1 and not TradeBoard.Listings[1].online)
assert(#TradeBoard.Services == 1 and not TradeBoard.Services[1].online)
assert(TradeBoard.Listings[1].guild == "Crafters United")

print("TradeBoard 0.4.0 persistence smoke test passed")
