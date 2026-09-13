TradeBoard = {}

TradeBoard.VERSION = "0.5.2"
TradeBoard.DISPLAY_TITLE = "HC TradeBoard"
TradeBoard.COLORED_TITLE = "|cffb8c0ccHC|r |cffa335eeTradeBoard|r"
TradeBoard.MAX_VISIBLE_ROWS = 7
TradeBoard.MAX_MY_LISTING_ROWS = 5
TradeBoard.CHANNEL_NAME = "TradeBoard"
TradeBoard.PROTOCOL = "TB1"
TradeBoard.REMOTE_TTL = 600
TradeBoard.ANNOUNCE_INTERVAL = 240
TradeBoard.AUTO_SYNC_INTERVAL = 60
TradeBoard.PROFESSION_UPDATE_DEBOUNCE = 45
TradeBoard.MAX_WORLD_LOGS = 500
TradeBoard.MAX_WORLD_ROWS = 8
TradeBoard.WHO_LOOKUP_INTERVAL = 8

TradeBoard.Listings = {}
TradeBoard.ListingIndex = {}
TradeBoard.MyListings = {}
TradeBoard.Chains = {}
TradeBoard.Services = {}
TradeBoard.ServiceIndex = {}
TradeBoard.MyServices = {}

TradeBoard.ProfessionNames = {
    "Alchemy",
    "Blacksmithing",
    "Enchanting",
    "Engineering",
    "Herbalism",
    "Leatherworking",
    "Mining",
    "Skinning",
    "Tailoring",
    "Cooking",
    "First Aid",
}

TradeBoard.GuildSigilTextures = {
    "Interface\\Icons\\INV_Shield_04",
    "Interface\\Icons\\INV_Shield_05",
    "Interface\\Icons\\INV_Shield_06",
    "Interface\\Icons\\INV_Shield_07",
    "Interface\\Icons\\INV_Shield_08",
    "Interface\\Icons\\INV_Shield_09",
    "Interface\\Icons\\INV_Shield_10",
    "Interface\\Icons\\INV_Shield_11",
}

TradeBoard.Quality = {
    [1] = { name = "Common", r = 1.00, g = 1.00, b = 1.00, hex = "ffffffff" },
    [2] = { name = "Uncommon / Magic", r = 0.12, g = 1.00, b = 0.12, hex = "ff1eff00" },
    [3] = { name = "Rare", r = 0.20, g = 0.50, b = 1.00, hex = "ff3399ff" },
    [4] = { name = "Epic", r = 0.70, g = 0.30, b = 1.00, hex = "ffb048ff" },
    [5] = { name = "Legendary", r = 1.00, g = 0.50, b = 0.05, hex = "ffff8000" },
}

TradeBoard.Categories = {
    "All Items",
    "Weapons",
    "Armor",
    "Containers",
    "Consumables",
    "Trade Goods",
    "Recipes",
    "Projectiles",
    "Quivers",
    "Miscellaneous",
}

TradeBoard.Subcategories = {
    Weapons = { "2H", "1H", "Swords", "Axe", "Maces", "Daggers", "Staves", "Fists", "Ranged" },
    Armor = { "Cloth", "Leather", "Mail", "Plate", "Shields" },
}

TradeBoard.State = {
    activeTab = "Browse",
    category = "All Items",
    categoryView = "root",
    subCategory = nil,
    myLevelRange = 1,
    onlineOnly = 1,
    listingType = "ALL",
    levelType = "required",
    minLevel = 0,
    maxLevel = 0,
    search = "",
    rarities = {
        [1] = 1,
        [2] = 1,
        [3] = 1,
        [4] = 1,
        [5] = 1,
    },
    browseOffset = 0,
    selectedListing = nil,
    myListingOffset = 0,
    selectedChain = nil,
    chainOffset = 0,
    selectedMyListing = nil,
    profession = "All Services",
    professionOffset = 0,
    selectedService = nil,
    guildFilter = nil,
    sortKey = "unitPrice",
    sortAscending = 1,
    worldOffset = 0,
    worldSearch = "",
    worldType = "ALL",
}

function TradeBoard:GetPlayerLevel()
    local level = tonumber(UnitLevel("player"))
    if level and level > 0 and (not self.PlayerLevel or level > self.PlayerLevel) then
        self.PlayerLevel = level
    end
    return self.PlayerLevel or 1
end

function TradeBoard:SetPlayerLevel(level)
    level = tonumber(level)
    if level and level > 0 then
        self.PlayerLevel = level
    end
    return self:GetPlayerLevel()
end

function TradeBoard:GetTraderRange()
    local level = self:GetPlayerLevel()
    local low = level - 5
    local high = level + 5
    if low < 1 then
        low = 1
    end
    if high > 60 then
        high = 60
    end
    return low, high
end

function TradeBoard:GetTraderRangeLabel()
    local low, high = self:GetTraderRange()
    return "My level range (" .. low .. "-" .. high .. ")"
end

function TradeBoard:GetWallTime()
    if type(time) == "function" then
        local now = tonumber(time())
        if now and now > 0 then
            return now
        end
    end
    return math.floor(GetTime())
end

function TradeBoard:FormatLastSeen(timestamp)
    timestamp = tonumber(timestamp)
    if not timestamp then
        return "unknown"
    end
    local elapsed = self:GetWallTime() - timestamp
    if elapsed < 0 then
        elapsed = 0
    end
    if elapsed < 60 then
        return "<1m"
    elseif elapsed < 3600 then
        return math.floor(elapsed / 60) .. "m"
    elseif elapsed < 86400 then
        return math.floor(elapsed / 3600) .. "h"
    end
    return math.floor(elapsed / 86400) .. "d"
end

function TradeBoard:GetPlayerGuildName()
    local guildName = GetGuildInfo("player")
    return guildName or ""
end

function TradeBoard:IsWorldChannel(channelName)
    local name = string.lower(channelName or "")
    name = string.gsub(name, "^%d+%.%s*", "")
    return name == "world"
end

function TradeBoard:GetWorldMessageType(message)
    local padded = " " .. string.upper(message or "") .. " "
    if string.find(padded, "[%s%p]WTB[%s%p]") then return "WTB" end
    if string.find(padded, "[%s%p]WTS[%s%p]") then return "WTS" end
    if string.find(padded, "[%s%p]LFW[%s%p]") then return "LFW" end
    return nil
end

function TradeBoard:ExtractWorldItemLinks(message)
    local links = {}
    local seen = {}
    local link
    for link in string.gfind(message or "", "(|c%x+|Hitem:[^|]+|h%[[^]]+%]|h|r)") do
        if not seen[link] then seen[link] = 1; table.insert(links, link) end
    end
    return links
end

function TradeBoard:GetWorldMessageSegments(message)
    local segments = {}
    local text = message or ""
    local cursor = 1
    while cursor <= string.len(text) do
        local first, last, link = string.find(text, "(|c%x+|Hitem:[^|]+|h%[[^]]+%]|h|r)", cursor)
        if not first then
            table.insert(segments, { text = string.sub(text, cursor) })
            break
        end
        if first > cursor then
            table.insert(segments, { text = string.sub(text, cursor, first - 1) })
        end
        table.insert(segments, { text = link, itemLink = link })
        cursor = last + 1
    end
    if table.getn(segments) == 0 then table.insert(segments, { text = text }) end
    return segments
end

function TradeBoard:OpenWorldWhisper(name)
    if not name or name == "" or not ChatFrame_OpenChat then return end
    ChatFrame_OpenChat("/w " .. name .. " ")
    self:SetStatus("Whisper opened for " .. name .. ".")
end

function TradeBoard:OpenWorldGuildWho(guild)
    if not guild or guild == "" or not SendWho then return end
    guild = string.gsub(guild, '"', "")
    self.PendingWhoName = nil
    self.addonWhoShouldClose = nil
    self.closeWhoOnNextUpdate = nil
    if SetWhoToUI then SetWhoToUI(1) end
    SendWho('g-"' .. guild .. '"')
    self:SetStatus("Who search sent for <" .. guild .. ">.")
end

function TradeBoard:GetKnownTraderInfo(name)
    local key = string.lower(name or "")
    if key == string.lower(UnitName("player") or "") then
        return self:GetPlayerLevel(), self:GetPlayerGuildName()
    end
    if TradeBoardDB and TradeBoardDB.worldPeople and TradeBoardDB.worldPeople[key] then
        local person = TradeBoardDB.worldPeople[key]
        return tonumber(person.level), person.guild or ""
    end
    if self.Network and self.Network.peers and self.Network.peers[key] then
        local peer = self.Network.peers[key]
        if peer.level or (peer.guild and peer.guild ~= "") then
            return tonumber(peer.level), peer.guild or ""
        end
    end
    local i
    for i = 1, table.getn(self.Listings) do
        local listing = self.Listings[i]
        if string.lower(listing.trader or "") == key then return tonumber(listing.traderLevel), listing.guild or "" end
    end
    for i = 1, table.getn(self.Services) do
        local service = self.Services[i]
        if string.lower(service.trader or "") == key then return tonumber(service.traderLevel), service.guild or "" end
    end
    return nil, ""
end

function TradeBoard:InitializeWorldLog()
    if not TradeBoardDB then TradeBoardDB = {} end
    if type(TradeBoardDB.worldLog) ~= "table" then TradeBoardDB.worldLog = {} end
    if type(TradeBoardDB.worldPeople) ~= "table" then TradeBoardDB.worldPeople = {} end
    self.WorldLog = TradeBoardDB.worldLog
    self.WhoQueue = self.WhoQueue or {}
    local i
    for i = 1, table.getn(self.WorldLog) do
        local entry = self.WorldLog[i]
        if type(entry) == "table" and type(entry.items) ~= "table" then
            entry.items = self:ExtractWorldItemLinks(entry.message)
        end
    end
    while table.getn(self.WorldLog) > self.MAX_WORLD_LOGS do table.remove(self.WorldLog, 1) end
end

function TradeBoard:QueueWhoLookup(name)
    if not name or name == "" then return end
    local key = string.lower(name)
    if TradeBoardDB.worldPeople[key] or self.PendingWhoName == key then return end
    local i
    for i = 1, table.getn(self.WhoQueue) do if string.lower(self.WhoQueue[i]) == key then return end end
    table.insert(self.WhoQueue, name)
end

function TradeBoard:CaptureWorldMessage(message, sender, channelName)
    if not self:IsWorldChannel(channelName) then return end
    local kind = self:GetWorldMessageType(message)
    if not kind then return end
    self:InitializeWorldLog()
    local level, guild = self:GetKnownTraderInfo(sender)
    local entry = {
        timestamp = self:GetWallTime(), type = kind, sender = sender or "Unknown",
        level = level, guild = guild or "", message = message or "",
        items = self:ExtractWorldItemLinks(message),
    }
    table.insert(self.WorldLog, entry)
    while table.getn(self.WorldLog) > self.MAX_WORLD_LOGS do table.remove(self.WorldLog, 1) end
    if not level or guild == "" then self:QueueWhoLookup(sender) end
    if self.UpdateWorldLog then self:UpdateWorldLog() end
end

function TradeBoard:RememberWorldPerson(name, guild, level)
    if not name or name == "" then return end
    if not self.WorldLog or not TradeBoardDB or not TradeBoardDB.worldPeople then self:InitializeWorldLog() end
    local key = string.lower(name)
    TradeBoardDB.worldPeople[key] = { guild = guild or "", level = tonumber(level), seenAt = self:GetWallTime() }
    local i
    for i = 1, table.getn(self.WorldLog or {}) do
        local entry = self.WorldLog[i]
        if string.lower(entry.sender or "") == key then
            entry.guild = guild or entry.guild or ""
            entry.level = tonumber(level) or entry.level
        end
    end
end

function TradeBoard:GetFilteredWorldLog()
    local result = {}
    local needle = string.lower(self.State.worldSearch or "")
    local i
    for i = 1, table.getn(self.WorldLog or {}) do
        local entry = self.WorldLog[i]
        local typeMatches = self.State.worldType == "ALL" or entry.type == self.State.worldType
        local text = string.lower((entry.sender or "") .. " " .. (entry.guild or "") .. " " .. (entry.message or ""))
        if typeMatches and (needle == "" or string.find(text, needle, 1, 1)) then table.insert(result, entry) end
    end
    return result
end

function TradeBoard:GetGuildSigilTexture(guildName)
    local normalized = string.lower(guildName or "")
    local count = table.getn(self.GuildSigilTextures)
    local hash = 0
    local i
    for i = 1, string.len(normalized) do
        hash = math.mod((hash * 33) + string.byte(normalized, i), count)
    end
    return self.GuildSigilTextures[hash + 1]
end

function TradeBoard:FormatMoney(copper)
    local gold = math.floor(copper / 10000)
    local silver = math.floor(math.mod(copper, 10000) / 100)
    local coins = math.mod(copper, 100)
    local result = ""

    if gold > 0 then
        result = gold .. "g "
    end
    if silver > 0 or gold > 0 then
        result = result .. silver .. "s "
    end
    return result .. coins .. "c"
end

function TradeBoard:ColorText(text, quality)
    local info = self.Quality[quality] or self.Quality[1]
    return "|c" .. info.hex .. text .. "|r"
end

function TradeBoard:NormalizeQuality(quality)
    quality = tonumber(quality) or 1
    if quality < 1 then
        return 1
    elseif quality > 5 then
        return 5
    end
    return quality
end

function TradeBoard:GetListingItemLink(listing)
    if listing and listing.itemLink then
        return listing.itemLink
    end
    if not listing or not listing.itemID then
        return nil
    end
    local info = self.Quality[listing.quality] or self.Quality[1]
    return "|c" .. info.hex .. "|Hitem:" .. listing.itemID .. ":0:0:0|h[" .. listing.name .. "]|h|r"
end

function TradeBoard:GetListingTooltipHyperlink(listing)
    local link = self:GetListingItemLink(listing)
    if not link then
        return nil
    end
    local _, _, hyperlink = string.find(link, "|H([^|]+)|h")
    if hyperlink then
        return hyperlink
    end
    if string.find(link, "^item:") then
        return link
    end
    return nil
end

function TradeBoard:ListingHasTag(listing, tag)
    if tag == "Ranged" and listing.tags then
        if listing.tags.Ranged or listing.tags["Ranged (Bow/Xbow/Gun)"] or listing.tags["Ranged (Box/Xbox/Gun)"] then
            return 1
        end
    end
    return listing.tags and listing.tags[tag]
end

function TradeBoard:IsListingVisible(listing)
    local state = self.State

    if state.category ~= "All Items" and listing.category ~= state.category then
        return nil
    end

    if state.subCategory and not self:ListingHasTag(listing, state.subCategory) then
        return nil
    end

    if not state.rarities[listing.quality] then
        return nil
    end

    if state.listingType ~= "ALL" and listing.orderType ~= state.listingType then
        return nil
    end

    if state.onlineOnly and not listing.online then
        return nil
    end

    if state.myLevelRange then
        local low, high = self:GetTraderRange()
        if listing.traderLevel < low or listing.traderLevel > high then
            return nil
        end
    end

    local level = listing.requiredLevel
    if state.levelType == "item" then
        level = listing.itemLevel
    end

    if state.minLevel and state.minLevel > 0 and level < state.minLevel then
        return nil
    end
    if state.maxLevel and state.maxLevel > 0 and level > state.maxLevel then
        return nil
    end

    if state.search and state.search ~= "" then
        local needle = string.lower(state.search)
        local haystack = string.lower(listing.name)
        if not string.find(haystack, needle, 1, 1) then
            return nil
        end
    end

    return 1
end

function TradeBoard:GetFilteredListings()
    local filtered = {}
    local count = table.getn(self.Listings)
    local i

    for i = 1, count do
        if self:IsListingVisible(self.Listings[i]) then
            table.insert(filtered, self.Listings[i])
        end
    end

    local sortKey = self.State.sortKey
    local ascending = self.State.sortAscending

    table.sort(filtered, function(a, b)
        local aValue = a[sortKey]
        local bValue = b[sortKey]

        if sortKey == "name" or sortKey == "trader" or sortKey == "guild" then
            aValue = string.lower(aValue or "")
            bValue = string.lower(bValue or "")
        elseif sortKey == "online" then
            aValue = a.online and 1 or 0
            bValue = b.online and 1 or 0
        else
            aValue = aValue or 0
            bValue = bValue or 0
        end

        if aValue == bValue then
            local aName = string.lower(a.name or "")
            local bName = string.lower(b.name or "")
            if aName == bName then
                return string.lower(a.trader or "") < string.lower(b.trader or "")
            end
            return aName < bName
        end

        if ascending then
            return aValue < bValue
        end
        return aValue > bValue
    end)

    return filtered
end

function TradeBoard:SetSort(sortKey)
    if self.State.sortKey == sortKey then
        if self.State.sortAscending then
            self.State.sortAscending = nil
        else
            self.State.sortAscending = 1
        end
    else
        self.State.sortKey = sortKey
        self.State.sortAscending = 1
    end
    self.State.browseOffset = 0
end

function TradeBoard:ResetFilters()
    local state = self.State
    state.category = "All Items"
    state.categoryView = "root"
    state.subCategory = nil
    state.myLevelRange = nil
    state.onlineOnly = nil
    state.listingType = "ALL"
    state.levelType = "required"
    state.minLevel = 0
    state.maxLevel = 0
    state.search = ""
    state.browseOffset = 0

    local quality
    for quality = 1, 5 do
        state.rarities[quality] = 1
    end
end

function TradeBoard:SetStatus(text)
    if self.Frames and self.Frames.statusText then
        self.Frames.statusText:SetText(text)
    end
end
