local TB = TradeBoard

TB.Frames = {}

local MAIN_BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = 1,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 10, right = 10, top = 10, bottom = 10 },
}

local PANEL_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = 1,
    tileSize = 16,
    edgeSize = 14,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local GOLD_R = 0.86
local GOLD_G = 0.66
local GOLD_B = 0.24

local function CreatePanel(parent, width, height)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetWidth(width)
    panel:SetHeight(height)
    panel:SetBackdrop(PANEL_BACKDROP)
    panel:SetBackdropColor(0.025, 0.025, 0.025, 0.96)
    panel:SetBackdropBorderColor(0.42, 0.34, 0.18, 1)
    return panel
end

local function CreateText(parent, text, font, r, g, b)
    local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    label:SetText(text or "")
    if r then
        label:SetTextColor(r, g, b)
    end
    return label
end

local function CreateButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(height)
    button:SetBackdrop(PANEL_BACKDROP)
    button:SetBackdropColor(0.18, 0.045, 0.018, 1)
    button:SetBackdropBorderColor(0.62, 0.40, 0.14, 1)

    local fill = button:CreateTexture(nil, "BACKGROUND")
    fill:SetTexture(0.18, 0.045, 0.018, 0.95)
    fill:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
    fill:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)
    button.fill = fill

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(0.75, 0.45, 0.12, 0.20)
    highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
    highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)

    local label = CreateText(button, text, "GameFontNormal")
    label:SetPoint("CENTER", button, "CENTER", 0, 0)
    label:SetTextColor(1.00, 0.82, 0.24)
    button.label = label

    return button
end

local function SetButtonSelected(button, selected)
    if selected then
        button:SetBackdropColor(0.26, 0.10, 0.02, 1)
        button:SetBackdropBorderColor(0.95, 0.66, 0.18, 1)
        button.label:SetTextColor(1.00, 0.84, 0.26)
    else
        button:SetBackdropColor(0.055, 0.055, 0.055, 1)
        button:SetBackdropBorderColor(0.34, 0.28, 0.16, 1)
        button.label:SetTextColor(0.83, 0.74, 0.58)
    end
end

local function CreateCheckButton(parent, text, width, checked, callback, r, g, b)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(24)
    button.checked = checked

    local box = button:CreateTexture(nil, "ARTWORK")
    box:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
    box:SetWidth(24)
    box:SetHeight(24)
    box:SetPoint("LEFT", button, "LEFT", 0, 0)
    button.box = box

    local check = button:CreateTexture(nil, "OVERLAY")
    check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    check:SetWidth(24)
    check:SetHeight(24)
    check:SetPoint("CENTER", box, "CENTER", 0, 0)
    button.check = check

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(1.00, 0.78, 0.20, 0.20)
    highlight:SetWidth(18)
    highlight:SetHeight(18)
    highlight:SetPoint("CENTER", box, "CENTER", 0, 0)

    local label = CreateText(button, text, "GameFontHighlightSmall", r or 0.90, g or 0.86, b or 0.76)
    label:SetPoint("LEFT", box, "RIGHT", 2, 1)
    label:SetJustifyH("LEFT")
    button.label = label

    function button:SetCheckedValue(value)
        self.checked = value
        if value then
            self.check:Show()
        else
            self.check:Hide()
        end
    end

    button:SetCheckedValue(checked)
    button:SetScript("OnClick", function()
        if this.checked then
            this:SetCheckedValue(nil)
        else
            this:SetCheckedValue(1)
        end
        if callback then
            callback(this.checked)
        end
    end)

    return button
end

local function CreateEditBox(parent, width, height, text)
    local edit = CreateFrame("EditBox", nil, parent)
    edit:SetWidth(width)
    edit:SetHeight(height)
    edit:SetAutoFocus(nil)
    edit:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
    edit:SetTextColor(0.95, 0.90, 0.78)
    edit:SetJustifyH("LEFT")
    edit:SetBackdrop(PANEL_BACKDROP)
    edit:SetBackdropColor(0.01, 0.01, 0.01, 1)
    edit:SetBackdropBorderColor(0.35, 0.30, 0.20, 1)
    if edit.SetTextInsets then
        edit:SetTextInsets(7, 7, 0, 0)
    end
    edit:SetText(text or "")
    edit:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        TB:Close()
    end)
    return edit
end

local function CreateHeading(parent, text)
    local heading = CreateText(parent, text, "GameFontNormal", 1.00, 0.78, 0.24)
    heading:SetPoint("TOP", parent, "TOP", 0, -9)
    return heading
end

function TB:OnMainFrameHidden()
    self.bagPickMode = nil
    if self.Frames.chainEditor then
        self.Frames.chainEditor:Hide()
    end
    if self.Frames.professionEditor then
        self.Frames.professionEditor:Hide()
    end
    if self.HideBrowseListingTooltips then
        self:HideBrowseListingTooltips()
    else
        GameTooltip:Hide()
    end
end

function TB:Close()
    local frame = self.Frames and self.Frames.main
    if not frame then
        return
    end
    frame:StopMovingOrSizing()
    frame:Hide()
end

function TB:CreateMainFrame()
    local frame = CreateFrame("Frame", "TradeBoardFrame", UIParent)
    frame:SetWidth(960)
    frame:SetHeight(680)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(1)
    if frame.SetClampedToScreen then
        frame:SetClampedToScreen(1)
    end
    frame:EnableMouse(1)
    frame:SetBackdrop(MAIN_BACKDROP)
    frame:SetBackdropColor(0.018, 0.018, 0.018, 0.98)
    frame:SetBackdropBorderColor(0.54, 0.42, 0.18, 1)
    frame:SetScript("OnHide", function()
        TB:OnMainFrameHidden()
    end)
    self.Frames.main = frame

    local header = CreateFrame("Frame", nil, frame)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -13)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -13)
    header:SetHeight(36)
    header:EnableMouse(1)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function()
        TradeBoardFrame:StartMoving()
    end)
    header:SetScript("OnDragStop", function()
        TradeBoardFrame:StopMovingOrSizing()
    end)

    local headerBg = header:CreateTexture(nil, "BACKGROUND")
    headerBg:SetTexture(0.025, 0.025, 0.025, 1)
    headerBg:SetAllPoints(header)

    local title = CreateText(header, self.COLORED_TITLE, "GameFontNormalLarge", 1.00, 1.00, 1.00)
    title:SetPoint("CENTER", header, "CENTER", 0, 1)

    local version = CreateText(header, "v" .. self.VERSION, "GameFontDisableSmall", 0.55, 0.50, 0.40)
    version:SetPoint("LEFT", header, "LEFT", 8, 0)

    -- Keep the emergency close control outside the draggable header so even a
    -- small mouse movement cannot turn the click into a header drag.
    local close = CreateButton(frame, "X", 42, 32)
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -15)
    close:SetFrameLevel(header:GetFrameLevel() + 10)
    close:RegisterForClicks("LeftButtonDown")
    close:SetScript("OnClick", function()
        TB:Close()
    end)
    self.Frames.closeButton = close

    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -94)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 48)
    self.Frames.content = content

    self:CreateTabs(frame)
    self:CreateBrowsePane(content)
    self:CreateMyListingsPane(content)
    self:CreateTradeChainsPane(content)
    self:CreateProfessionsPane(content)
    self:CreateWorldLogPane(content)

    local statusBar = CreateFrame("Frame", nil, frame)
    statusBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 15)
    statusBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 15)
    statusBar:SetHeight(24)
    statusBar:SetBackdrop(PANEL_BACKDROP)
    statusBar:SetBackdropColor(0.025, 0.025, 0.025, 1)
    statusBar:SetBackdropBorderColor(0.30, 0.25, 0.15, 1)

    local statusText = CreateText(statusBar, "Ready.", "GameFontHighlightSmall", 0.70, 0.67, 0.58)
    statusText:SetPoint("LEFT", statusBar, "LEFT", 8, 0)
    statusText:SetWidth(510)
    statusText:SetJustifyH("LEFT")
    self.Frames.statusText = statusText

    local networkText = CreateText(statusBar, "Network: offline", "GameFontHighlightSmall", 0.70, 0.35, 0.30)
    networkText:SetPoint("RIGHT", statusBar, "RIGHT", -8, 0)
    networkText:SetWidth(390)
    networkText:SetJustifyH("RIGHT")
    self.Frames.networkText = networkText

    table.insert(UISpecialFrames, "TradeBoardFrame")
end

function TB:SetMinimapButtonAngle(angle)
    if not angle then
        angle = -2.52
    end
    self.minimapAngle = angle
    if self.Frames.minimapButton then
        local radius = 84
        self.Frames.minimapButton:ClearAllPoints()
        self.Frames.minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
    end
    if TradeBoardDB then
        TradeBoardDB.minimapAngle = angle
    end
end

function TB:UpdateMinimapButtonFromCursor()
    local scale = Minimap:GetEffectiveScale()
    local cursorX, cursorY = GetCursorPosition()
    local centerX, centerY = Minimap:GetCenter()
    if not scale or scale == 0 or not centerX or not centerY then
        return
    end
    cursorX = cursorX / scale
    cursorY = cursorY / scale
    self:SetMinimapButtonAngle(math.atan2(cursorY - centerY, cursorX - centerX))
end

function TB:CreateMinimapButton()
    local button = CreateFrame("Button", "TradeBoardMinimapButton", Minimap)
    button:SetWidth(33)
    button:SetHeight(33)
    button:SetPoint("CENTER", Minimap, "CENTER", -70, -50)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetWidth(24)
    background:SetHeight(24)
    background:SetPoint("CENTER", button, "CENTER", 0, 0)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetWidth(52)
    border:SetHeight(52)
    border:SetPoint("CENTER", button, "CENTER", 10, -9)

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetWidth(32)
    highlight:SetHeight(32)
    highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
    highlight:SetBlendMode("ADD")

    button:SetScript("OnClick", function()
        if this.wasDragged then
            this.wasDragged = nil
            return
        end
        TB:Toggle()
    end)
    button:SetScript("OnDragStart", function()
        if IsControlKeyDown() then
            this.dragging = 1
            this:SetScript("OnUpdate", function()
                TB:UpdateMinimapButtonFromCursor()
            end)
        end
    end)
    button:SetScript("OnDragStop", function()
        if this.dragging then
            TB:UpdateMinimapButtonFromCursor()
            this.dragging = nil
            this.wasDragged = 1
            this:SetScript("OnUpdate", nil)
        end
    end)
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText(TB.COLORED_TITLE, 1.00, 1.00, 1.00)
        GameTooltip:AddLine("Left-click to open or close.", 0.88, 0.84, 0.75)
        GameTooltip:AddLine("Ctrl + left-drag to move.", 0.88, 0.84, 0.75)
        GameTooltip:AddLine("You can also type /tb.", 0.65, 0.72, 0.90)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.Frames.minimapButton = button
end

function TB:CreateTabs(parent)
    self.Frames.tabs = {}
    local names = { "Browse", "My Listings", "Trade Chains", "Professions", "World Trade" }
    local widths = { 112, 132, 132, 124, 148 }
    local x = 24
    local i

    for i = 1, table.getn(names) do
        local tabName = names[i]
        local tab = CreateButton(parent, tabName, widths[i], 34)
        tab:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -55)
        tab:SetScript("OnClick", function()
            TB:SetActiveTab(tabName)
        end)
        self.Frames.tabs[tabName] = tab
        x = x + widths[i] + 6
    end
end

function TB:CreateBrowsePane(parent)
    local pane = CreateFrame("Frame", nil, parent)
    pane:SetAllPoints(parent)
    self.Frames.browsePane = pane

    local searchPanel = CreatePanel(pane, 928, 42)
    searchPanel:SetPoint("TOPLEFT", pane, "TOPLEFT", 0, 0)

    local searchField = CreateEditBox(searchPanel, 900, 28, "")
    searchField:SetPoint("CENTER", searchPanel, "CENTER", 0, 0)
    searchField:SetMaxLetters(60)
    self.Frames.searchField = searchField

    local placeholder = CreateText(searchPanel, "Search items...", "GameFontDisable", 0.50, 0.48, 0.44)
    placeholder:SetPoint("LEFT", searchField, "LEFT", 8, 0)
    self.Frames.searchPlaceholder = placeholder

    searchField:SetScript("OnTextChanged", function()
        if this:GetText() == "" then
            TB.Frames.searchPlaceholder:Show()
        else
            TB.Frames.searchPlaceholder:Hide()
        end
    end)
    searchField:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        TB:UpdateBrowse()
    end)

    self:CreateCategoryPanel(pane)
    self:CreateFilterPanels(pane)
    self:CreateResultsPanel(pane)

    local countText = CreateText(pane, "0 matching listings", "GameFontHighlightSmall", 0.83, 0.77, 0.65)
    countText:SetPoint("BOTTOMLEFT", pane, "BOTTOMLEFT", 185, 8)
    self.Frames.resultCount = countText

    local listButton = CreateButton(pane, "List an Item", 126, 34)
    listButton:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", 0, 0)
    listButton:SetScript("OnClick", function()
        TB:SetActiveTab("My Listings")
        TB:SetStatus("Choose an item from your bags, then set quantity and unit price.")
    end)

    local addFriendButton = CreateButton(pane, "Add Friend", 108, 34)
    addFriendButton:SetPoint("RIGHT", listButton, "LEFT", -8, 0)
    addFriendButton:SetScript("OnClick", function()
        local listing = TB.State.selectedListing
        if listing then
            AddFriend(listing.trader)
            TB:SetStatus("Friend request sent for " .. listing.trader .. ".")
        else
            TB:SetStatus("Select a listing before adding its trader.")
        end
    end)

    local whisperButton = CreateButton(pane, "Whisper", 100, 34)
    whisperButton:SetPoint("RIGHT", addFriendButton, "LEFT", -8, 0)
    whisperButton:SetScript("OnClick", function()
        local listing = TB.State.selectedListing
        if listing then
            ChatFrame_OpenChat("/w " .. listing.trader .. " ")
            TB:SetStatus("Whisper opened for " .. listing.trader .. ".")
        else
            TB:SetStatus("Select a listing before whispering its trader.")
        end
    end)
end

function TB:CreateCategoryPanel(parent)
    local panel = CreatePanel(parent, 170, 438)
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -50)
    self.Frames.categoryHeading = CreateHeading(panel, "Categories")
    self.Frames.categoryPanel = panel
    self.Frames.categoryButtons = {}

    local i
    for i = 1, 11 do
        local button = CreateButton(panel, "", 150, 30)
        button:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -34 - ((i - 1) * 35))
        button.label:ClearAllPoints()
        button.label:SetPoint("LEFT", button, "LEFT", 10, 0)
        button.label:SetJustifyH("LEFT")
        button:SetScript("OnClick", function()
            local entry = this.categoryEntry
            if not entry then
                return
            end
            if entry.kind == "back" then
                TB.State.categoryView = "root"
            elseif entry.kind == "parent" then
                TB.State.category = entry.name
                TB.State.subCategory = nil
                TB.State.categoryView = entry.name
            elseif entry.kind == "allParent" then
                TB.State.category = entry.parent
                TB.State.subCategory = nil
            elseif entry.kind == "sub" then
                TB.State.category = entry.parent
                TB.State.subCategory = entry.name
            else
                TB.State.category = entry.name
                TB.State.subCategory = nil
            end
            TB.State.browseOffset = 0
            TB:UpdateBrowse()
        end)
        self.Frames.categoryButtons[i] = button
    end
    self:RefreshCategoryPanel()
end

function TB:RefreshCategoryPanel()
    local state = self.State
    local entries = {}
    local i

    if state.categoryView ~= "root" and self.Subcategories[state.categoryView] then
        local parent = state.categoryView
        self.Frames.categoryHeading:SetText(parent)
        table.insert(entries, { label = "< Categories", kind = "back" })
        table.insert(entries, { label = "All " .. parent, kind = "allParent", parent = parent })
        for i = 1, table.getn(self.Subcategories[parent]) do
            table.insert(entries, { label = self.Subcategories[parent][i], name = self.Subcategories[parent][i], kind = "sub", parent = parent })
        end
    else
        state.categoryView = "root"
        self.Frames.categoryHeading:SetText("Categories")
        for i = 1, table.getn(self.Categories) do
            local category = self.Categories[i]
            if self.Subcategories[category] then
                table.insert(entries, { label = category .. "  >", name = category, kind = "parent" })
            else
                table.insert(entries, { label = category, name = category, kind = "category" })
            end
        end
    end

    for i = 1, table.getn(self.Frames.categoryButtons) do
        local button = self.Frames.categoryButtons[i]
        local entry = entries[i]
        if entry then
            button.categoryEntry = entry
            button.label:SetText(entry.label)
            local selected = nil
            if entry.kind == "category" then
                selected = state.category == entry.name and not state.subCategory
            elseif entry.kind == "parent" then
                selected = state.category == entry.name
            elseif entry.kind == "allParent" then
                selected = state.category == entry.parent and not state.subCategory
            elseif entry.kind == "sub" then
                selected = state.category == entry.parent and state.subCategory == entry.name
            end
            SetButtonSelected(button, selected)
            button:Show()
        else
            button.categoryEntry = nil
            button:Hide()
        end
    end
end

function TB:CreateFilterPanels(parent)
    local trader = CreatePanel(parent, 198, 150)
    trader:SetPoint("TOPLEFT", parent, "TOPLEFT", 178, -50)
    CreateHeading(trader, "Trader")

    local rangeCheck = CreateCheckButton(trader, self:GetTraderRangeLabel(), 178, self.State.myLevelRange, function(value)
        TB.State.myLevelRange = value
        TB.State.browseOffset = 0
        TB:UpdateBrowse()
    end)
    rangeCheck:SetPoint("TOPLEFT", trader, "TOPLEFT", 10, -44)
    self.Frames.rangeCheck = rangeCheck

    local onlineCheck = CreateCheckButton(trader, "Online only", 178, self.State.onlineOnly, function(value)
        TB.State.onlineOnly = value
        TB.State.browseOffset = 0
        TB:UpdateBrowse()
    end)
    onlineCheck:SetPoint("TOPLEFT", trader, "TOPLEFT", 10, -82)
    self.Frames.onlineCheck = onlineCheck

    local levelPanel = CreatePanel(parent, 170, 150)
    levelPanel:SetPoint("TOPLEFT", parent, "TOPLEFT", 382, -50)
    CreateHeading(levelPanel, "Item Level")

    local levelType = CreateButton(levelPanel, "Required Level", 146, 30)
    levelType:SetPoint("TOPLEFT", levelPanel, "TOPLEFT", 12, -38)
    levelType:SetScript("OnClick", function()
        if TB.State.levelType == "required" then
            TB.State.levelType = "item"
        else
            TB.State.levelType = "required"
        end
        TB.State.browseOffset = 0
        TB:UpdateBrowse()
    end)
    self.Frames.levelTypeButton = levelType

    local minLabel = CreateText(levelPanel, "Min", "GameFontHighlightSmall", 0.80, 0.74, 0.62)
    minLabel:SetPoint("TOPLEFT", levelPanel, "TOPLEFT", 26, -79)
    local maxLabel = CreateText(levelPanel, "Max", "GameFontHighlightSmall", 0.80, 0.74, 0.62)
    maxLabel:SetPoint("TOPLEFT", levelPanel, "TOPLEFT", 104, -79)

    local minEdit = CreateEditBox(levelPanel, 58, 30, tostring(self.State.minLevel))
    minEdit:SetPoint("TOPLEFT", levelPanel, "TOPLEFT", 12, -101)
    minEdit:SetMaxLetters(3)
    minEdit:SetJustifyH("CENTER")
    self.Frames.minLevel = minEdit

    local maxEdit = CreateEditBox(levelPanel, 58, 30, tostring(self.State.maxLevel))
    maxEdit:SetPoint("TOPLEFT", levelPanel, "TOPLEFT", 90, -101)
    maxEdit:SetMaxLetters(3)
    maxEdit:SetJustifyH("CENTER")
    self.Frames.maxLevel = maxEdit

    minEdit:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        TB:UpdateBrowse()
    end)
    maxEdit:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        TB:UpdateBrowse()
    end)

    local rarity = CreatePanel(parent, 218, 150)
    rarity:SetPoint("TOPLEFT", parent, "TOPLEFT", 558, -50)
    CreateHeading(rarity, "Rarity")
    self.Frames.rarityChecks = {}

    local quality
    for quality = 1, 5 do
        local qualityIndex = quality
        local info = self.Quality[quality]
        local check = CreateCheckButton(rarity, info.name, 195, self.State.rarities[quality], function(value)
            TB.State.rarities[qualityIndex] = value
            TB.State.browseOffset = 0
            TB:UpdateBrowse()
        end, info.r, info.g, info.b)
        check:SetPoint("TOPLEFT", rarity, "TOPLEFT", 10, -30 - ((quality - 1) * 23))
        self.Frames.rarityChecks[quality] = check
    end

    local actions = CreatePanel(parent, 146, 150)
    actions:SetPoint("TOPLEFT", parent, "TOPLEFT", 782, -50)
    CreateHeading(actions, "Listing Type")
    self.Frames.listingTypeButtons = {}
    local listingChoices = {
        { label = "All Listings", value = "ALL" },
        { label = "For Sale", value = "SELL" },
        { label = "Wanted", value = "BUY" },
    }
    local i
    for i = 1, table.getn(listingChoices) do
        local listingType = listingChoices[i].value
        local typeButton = CreateButton(actions, listingChoices[i].label, 124, 27)
        typeButton:SetPoint("TOPLEFT", actions, "TOPLEFT", 11, -29 - ((i - 1) * 30))
        typeButton:SetScript("OnClick", function()
            TB.State.listingType = listingType
            TB.State.browseOffset = 0
            TB:UpdateBrowse()
        end)
        self.Frames.listingTypeButtons[listingType] = typeButton
    end

    local clear = CreateButton(actions, "Clear Filters", 124, 25)
    clear:SetPoint("TOPLEFT", actions, "TOPLEFT", 11, -120)
    clear:SetScript("OnClick", function()
        TB:ResetFilters()
        TB:SyncFilterControls()
        TB:UpdateBrowse()
        TB:SetStatus("All local filters cleared.")
    end)
end

function TB:TryInsertItemLink(item)
    if IsShiftKeyDown() and ChatFrameEditBox and ChatFrameEditBox:IsShown() then
        local link = self:GetListingItemLink(item)
        if link then
            ChatFrameEditBox:Insert(link)
            return 1
        end
    end
    return nil
end

function TB:ShowBrowseListingTooltips(row, listing)
    if not self.Frames.listingSummaryTooltip then
        self.Frames.listingSummaryTooltip = CreateFrame("GameTooltip", "TradeBoardListingSummaryTooltip", UIParent, "GameTooltipTemplate")
    end

    local summary = self.Frames.listingSummaryTooltip
    local info = self.Quality[listing.quality] or self.Quality[1]
    summary:SetOwner(row, "ANCHOR_RIGHT")
    summary:ClearLines()
    summary:SetText(listing.name, info.r, info.g, info.b)
    summary:AddLine(listing.orderType == "BUY" and "Wanted listing" or "For-sale listing", 0.80, 0.75, 0.62)
    summary:AddLine("Required level " .. listing.requiredLevel .. "   Item level " .. listing.itemLevel, 1, 1, 1)
    summary:AddLine("Trader: " .. listing.trader .. " (level " .. listing.traderLevel .. ")", 0.70, 0.85, 1)
    if listing.guild and listing.guild ~= "" then
        summary:AddLine("Guild: " .. listing.guild, 0.82, 0.72, 0.42)
    end
    if not listing.online then
        summary:AddLine("Last seen: " .. self:FormatLastSeen(listing.lastSeenAt) .. " ago", 0.58, 0.58, 0.58)
    end
    summary:AddLine("Shift-click with chat open to link the item.", 0.35, 1.00, 0.35)
    summary:AddLine("Synced through the HC TradeBoard network.", 0.55, 0.55, 0.55)
    summary:Show()

    GameTooltip:SetOwner(row, "ANCHOR_NONE")
    GameTooltip:ClearLines()
    local hyperlink = self:GetListingTooltipHyperlink(listing)
    if hyperlink then
        GameTooltip:SetHyperlink(hyperlink)
    else
        GameTooltip:SetText("Item details unavailable", 0.75, 0.72, 0.64)
    end
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("BOTTOMLEFT", summary, "TOPLEFT", 0, 4)
    GameTooltip:Show()

    local width = summary:GetWidth()
    if GameTooltip:GetWidth() > width then
        width = GameTooltip:GetWidth()
    end
    summary:SetWidth(width)
    GameTooltip:SetWidth(width)
end

function TB:HideBrowseListingTooltips()
    GameTooltip:Hide()
    if self.Frames.listingSummaryTooltip then
        self.Frames.listingSummaryTooltip:Hide()
    end
end

function TB:CreateResultsPanel(parent)
    local panel = CreatePanel(parent, 750, 280)
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 178, -208)
    panel:EnableMouseWheel(1)
    panel:SetScript("OnMouseWheel", function()
        local filtered = TB:GetFilteredListings()
        local maxOffset = table.getn(filtered) - TB.MAX_VISIBLE_ROWS
        if maxOffset < 0 then
            maxOffset = 0
        end

        if arg1 > 0 then
            TB.State.browseOffset = TB.State.browseOffset - 1
        else
            TB.State.browseOffset = TB.State.browseOffset + 1
        end

        if TB.State.browseOffset < 0 then
            TB.State.browseOffset = 0
        end
        if TB.State.browseOffset > maxOffset then
            TB.State.browseOffset = maxOffset
        end
        TB:UpdateBrowseRows(filtered)
    end)
    self.Frames.resultsPanel = panel

    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, -5)
    header:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -5, -5)
    header:SetHeight(28)
    local headerBg = header:CreateTexture(nil, "BACKGROUND")
    headerBg:SetTexture(0.14, 0.12, 0.075, 0.95)
    headerBg:SetAllPoints(header)

    local columns = {
        { text = "Item Name", x = 8, width = 188, sortKey = "name" },
        { text = "Qty", x = 200, width = 32, sortKey = "quantity" },
        { text = "Req", x = 234, width = 34, sortKey = "requiredLevel" },
        { text = "iLvl", x = 270, width = 34, sortKey = "itemLevel" },
        { text = "Unit Price", x = 306, width = 74, sortKey = "unitPrice" },
        { text = "Trader", x = 390, width = 82, sortKey = "trader" },
        { text = "Guild", x = 476, width = 96, sortKey = "guild" },
        { text = "Lv", x = 576, width = 42, sortKey = "traderLevel" },
        { text = "Status", x = 622, width = 104, sortKey = "online" },
    }

    self.Frames.sortHeaders = {}
    local i
    for i = 1, table.getn(columns) do
        local column = columns[i]
        local sortKey = column.sortKey
        local headerText = column.text
        local sortButton = CreateFrame("Button", nil, header)
        sortButton:SetPoint("TOPLEFT", header, "TOPLEFT", column.x, 0)
        sortButton:SetWidth(column.width)
        sortButton:SetHeight(28)

        local hover = sortButton:CreateTexture(nil, "HIGHLIGHT")
        hover:SetTexture(0.90, 0.64, 0.18, 0.16)
        hover:SetAllPoints(sortButton)

        local label = CreateText(sortButton, headerText, "GameFontNormalSmall", 0.92, 0.78, 0.45)
        label:SetPoint("LEFT", sortButton, "LEFT", 0, 0)
        label:SetWidth(column.width - 13)
        label:SetJustifyH("LEFT")

        local arrow = sortButton:CreateTexture(nil, "ARTWORK")
        arrow:SetTexture("Interface\\Buttons\\UI-SortArrow")
        arrow:SetWidth(9)
        arrow:SetHeight(8)
        arrow:SetPoint("RIGHT", sortButton, "RIGHT", -2, -1)
        arrow:Hide()

        sortButton.label = label
        sortButton.arrow = arrow
        sortButton.sortKey = sortKey
        sortButton:SetScript("OnClick", function()
            TB:SetSort(sortKey)
            TB:UpdateBrowse()
            local direction = TB.State.sortAscending and "ascending" or "descending"
            TB:SetStatus("Sorted by " .. headerText .. " (" .. direction .. ").")
        end)
        sortButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_TOP")
            GameTooltip:SetText("Sort by " .. headerText, 1.00, 0.82, 0.24)
            GameTooltip:AddLine("Click again to reverse the order.", 0.75, 0.72, 0.64)
            GameTooltip:Show()
        end)
        sortButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        self.Frames.sortHeaders[sortKey] = sortButton
    end

    self.Frames.resultRows = {}
    for i = 1, self.MAX_VISIBLE_ROWS do
        local row = CreateFrame("Button", nil, panel)
        row:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, -35 - ((i - 1) * 34))
        row:SetWidth(738)
        row:SetHeight(32)

        local bg = row:CreateTexture(nil, "BACKGROUND")
        if math.mod(i, 2) == 0 then
            bg:SetTexture(0.055, 0.055, 0.050, 0.90)
        else
            bg:SetTexture(0.025, 0.025, 0.025, 0.90)
        end
        bg:SetAllPoints(row)

        local selected = row:CreateTexture(nil, "ARTWORK")
        selected:SetTexture(0.75, 0.48, 0.12, 0.20)
        selected:SetAllPoints(row)
        selected:Hide()
        row.selected = selected

        local highlight = row:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetTexture(0.75, 0.48, 0.12, 0.12)
        highlight:SetAllPoints(row)

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetWidth(27)
        icon:SetHeight(27)
        icon:SetPoint("LEFT", row, "LEFT", 3, 0)
        row.icon = icon

        local name = CreateText(row, "", "GameFontHighlightSmall")
        name:SetPoint("LEFT", row, "LEFT", 34, 0)
        name:SetWidth(160)
        name:SetJustifyH("LEFT")
        row.itemName = name

        local function RowText(x, width, justify)
            local text = CreateText(row, "", "GameFontHighlightSmall", 0.86, 0.82, 0.74)
            text:SetPoint("LEFT", row, "LEFT", x, 0)
            text:SetWidth(width)
            text:SetJustifyH(justify or "LEFT")
            return text
        end

        row.quantity = RowText(200, 30, "CENTER")
        row.required = RowText(234, 32, "CENTER")
        row.itemLevel = RowText(270, 32, "CENTER")
        row.price = RowText(306, 72, "RIGHT")
        row.trader = RowText(390, 80, "LEFT")
        row.guild = RowText(476, 94, "LEFT")
        row.traderLevel = RowText(576, 40, "CENTER")
        row.status = RowText(622, 104, "LEFT")

        row:SetScript("OnClick", function()
            if this.listing then
                if TB:TryInsertItemLink(this.listing) then
                    return
                end
                TB.Frames.searchField:ClearFocus()
                TB.Frames.minLevel:ClearFocus()
                TB.Frames.maxLevel:ClearFocus()
                TB.State.selectedListing = this.listing
                TB:UpdateBrowse()
                TB:SetStatus("Selected " .. this.listing.name .. " from " .. this.listing.trader .. ".")
            end
        end)
        row:SetScript("OnEnter", function()
            if this.listing then
                TB:ShowBrowseListingTooltips(this, this.listing)
            end
        end)
        row:SetScript("OnLeave", function()
            TB:HideBrowseListingTooltips()
        end)

        self.Frames.resultRows[i] = row
    end

    local scrollHint = CreateText(panel, "SCROLL: use mouse wheel over this list", "GameFontNormalSmall", 1.00, 0.72, 0.20)
    scrollHint:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 5)
end

function TB:CreateMyListingsPane(parent)
    local pane = CreateFrame("Frame", nil, parent)
    pane:SetAllPoints(parent)
    pane:Hide()
    self.Frames.myListingsPane = pane

    local title = CreateText(pane, "My Listings", "GameFontNormalLarge", 1.00, 0.78, 0.20)
    title:SetPoint("TOPLEFT", pane, "TOPLEFT", 8, -8)
    local subtitle = CreateText(pane, "Select a real bag item and advertise a unit price to connected HC TradeBoard peers.", "GameFontHighlightSmall", 0.66, 0.63, 0.56)
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)

    local editor = CreatePanel(pane, 348, 424)
    editor:SetPoint("TOPLEFT", pane, "TOPLEFT", 8, -58)
    CreateHeading(editor, "Create a Sale Listing")

    local itemSlot = CreateFrame("Button", nil, editor)
    itemSlot:SetWidth(62)
    itemSlot:SetHeight(62)
    itemSlot:SetPoint("TOPLEFT", editor, "TOPLEFT", 18, -45)
    itemSlot:SetBackdrop(PANEL_BACKDROP)
    itemSlot:SetBackdropColor(0.02, 0.02, 0.02, 1)
    itemSlot:SetBackdropBorderColor(0.72, 0.52, 0.16, 1)
    itemSlot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local slotIcon = itemSlot:CreateTexture(nil, "ARTWORK")
    slotIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    slotIcon:SetWidth(48)
    slotIcon:SetHeight(48)
    slotIcon:SetPoint("CENTER", itemSlot, "CENTER", 0, 0)
    itemSlot.icon = slotIcon
    local slotHighlight = itemSlot:CreateTexture(nil, "HIGHLIGHT")
    slotHighlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    slotHighlight:SetBlendMode("ADD")
    slotHighlight:SetAllPoints(itemSlot)
    itemSlot:SetScript("OnClick", function()
        if arg1 == "RightButton" then
            TB:CancelBagPick()
        else
            TB:BeginBagPick()
        end
    end)
    itemSlot:SetScript("OnReceiveDrag", function()
        local candidate = TB.dragListingCandidate
        if CursorHasItem() then
            ClearCursor()
        end
        if candidate then
            TB:ApplyBagListingCandidate(candidate)
        else
            TB:SetStatus("Drag an item from a normal bag slot onto this box.")
        end
    end)
    itemSlot:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText("Sale Item", 1.00, 0.82, 0.24)
        GameTooltip:AddLine("Shift-left-click a bag item or drag it here.", 0.88, 0.84, 0.75)
        GameTooltip:AddLine("Click this box to arm one normal bag click.", 0.65, 0.72, 0.90)
        GameTooltip:Show()
    end)
    itemSlot:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    self.Frames.listingItemSlot = itemSlot

    local itemName = CreateText(editor, "No item selected", "GameFontNormal", 0.72, 0.68, 0.60)
    itemName:SetPoint("TOPLEFT", editor, "TOPLEFT", 92, -51)
    itemName:SetWidth(235)
    itemName:SetJustifyH("LEFT")
    self.Frames.listingItemName = itemName

    local itemHelp = CreateText(editor, "Shift-click a bag item or drag it onto this slot.", "GameFontHighlightSmall", 0.62, 0.60, 0.54)
    itemHelp:SetPoint("TOPLEFT", itemName, "BOTTOMLEFT", 0, -7)
    itemHelp:SetWidth(235)
    itemHelp:SetJustifyH("LEFT")
    self.Frames.listingItemHelp = itemHelp

    local choose = CreateButton(editor, "Arm Normal Bag Click", 166, 30)
    choose:SetPoint("TOPLEFT", editor, "TOPLEFT", 18, -123)
    choose:SetScript("OnClick", function()
        TB:BeginBagPick()
    end)

    local clearItem = CreateButton(editor, "Clear", 96, 30)
    clearItem:SetPoint("LEFT", choose, "RIGHT", 8, 0)
    clearItem:SetScript("OnClick", function()
        TB.PendingListing = nil
        TB.bagPickMode = nil
        TB:UpdateListingEditor()
        TB:SetStatus("Listing item cleared.")
    end)

    local qtyLabel = CreateText(editor, "Quantity", "GameFontNormal", 0.92, 0.78, 0.45)
    qtyLabel:SetPoint("TOPLEFT", editor, "TOPLEFT", 18, -176)
    local qtyEdit = CreateEditBox(editor, 82, 30, "")
    qtyEdit:SetPoint("TOPLEFT", editor, "TOPLEFT", 18, -197)
    qtyEdit:SetJustifyH("CENTER")
    qtyEdit:SetMaxLetters(4)
    self.Frames.listingQuantity = qtyEdit
    local qtyMax = CreateText(editor, "", "GameFontHighlightSmall", 0.66, 0.63, 0.56)
    qtyMax:SetPoint("LEFT", qtyEdit, "RIGHT", 8, 0)
    self.Frames.listingQuantityMax = qtyMax

    local priceLabel = CreateText(editor, "Unit Price", "GameFontNormal", 0.92, 0.78, 0.45)
    priceLabel:SetPoint("TOPLEFT", editor, "TOPLEFT", 18, -251)
    local coinLabels = { "Gold", "Silver", "Copper" }
    local coinX = { 18, 122, 226 }
    self.Frames.listingPriceEdits = {}
    local i
    for i = 1, 3 do
        local coinLabel = CreateText(editor, coinLabels[i], "GameFontHighlightSmall", 0.72, 0.68, 0.60)
        coinLabel:SetPoint("TOPLEFT", editor, "TOPLEFT", coinX[i], -274)
        local coinEdit = CreateEditBox(editor, 82, 30, "")
        coinEdit:SetPoint("TOPLEFT", editor, "TOPLEFT", coinX[i], -294)
        coinEdit:SetJustifyH("CENTER")
        coinEdit:SetMaxLetters(i == 1 and 6 or 2)
        self.Frames.listingPriceEdits[i] = coinEdit
    end

    local post = CreateButton(editor, "Post Sale Listing", 194, 36)
    post:SetPoint("BOTTOM", editor, "BOTTOM", 0, 22)
    post:SetScript("OnClick", function()
        local gold = tonumber(TB.Frames.listingPriceEdits[1]:GetText()) or 0
        local silver = tonumber(TB.Frames.listingPriceEdits[2]:GetText()) or 0
        local copper = tonumber(TB.Frames.listingPriceEdits[3]:GetText()) or 0
        if silver > 99 or copper > 99 then
            TB:SetStatus("Silver and copper must each be between 0 and 99.")
            return
        end
        TB:CreateMyListing(TB.Frames.listingQuantity:GetText(), (gold * 10000) + (silver * 100) + copper)
    end)

    local listPanel = CreatePanel(pane, 554, 424)
    listPanel:SetPoint("TOPLEFT", pane, "TOPLEFT", 366, -58)
    listPanel:EnableMouseWheel(1)
    local function ScrollMyListings()
        local maxOffset = table.getn(TB.MyListings) - TB.MAX_MY_LISTING_ROWS
        if maxOffset < 0 then
            maxOffset = 0
        end
        if arg1 > 0 then
            TB.State.myListingOffset = (TB.State.myListingOffset or 0) - 1
        else
            TB.State.myListingOffset = (TB.State.myListingOffset or 0) + 1
        end
        if TB.State.myListingOffset < 0 then
            TB.State.myListingOffset = 0
        elseif TB.State.myListingOffset > maxOffset then
            TB.State.myListingOffset = maxOffset
        end
        TB:UpdateMyListings()
    end
    listPanel:SetScript("OnMouseWheel", ScrollMyListings)
    CreateHeading(listPanel, "My Active Sales")
    self.Frames.myListingRows = {}
    for i = 1, self.MAX_MY_LISTING_ROWS do
        local row = CreateFrame("Button", nil, listPanel)
        row:SetWidth(532)
        row:SetHeight(58)
        row:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 11, -40 - ((i - 1) * 63))
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture(0.035, 0.035, 0.032, 0.92)
        bg:SetAllPoints(row)
        local selected = row:CreateTexture(nil, "ARTWORK")
        selected:SetTexture(0.75, 0.48, 0.12, 0.20)
        selected:SetAllPoints(row)
        selected:Hide()
        row.selected = selected
        local hover = row:CreateTexture(nil, "HIGHLIGHT")
        hover:SetTexture(0.72, 0.46, 0.12, 0.12)
        hover:SetAllPoints(row)
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetWidth(42)
        icon:SetHeight(42)
        icon:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.icon = icon
        local name = CreateText(row, "", "GameFontNormal")
        name:SetPoint("TOPLEFT", row, "TOPLEFT", 60, -10)
        name:SetWidth(285)
        name:SetJustifyH("LEFT")
        row.itemName = name
        local details = CreateText(row, "", "GameFontHighlightSmall", 0.76, 0.72, 0.65)
        details:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 60, 9)
        row.details = details
        local active = CreateText(row, "Broadcasting", "GameFontHighlightSmall", 0.30, 1.00, 0.30)
        active:SetPoint("RIGHT", row, "RIGHT", -12, 0)
        row.active = active
        row:SetScript("OnClick", function()
            if this.listing and TB:TryInsertItemLink(this.listing) then
                return
            end
            if this.listing then
                TB.State.selectedMyListing = this.listing
                TB:UpdateMyListings()
                TB:SetStatus("Selected your " .. this.listing.name .. " listing.")
            end
        end)
        row:EnableMouseWheel(1)
        row:SetScript("OnMouseWheel", ScrollMyListings)
        self.Frames.myListingRows[i] = row
    end

    local count = CreateText(listPanel, "0 active listings", "GameFontHighlightSmall", 0.72, 0.68, 0.60)
    count:SetPoint("BOTTOMLEFT", listPanel, "BOTTOMLEFT", 14, 14)
    self.Frames.myListingCount = count

    local remove = CreateButton(listPanel, "Remove Selected", 150, 32)
    remove:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -10, 10)
    remove:SetScript("OnClick", function()
        if TB.State.selectedMyListing then
            TB:DeleteMyListing(TB.State.selectedMyListing.id)
        else
            TB:SetStatus("Select one of your listings before removing it.")
        end
    end)

    self:UpdateListingEditor()
    self:UpdateMyListings()
end

function TB:UpdateListingEditor()
    local pending = self.PendingListing
    if pending then
        local info = self.Quality[pending.quality] or self.Quality[1]
        self.Frames.listingItemSlot.icon:SetTexture(pending.texture)
        self.Frames.listingItemName:SetText(pending.name)
        self.Frames.listingItemName:SetTextColor(info.r, info.g, info.b)
        if self.bagPickMode then
            self.Frames.listingItemHelp:SetText("Choose the replacement item with one normal bag click.")
        else
            self.Frames.listingItemHelp:SetText("Bag " .. pending.bag .. ", slot " .. pending.slot .. " / Shift-click or drag to replace")
        end
        self.Frames.listingQuantityMax:SetText("Available: " .. pending.availableQuantity)
        if self.editorPendingListing ~= pending then
            self.Frames.listingQuantity:SetText(tostring(pending.availableQuantity))
            self.Frames.listingPriceEdits[1]:SetText("")
            self.Frames.listingPriceEdits[2]:SetText("")
            self.Frames.listingPriceEdits[3]:SetText("")
            self.editorPendingListing = pending
        end
    else
        self.Frames.listingItemSlot.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        self.Frames.listingItemName:SetText(self.bagPickMode and "Choose a bag item..." or "No item selected")
        self.Frames.listingItemName:SetTextColor(0.72, 0.68, 0.60)
        self.Frames.listingItemHelp:SetText(self.bagPickMode and "Your next normal bag-item click will select it." or "Shift-click a bag item or drag it onto this slot.")
        self.Frames.listingQuantityMax:SetText("")
        self.Frames.listingQuantity:SetText("")
        self.Frames.listingPriceEdits[1]:SetText("")
        self.Frames.listingPriceEdits[2]:SetText("")
        self.Frames.listingPriceEdits[3]:SetText("")
        self.editorPendingListing = nil
    end
end

function TB:UpdateMyListings()
    if not self.Frames.myListingRows then
        return
    end
    local total = table.getn(self.MyListings)
    local visibleRows = table.getn(self.Frames.myListingRows)
    local maxOffset = total - visibleRows
    if maxOffset < 0 then
        maxOffset = 0
    end
    local offset = self.State.myListingOffset or 0
    if offset < 0 then
        offset = 0
    elseif offset > maxOffset then
        offset = maxOffset
    end
    self.State.myListingOffset = offset

    local i
    for i = 1, table.getn(self.Frames.myListingRows) do
        local row = self.Frames.myListingRows[i]
        local listing = self.MyListings[offset + i]
        if listing then
            local info = self.Quality[listing.quality] or self.Quality[1]
            row.listing = listing
            row.icon:SetTexture(listing.texture or "Interface\\Icons\\INV_Misc_QuestionMark")
            row.itemName:SetText(listing.name)
            row.itemName:SetTextColor(info.r, info.g, info.b)
            row.details:SetText("Qty " .. listing.quantity .. " / " .. self:FormatMoney(listing.unitPrice) .. " each")
            if self.Network and self.Network.state == "CONNECTED" then
                row.active:SetText("Broadcasting")
                row.active:SetTextColor(0.30, 1.00, 0.30)
            elseif self.Network and (self.Network.state == "PROBING" or self.Network.state == "JOINING") then
                row.active:SetText("Queued")
                row.active:SetTextColor(1.00, 0.78, 0.25)
            elseif self.Network and self.Network.state == "ALONE" then
                row.active:SetText("No peer yet")
                row.active:SetTextColor(1.00, 0.78, 0.25)
            else
                row.active:SetText("Local only")
                row.active:SetTextColor(0.70, 0.45, 0.35)
            end
            if self.State.selectedMyListing == listing then
                row.selected:Show()
            else
                row.selected:Hide()
            end
            row:Show()
        else
            row.listing = nil
            row:Hide()
        end
    end
    local countText = total .. (total == 1 and " active listing" or " active listings")
    if maxOffset > 0 then
        countText = countText .. " - SCROLL WITH MOUSE WHEEL"
    end
    self.Frames.myListingCount:SetText(countText)
end

function TB:CreateTradeChainsPane(parent)
    local pane = CreateFrame("Frame", nil, parent)
    pane:SetAllPoints(parent)
    pane:Hide()
    self.Frames.tradeChainsPane = pane

    local intro = CreateText(pane, "Trade chains bridge goods through legal 5-level handoffs.", "GameFontNormal", 0.90, 0.82, 0.66)
    intro:SetPoint("TOPLEFT", pane, "TOPLEFT", 8, -8)

    local listPanel = CreatePanel(pane, 180, 430)
    listPanel:SetPoint("TOPLEFT", pane, "TOPLEFT", 0, -42)
    listPanel:EnableMouseWheel(1)
    listPanel:SetScript("OnMouseWheel", function()
        local maxOffset = table.getn(TB.Chains) - 8
        if maxOffset < 0 then
            maxOffset = 0
        end
        if arg1 > 0 then
            TB.State.chainOffset = TB.State.chainOffset - 1
        else
            TB.State.chainOffset = TB.State.chainOffset + 1
        end
        if TB.State.chainOffset < 0 then
            TB.State.chainOffset = 0
        elseif TB.State.chainOffset > maxOffset then
            TB.State.chainOffset = maxOffset
        end
        TB:UpdateTradeChains()
    end)
    CreateHeading(listPanel, "Listed Chains")

    self.Frames.chainButtons = {}
    local i
    for i = 1, 8 do
        local button = CreateButton(listPanel, "", 158, 32)
        button:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 11, -40 - ((i - 1) * 39))
        button.label:ClearAllPoints()
        button.label:SetPoint("LEFT", button, "LEFT", 10, 0)
        button.label:SetWidth(138)
        button.label:SetJustifyH("LEFT")
        button:SetScript("OnClick", function()
            if this.chainIndex and TB.Chains[this.chainIndex] then
                TB.State.selectedChain = this.chainIndex
                TB:UpdateTradeChains()
            end
        end)
        self.Frames.chainButtons[i] = button
        button:Hide()
    end

    local deleteChain = CreateButton(listPanel, "Delete My Chain", 158, 30)
    deleteChain:SetPoint("BOTTOMLEFT", listPanel, "BOTTOMLEFT", 11, 10)
    deleteChain:SetScript("OnClick", function()
        TB:DeleteOwnChain()
    end)

    local scrollChains = CreateText(listPanel, "SCROLL: mouse wheel for more chains", "GameFontNormalSmall", 1.00, 0.72, 0.20)
    scrollChains:SetPoint("BOTTOM", deleteChain, "TOP", 0, 5)

    local detail = CreatePanel(pane, 738, 430)
    detail:SetPoint("TOPLEFT", pane, "TOPLEFT", 190, -42)
    self.Frames.chainDetail = detail

    local chainTitle = CreateText(detail, "", "GameFontNormalLarge", 1.00, 0.78, 0.20)
    chainTitle:SetPoint("TOP", detail, "TOP", 0, -15)
    self.Frames.chainTitle = chainTitle

    local positions = {
        { 20, -70 }, { 194, -70 }, { 368, -70 }, { 542, -70 },
        { 542, -178 }, { 368, -178 }, { 194, -178 }, { 20, -178 },
        { 20, -286 }, { 194, -286 }, { 368, -286 }, { 542, -286 },
    }

    self.Frames.chainNodes = {}
    for i = 1, 12 do
        local node = CreatePanel(detail, 150, 58)
        node:SetPoint("TOPLEFT", detail, "TOPLEFT", positions[i][1], positions[i][2])
        node:SetBackdropColor(0.045, 0.045, 0.042, 1)

        local level = CreateText(node, "", "GameFontNormal", 1.00, 0.78, 0.20)
        level:SetPoint("TOPLEFT", node, "TOPLEFT", 10, -8)
        node.level = level

        local name = CreateText(node, "", "GameFontHighlightSmall", 0.88, 0.84, 0.76)
        name:SetPoint("BOTTOMLEFT", node, "BOTTOMLEFT", 10, 8)
        node.memberName = name

        local dot = node:CreateTexture(nil, "ARTWORK")
        dot:SetTexture(1, 1, 1, 1)
        dot:SetWidth(10)
        dot:SetHeight(10)
        dot:SetPoint("RIGHT", node, "RIGHT", -10, 0)
        node.dot = dot

        self.Frames.chainNodes[i] = node
    end

    local function Line(x, y, width, height)
        local line = detail:CreateTexture(nil, "BACKGROUND")
        line:SetTexture(GOLD_R, GOLD_G, GOLD_B, 0.70)
        line:SetPoint("TOPLEFT", detail, "TOPLEFT", x, y)
        line:SetWidth(width)
        line:SetHeight(height)
    end

    Line(170, -98, 24, 3)
    Line(344, -98, 24, 3)
    Line(518, -98, 24, 3)
    Line(616, -128, 3, 50)
    Line(518, -206, 24, 3)
    Line(344, -206, 24, 3)
    Line(170, -206, 24, 3)
    Line(94, -236, 3, 50)
    Line(170, -314, 24, 3)
    Line(344, -314, 24, 3)
    Line(518, -314, 24, 3)

    local onlinePanel = CreatePanel(pane, 170, 42)
    onlinePanel:SetPoint("BOTTOMLEFT", pane, "BOTTOMLEFT", 190, 0)
    local onlineText = CreateText(onlinePanel, "", "GameFontNormal", 0.35, 1.00, 0.35)
    onlineText:SetPoint("CENTER", onlinePanel, "CENTER", 0, 0)
    self.Frames.chainOnline = onlineText

    local fullPanel = CreatePanel(pane, 170, 42)
    fullPanel:SetPoint("LEFT", onlinePanel, "RIGHT", 8, 0)
    local fullText = CreateText(fullPanel, "Full 5-60 chain", "GameFontNormal", 0.95, 0.82, 0.42)
    fullText:SetPoint("CENTER", fullPanel, "CENTER", 0, 0)
    self.Frames.chainFilled = fullText

    local factionPanel = CreatePanel(pane, 170, 42)
    factionPanel:SetPoint("LEFT", fullPanel, "RIGHT", 8, 0)
    local factionText = CreateText(factionPanel, "", "GameFontNormal", 0.95, 0.82, 0.42)
    factionText:SetPoint("CENTER", factionPanel, "CENTER", 0, 0)
    self.Frames.chainFaction = factionText

    local listChain = CreateButton(pane, "List / Edit My Chain", 158, 42)
    listChain:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", 0, 0)
    listChain:SetScript("OnClick", function()
        TB:OpenChainEditor()
    end)

    self:CreateChainEditor(pane)
end

function TB:CreateChainEditor(parent)
    local editor = CreatePanel(parent, 660, 450)
    editor:SetPoint("CENTER", parent, "CENTER", 0, 0)
    editor:SetFrameLevel(parent:GetFrameLevel() + 20)
    editor:EnableMouse(1)
    editor:Hide()
    self.Frames.chainEditor = editor

    local title = CreateText(editor, "List My Trade Chain", "GameFontNormalLarge", 1.00, 0.78, 0.20)
    title:SetPoint("TOP", editor, "TOP", 0, -18)
    local help = CreateText(editor, "Add one character for each five-level handoff. Empty slots are allowed.", "GameFontHighlightSmall", 0.72, 0.68, 0.60)
    help:SetPoint("TOP", title, "BOTTOM", 0, -7)

    local nameLabel = CreateText(editor, "Chain name", "GameFontNormalSmall", 0.92, 0.78, 0.45)
    nameLabel:SetPoint("TOPLEFT", editor, "TOPLEFT", 24, -67)
    local nameEdit = CreateEditBox(editor, 510, 28, "")
    nameEdit:SetPoint("TOPLEFT", editor, "TOPLEFT", 120, -61)
    nameEdit:SetMaxLetters(32)
    self.Frames.chainNameEdit = nameEdit
    self.Frames.chainMemberEdits = {}

    local i
    for i = 1, 12 do
        local column = 0
        local row = i - 1
        if i > 6 then
            column = 1
            row = i - 7
        end
        local x = 24 + (column * 316)
        local y = -105 - (row * 48)
        local level = i * 5
        local levelLabel = CreateText(editor, "Lv " .. level, "GameFontNormal", 1.00, 0.78, 0.20)
        levelLabel:SetPoint("TOPLEFT", editor, "TOPLEFT", x, y - 7)
        local memberEdit = CreateEditBox(editor, 232, 30, "")
        memberEdit:SetPoint("TOPLEFT", editor, "TOPLEFT", x + 54, y)
        memberEdit:SetMaxLetters(12)
        self.Frames.chainMemberEdits[i] = memberEdit
    end

    local save = CreateButton(editor, "Save Chain", 130, 34)
    save:SetPoint("BOTTOMRIGHT", editor, "BOTTOMRIGHT", -18, 16)
    save:SetScript("OnClick", function()
        TB:SaveChainEditor()
    end)

    local cancel = CreateButton(editor, "Cancel", 100, 34)
    cancel:SetPoint("RIGHT", save, "LEFT", -8, 0)
    cancel:SetScript("OnClick", function()
        TB.Frames.chainEditor:Hide()
        TB:SetStatus("Chain editing cancelled.")
    end)
end

function TB:OpenChainEditor()
    local saved = TradeBoardDB and TradeBoardDB.myChain
    local playerName = UnitName("player") or "My"
    local i
    self.Frames.chainNameEdit:SetText(saved and saved.name or (playerName .. "'s Chain"))
    for i = 1, 12 do
        local memberName = ""
        if saved and saved.members and saved.members[i] then
            memberName = saved.members[i]
        end
        self.Frames.chainMemberEdits[i]:SetText(memberName)
    end

    if not saved then
        local slot = math.floor((self:GetPlayerLevel() + 2) / 5)
        if slot < 1 then
            slot = 1
        elseif slot > 12 then
            slot = 12
        end
        self.Frames.chainMemberEdits[slot]:SetText(playerName)
    end

    self.Frames.chainEditor:Show()
    self.Frames.chainNameEdit:SetFocus()
    self.Frames.chainNameEdit:HighlightText()
    self:SetStatus("Editing your local trade chain.")
end

function TB:SaveChainEditor()
    local chainName = self.Frames.chainNameEdit:GetText() or ""
    if chainName == "" then
        chainName = "My Trade Chain"
    end

    local savedMembers = {}
    local i
    for i = 1, 12 do
        local memberName = self.Frames.chainMemberEdits[i]:GetText() or ""
        savedMembers[i] = memberName
    end

    self:SaveOwnChain(chainName, savedMembers)
    self.Frames.chainEditor:Hide()
    self:UpdateTradeChains()
    self:SetStatus("Saved and announced " .. chainName .. ".")
end

function TB:CreateProfessionsPane(parent)
    local pane = CreateFrame("Frame", nil, parent)
    pane:SetAllPoints(parent)
    pane:Hide()
    self.Frames.professionsPane = pane

    local intro = CreateText(pane, "Find online and recently seen crafters, compare guild participation, and publish your services.", "GameFontNormal", 0.90, 0.82, 0.66)
    intro:SetPoint("TOPLEFT", pane, "TOPLEFT", 8, -8)

    local filters = CreatePanel(pane, 180, 430)
    filters:SetPoint("TOPLEFT", pane, "TOPLEFT", 0, -42)
    CreateHeading(filters, "Profession")
    self.Frames.professionButtons = {}
    local filterNames = { "All Services" }
    local i
    for i = 1, table.getn(self.ProfessionNames) do
        table.insert(filterNames, self.ProfessionNames[i])
    end
    for i = 1, table.getn(filterNames) do
        local professionName = filterNames[i]
        local button = CreateButton(filters, professionName, 158, 27)
        button:SetPoint("TOPLEFT", filters, "TOPLEFT", 11, -34 - ((i - 1) * 31))
        button.label:ClearAllPoints()
        button.label:SetPoint("LEFT", button, "LEFT", 9, 0)
        button.label:SetJustifyH("LEFT")
        button.professionName = professionName
        button:SetScript("OnClick", function()
            TB.State.profession = this.professionName
            TB.State.professionOffset = 0
            TB:UpdateProfessions()
        end)
        self.Frames.professionButtons[professionName] = button
    end

    local results = CreatePanel(pane, 738, 430)
    results:SetPoint("TOPLEFT", pane, "TOPLEFT", 190, -42)
    results:EnableMouseWheel(1)
    results:SetScript("OnMouseWheel", function()
        local filtered = TB:GetFilteredServices()
        local maxOffset = table.getn(filtered) - 7
        if maxOffset < 0 then
            maxOffset = 0
        end
        if arg1 > 0 then
            TB.State.professionOffset = TB.State.professionOffset - 1
        else
            TB.State.professionOffset = TB.State.professionOffset + 1
        end
        if TB.State.professionOffset < 0 then
            TB.State.professionOffset = 0
        elseif TB.State.professionOffset > maxOffset then
            TB.State.professionOffset = maxOffset
        end
        TB:UpdateProfessionRows(filtered)
    end)

    self.Frames.guildCards = {}
    local rankColors = {
        { 1.00, 0.78, 0.20 },
        { 0.78, 0.78, 0.82 },
        { 0.78, 0.48, 0.24 },
    }
    for i = 1, 3 do
        local card = CreateFrame("Button", nil, results)
        card:SetWidth(232)
        card:SetHeight(58)
        card:SetPoint("TOPLEFT", results, "TOPLEFT", 6 + ((i - 1) * 241), -6)
        card:SetBackdrop(PANEL_BACKDROP)
        card:SetBackdropColor(0.04, 0.04, 0.035, 0.96)
        card:SetBackdropBorderColor(0.38, 0.31, 0.17, 1)
        local selected = card:CreateTexture(nil, "ARTWORK")
        selected:SetTexture(0.78, 0.50, 0.14, 0.18)
        selected:SetPoint("TOPLEFT", card, "TOPLEFT", 4, -4)
        selected:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -4, 4)
        selected:Hide()
        card.selected = selected
        local hover = card:CreateTexture(nil, "HIGHLIGHT")
        hover:SetTexture(0.78, 0.50, 0.14, 0.14)
        hover:SetPoint("TOPLEFT", card, "TOPLEFT", 4, -4)
        hover:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -4, 4)
        local icon = card:CreateTexture(nil, "ARTWORK")
        icon:SetWidth(42)
        icon:SetHeight(42)
        icon:SetPoint("LEFT", card, "LEFT", 8, 0)
        card.icon = icon
        local rank = CreateText(card, "#" .. i, "GameFontNormalSmall", rankColors[i][1], rankColors[i][2], rankColors[i][3])
        rank:SetPoint("TOPLEFT", card, "TOPLEFT", 5, -4)
        local guildName = CreateText(card, "", "GameFontNormal", 1.00, 0.82, 0.24)
        guildName:SetPoint("TOPLEFT", card, "TOPLEFT", 58, -10)
        guildName:SetWidth(164)
        guildName:SetJustifyH("LEFT")
        card.guildLabel = guildName
        local providerCount = CreateText(card, "", "GameFontHighlightSmall", 0.72, 0.68, 0.60)
        providerCount:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 58, 9)
        card.providerCount = providerCount
        card:SetScript("OnClick", function()
            if this.guildName then
                if TB.State.guildFilter == this.guildName then
                    TB.State.guildFilter = nil
                    TB:SetStatus("Showing profession providers from all guilds.")
                else
                    TB.State.guildFilter = this.guildName
                    TB:SetStatus("Showing profession providers from " .. this.guildName .. ". Click its sigil again to clear.")
                end
                TB.State.professionOffset = 0
                TB:UpdateProfessions()
            end
        end)
        card:SetScript("OnEnter", function()
            if this.guildName then
                GameTooltip:SetOwner(this, "ANCHOR_TOP")
                GameTooltip:SetText(this.guildName, 1.00, 0.82, 0.24)
                GameTooltip:AddLine(this.providerTotal .. (this.providerTotal == 1 and " profession provider" or " profession providers"), 0.86, 0.82, 0.74)
                GameTooltip:AddLine("Click to show only this guild. Click again to clear.", 0.35, 1.00, 0.35, 1)
                GameTooltip:Show()
            end
        end)
        card:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        self.Frames.guildCards[i] = card
    end

    local header = CreateFrame("Frame", nil, results)
    header:SetPoint("TOPLEFT", results, "TOPLEFT", 6, -70)
    header:SetPoint("TOPRIGHT", results, "TOPRIGHT", -6, -70)
    header:SetHeight(28)
    local headerBg = header:CreateTexture(nil, "BACKGROUND")
    headerBg:SetTexture(0.14, 0.12, 0.075, 0.95)
    headerBg:SetAllPoints(header)
    local headers = {
        { "Profession", 8, 108 }, { "Crafter", 122, 90 }, { "Guild", 216, 120 },
        { "Skill", 340, 55 }, { "Service Note", 399, 210 }, { "Status", 613, 105 },
    }
    for i = 1, table.getn(headers) do
        local label = CreateText(header, headers[i][1], "GameFontNormalSmall", 0.92, 0.78, 0.45)
        label:SetPoint("LEFT", header, "LEFT", headers[i][2], 0)
        label:SetWidth(headers[i][3])
        label:SetJustifyH("LEFT")
    end

    self.Frames.professionRows = {}
    for i = 1, 7 do
        local row = CreateFrame("Button", nil, results)
        row:SetPoint("TOPLEFT", results, "TOPLEFT", 6, -102 - ((i - 1) * 39))
        row:SetWidth(726)
        row:SetHeight(36)
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture(math.mod(i, 2) == 0 and 0.055 or 0.025, math.mod(i, 2) == 0 and 0.055 or 0.025, 0.025, 0.90)
        bg:SetAllPoints(row)
        local selected = row:CreateTexture(nil, "ARTWORK")
        selected:SetTexture(0.75, 0.48, 0.12, 0.20)
        selected:SetAllPoints(row)
        selected:Hide()
        row.selected = selected
        local hover = row:CreateTexture(nil, "HIGHLIGHT")
        hover:SetTexture(0.75, 0.48, 0.12, 0.12)
        hover:SetAllPoints(row)

        local function ServiceText(x, width, colorR, colorG, colorB)
            local text = CreateText(row, "", "GameFontHighlightSmall", colorR or 0.86, colorG or 0.82, colorB or 0.74)
            text:SetPoint("LEFT", row, "LEFT", x, 0)
            text:SetWidth(width)
            text:SetJustifyH("LEFT")
            return text
        end
        row.profession = ServiceText(8, 108, 1.00, 0.82, 0.24)
        row.crafter = ServiceText(122, 90)
        row.guild = ServiceText(216, 120, 0.82, 0.72, 0.42)
        row.skill = ServiceText(340, 55)
        row.note = ServiceText(399, 210, 0.76, 0.72, 0.65)
        row.status = ServiceText(613, 105, 0.30, 1.00, 0.30)
        row:SetScript("OnClick", function()
            if this.service then
                TB.State.selectedService = this.service
                TB:UpdateProfessions()
                TB:SetStatus("Selected " .. this.service.profession .. " service from " .. this.service.trader .. ".")
            end
        end)
        row:SetScript("OnEnter", function()
            if this.service then
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:SetText(this.service.profession .. " - " .. this.service.trader, 1.00, 0.82, 0.24)
                if this.service.guild and this.service.guild ~= "" then
                    GameTooltip:AddLine("Guild: " .. this.service.guild, 0.82, 0.72, 0.42)
                end
                GameTooltip:AddLine("Skill " .. this.service.rank .. "/" .. this.service.maxRank, 0.90, 0.86, 0.76)
                GameTooltip:AddLine(this.service.note ~= "" and this.service.note or "Available for profession work.", 0.76, 0.72, 0.65, 1)
                if this.service.online then
                    GameTooltip:AddLine("Online through HC TradeBoard", 0.30, 1.00, 0.30)
                else
                    GameTooltip:AddLine("Last seen: " .. TB:FormatLastSeen(this.service.lastSeenAt) .. " ago", 0.58, 0.58, 0.58)
                end
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        self.Frames.professionRows[i] = row
    end

    local count = CreateText(results, "0 services", "GameFontHighlightSmall", 0.72, 0.68, 0.60)
    count:SetPoint("BOTTOMLEFT", results, "BOTTOMLEFT", 12, 15)
    self.Frames.professionCount = count

    local edit = CreateButton(results, "List / Edit Mine", 130, 32)
    edit:SetPoint("BOTTOMRIGHT", results, "BOTTOMRIGHT", -10, 9)
    edit:SetScript("OnClick", function()
        TB:OpenProfessionEditor()
    end)
    local remove = CreateButton(results, "Remove Mine", 108, 32)
    remove:SetPoint("RIGHT", edit, "LEFT", -7, 0)
    remove:SetScript("OnClick", function()
        TB:DeleteOwnServices()
    end)
    local whisper = CreateButton(results, "Whisper", 92, 32)
    whisper:SetPoint("RIGHT", remove, "LEFT", -7, 0)
    whisper:SetScript("OnClick", function()
        if TB.State.selectedService then
            ChatFrame_OpenChat("/w " .. TB.State.selectedService.trader .. " ")
        else
            TB:SetStatus("Select a profession service before whispering its crafter.")
        end
    end)
    self:CreateProfessionEditor(pane)
    self:UpdateProfessions()
end

function TB:CreateProfessionEditor(parent)
    local editor = CreatePanel(parent, 740, 500)
    editor:SetPoint("CENTER", parent, "CENTER", 0, 0)
    editor:SetFrameLevel(parent:GetFrameLevel() + 20)
    editor:EnableMouse(1)
    editor:Hide()
    self.Frames.professionEditor = editor

    local title = CreateText(editor, "List My Profession Services", "GameFontNormalLarge", 1.00, 0.78, 0.20)
    title:SetPoint("TOP", editor, "TOP", 0, -16)
    local help = CreateText(editor, "Only professions learned by this character can be published.", "GameFontHighlightSmall", 0.72, 0.68, 0.60)
    help:SetPoint("TOP", title, "BOTTOM", 0, -6)
    local skillHeader = CreateText(editor, "Skill", "GameFontNormalSmall", 0.92, 0.78, 0.45)
    skillHeader:SetPoint("TOPLEFT", editor, "TOPLEFT", 194, -48)
    local noteHeader = CreateText(editor, "Short service note", "GameFontNormalSmall", 0.92, 0.78, 0.45)
    noteHeader:SetPoint("TOPLEFT", editor, "TOPLEFT", 278, -48)

    self.Frames.professionChecks = {}
    self.Frames.professionRanks = {}
    self.Frames.professionNotes = {}
    local i
    for i = 1, table.getn(self.ProfessionNames) do
        local professionName = self.ProfessionNames[i]
        local y = -61 - ((i - 1) * 34)
        local check = CreateCheckButton(editor, professionName, 168, nil, function(value)
            if value and not TB.KnownProfessions[professionName] then
                this:SetCheckedValue(nil)
                TB:SetStatus(professionName .. " is not learned by this character.")
            end
        end)
        check:SetPoint("TOPLEFT", editor, "TOPLEFT", 18, y)
        self.Frames.professionChecks[professionName] = check
        local rank = CreateText(editor, "", "GameFontHighlightSmall", 0.76, 0.72, 0.65)
        rank:SetPoint("TOPLEFT", editor, "TOPLEFT", 194, y - 5)
        rank:SetWidth(72)
        rank:SetJustifyH("LEFT")
        self.Frames.professionRanks[professionName] = rank
        local note = CreateEditBox(editor, 440, 27, "")
        note:SetPoint("TOPLEFT", editor, "TOPLEFT", 278, y)
        note:SetMaxLetters(60)
        self.Frames.professionNotes[professionName] = note
    end

    local save = CreateButton(editor, "Save Services", 140, 34)
    save:SetPoint("BOTTOMRIGHT", editor, "BOTTOMRIGHT", -18, 15)
    save:SetScript("OnClick", function()
        TB:SaveProfessionEditor()
    end)
    local cancel = CreateButton(editor, "Cancel", 100, 34)
    cancel:SetPoint("RIGHT", save, "LEFT", -8, 0)
    cancel:SetScript("OnClick", function()
        TB.Frames.professionEditor:Hide()
        TB:SetStatus("Profession-service editing cancelled.")
    end)
end

function TB:OpenProfessionEditor()
    self:RefreshKnownProfessions()
    local published = {}
    local i
    for i = 1, table.getn(self.MyServices) do
        published[self.MyServices[i].profession] = self.MyServices[i]
    end
    for i = 1, table.getn(self.ProfessionNames) do
        local professionName = self.ProfessionNames[i]
        local known = self.KnownProfessions[professionName]
        local service = published[professionName]
        self.Frames.professionChecks[professionName]:SetCheckedValue(service and 1 or nil)
        self.Frames.professionRanks[professionName]:SetText(known and (known.rank .. "/" .. known.maxRank) or "Not learned")
        self.Frames.professionNotes[professionName]:SetText(service and service.note or "")
        if known then
            self.Frames.professionChecks[professionName].label:SetTextColor(0.90, 0.86, 0.76)
        else
            self.Frames.professionChecks[professionName].label:SetTextColor(0.48, 0.46, 0.42)
        end
    end
    self.Frames.professionEditor:Show()
    self:SetStatus("Choose which learned professions to publish and add optional notes.")
end

function TB:SaveProfessionEditor()
    self:RefreshKnownProfessions()
    local services = {}
    local i
    for i = 1, table.getn(self.ProfessionNames) do
        local professionName = self.ProfessionNames[i]
        local check = self.Frames.professionChecks[professionName]
        local known = self.KnownProfessions[professionName]
        if check.checked and known then
            table.insert(services, {
                profession = professionName,
                rank = known.rank,
                maxRank = known.maxRank,
                note = self.Frames.professionNotes[professionName]:GetText() or "",
            })
        end
    end
    local count = self:SaveOwnServices(services)
    self.Frames.professionEditor:Hide()
    if count == 0 then
        self:SetStatus("No profession services are currently published.")
    else
        self:SetStatus("Published " .. count .. (count == 1 and " profession service." or " profession services."))
    end
end

function TB:GetGuildProviderRankings()
    local byGuild = {}
    local i
    for i = 1, table.getn(self.Services) do
        local service = self.Services[i]
        if service.guild and service.guild ~= "" then
            local guildKey = string.lower(service.guild)
            local entry = byGuild[guildKey]
            if not entry then
                entry = { name = service.guild, providers = {}, count = 0 }
                byGuild[guildKey] = entry
            end
            local ownerKey = string.lower(service.owner or service.trader or "")
            if ownerKey ~= "" and not entry.providers[ownerKey] then
                entry.providers[ownerKey] = 1
                entry.count = entry.count + 1
            end
        end
    end

    local rankings = {}
    local key, entry
    for key, entry in pairs(byGuild) do
        table.insert(rankings, entry)
    end
    table.sort(rankings, function(a, b)
        if a.count == b.count then
            return string.lower(a.name) < string.lower(b.name)
        end
        return a.count > b.count
    end)
    return rankings
end

function TB:UpdateGuildProviderCards()
    if not self.Frames.guildCards then
        return
    end
    local rankings = self:GetGuildProviderRankings()
    local filterFound = nil
    local i
    for i = 1, 3 do
        local card = self.Frames.guildCards[i]
        local guild = rankings[i]
        if guild then
            card.guildName = guild.name
            card.providerTotal = guild.count
            card.icon:SetTexture(self:GetGuildSigilTexture(guild.name))
            card.guildLabel:SetText(guild.name)
            card.providerCount:SetText(guild.count .. (guild.count == 1 and " provider" or " providers"))
            if self.State.guildFilter and string.lower(self.State.guildFilter) == string.lower(guild.name) then
                card.selected:Show()
                card:SetBackdropBorderColor(0.95, 0.66, 0.18, 1)
                filterFound = 1
            else
                card.selected:Hide()
                card:SetBackdropBorderColor(0.38, 0.31, 0.17, 1)
            end
            card:Show()
        else
            card.guildName = nil
            card.providerTotal = 0
            card:Hide()
        end
    end
    if self.State.guildFilter and not filterFound then
        for i = 4, table.getn(rankings) do
            if string.lower(self.State.guildFilter) == string.lower(rankings[i].name) then
                filterFound = 1
                break
            end
        end
    end
    if self.State.guildFilter and not filterFound then
        self.State.guildFilter = nil
    end
end

function TB:GetFilteredServices()
    local filtered = {}
    local i
    for i = 1, table.getn(self.Services) do
        local service = self.Services[i]
        local professionMatches = self.State.profession == "All Services" or service.profession == self.State.profession
        local guildMatches = not self.State.guildFilter or string.lower(service.guild or "") == string.lower(self.State.guildFilter)
        if professionMatches and guildMatches then
            table.insert(filtered, service)
        end
    end
    table.sort(filtered, function(a, b)
        if (a.online and 1 or 0) ~= (b.online and 1 or 0) then
            return a.online and true or false
        end
        if a.profession == b.profession then
            if a.rank == b.rank then
                return string.lower(a.trader or "") < string.lower(b.trader or "")
            end
            return (a.rank or 0) > (b.rank or 0)
        end
        return string.lower(a.profession or "") < string.lower(b.profession or "")
    end)
    return filtered
end

function TB:UpdateProfessionRows(filtered)
    local total = table.getn(filtered)
    local maxOffset = total - 7
    if maxOffset < 0 then
        maxOffset = 0
    end
    if self.State.professionOffset > maxOffset then
        self.State.professionOffset = maxOffset
    elseif self.State.professionOffset < 0 then
        self.State.professionOffset = 0
    end
    local i
    for i = 1, 7 do
        local row = self.Frames.professionRows[i]
        local service = filtered[self.State.professionOffset + i]
        if service then
            row.service = service
            row.profession:SetText(service.profession)
            row.crafter:SetText(service.trader)
            row.guild:SetText(service.guild and service.guild ~= "" and service.guild or "-")
            row.skill:SetText(service.rank .. "/" .. service.maxRank)
            row.note:SetText(service.note ~= "" and service.note or "Available for work")
            if service.online then
                row.status:SetText("Online")
                row.status:SetTextColor(0.30, 1.00, 0.30)
                row:SetAlpha(1.00)
            else
                row.status:SetText("Last seen: " .. self:FormatLastSeen(service.lastSeenAt))
                row.status:SetTextColor(0.55, 0.55, 0.55)
                row:SetAlpha(0.48)
            end
            if self.State.selectedService == service then
                row.selected:Show()
            else
                row.selected:Hide()
            end
            row:Show()
        else
            row.service = nil
            row:Hide()
        end
    end
    local countText = total .. (total == 1 and " service" or " services")
    if self.State.guildFilter then
        countText = countText .. " / " .. self.State.guildFilter
    end
    self.Frames.professionCount:SetText(countText)
end

function TB:UpdateProfessions()
    if not self.Frames.professionRows then
        return
    end
    local professionName, button
    for professionName, button in pairs(self.Frames.professionButtons) do
        SetButtonSelected(button, professionName == self.State.profession)
    end
    self:UpdateGuildProviderCards()
    self:UpdateProfessionRows(self:GetFilteredServices())
end

function TB:CreateWorldLogPane(parent)
    local pane = CreateFrame("Frame", nil, parent)
    pane:SetAllPoints(parent)
    pane:Hide()
    self.Frames.worldLogPane = pane

    local title = CreateText(pane, "World WTS / WTB / LFW", "GameFontNormalLarge", 1.00, 0.78, 0.20)
    title:SetPoint("TOPLEFT", pane, "TOPLEFT", 8, -8)
    local subtitle = CreateText(pane, "Local World-channel archive for sales and crafting offers. Idea credit: Svenne :) | Saved across characters.", "GameFontHighlightSmall", 0.70, 0.67, 0.58)
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)

    local search = CreateEditBox(pane, 410, 28, self.State.worldSearch)
    search:SetPoint("TOPLEFT", pane, "TOPLEFT", 8, -50)
    search:SetScript("OnTextChanged", function()
        TB.State.worldSearch = this:GetText() or ""
        TB.State.worldOffset = 0
        TB:UpdateWorldLog()
    end)
    search:SetScript("OnEnterPressed", function() this:ClearFocus() end)
    self.Frames.worldSearch = search

    local searchHint = CreateText(pane, "Search message, character, or guild", "GameFontDisableSmall", 0.52, 0.50, 0.46)
    searchHint:SetPoint("LEFT", search, "RIGHT", 10, 0)

    self.Frames.worldTypeButtons = {}
    local types = { { "All", "ALL" }, { "WTS", "WTS" }, { "WTB", "WTB" }, { "LFW", "LFW" } }
    local previous = nil
    local i
    for i = 1, table.getn(types) do
        local value = types[i][2]
        local button = CreateButton(pane, types[i][1], 64, 27)
        if previous then button:SetPoint("LEFT", previous, "RIGHT", 6, 0) else button:SetPoint("TOPRIGHT", pane, "TOPRIGHT", -274, -50) end
        button:SetScript("OnClick", function()
            TB.State.worldType = value
            TB.State.worldOffset = 0
            TB:UpdateWorldLog()
        end)
        self.Frames.worldTypeButtons[value] = button
        previous = button
    end

    local panel = CreatePanel(pane, 912, 448)
    panel:SetPoint("TOPLEFT", pane, "TOPLEFT", 8, -87)
    panel:EnableMouseWheel(1)
    panel:SetScript("OnMouseWheel", function()
        local filtered = TB:GetFilteredWorldLog()
        local maxOffset = table.getn(filtered) - TB.MAX_WORLD_ROWS
        if maxOffset < 0 then maxOffset = 0 end
        if arg1 > 0 then TB.State.worldOffset = TB.State.worldOffset - 1 else TB.State.worldOffset = TB.State.worldOffset + 1 end
        if TB.State.worldOffset < 0 then TB.State.worldOffset = 0 end
        if TB.State.worldOffset > maxOffset then TB.State.worldOffset = maxOffset end
        TB:UpdateWorldLog()
    end)
    self.Frames.worldLogRows = {}

    for i = 1, self.MAX_WORLD_ROWS do
        local row = CreateFrame("Frame", nil, panel)
        row:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -8 - ((i - 1) * 53))
        row:SetWidth(896)
        row:SetHeight(50)
        row:SetBackdrop(PANEL_BACKDROP)
        row:SetBackdropColor(math.mod(i, 2) == 0 and 0.050 or 0.025, 0.025, 0.020, 0.90)
        row:SetBackdropBorderColor(0.25, 0.22, 0.16, 1)

        row.meta = CreateText(row, "", "GameFontNormalSmall", 1.00, 0.74, 0.22)
        row.meta:SetPoint("TOPLEFT", row, "TOPLEFT", 7, -5)
        row.meta:SetWidth(884)
        row.meta:SetJustifyH("LEFT")
        row.message = CreateText(row, "", "GameFontHighlightSmall", 0.92, 0.90, 0.84)
        row.message:SetPoint("TOPLEFT", row, "TOPLEFT", 7, -23)
        row.message:SetWidth(610)
        row.message:SetJustifyH("LEFT")
        row.itemButtons = {}
        local itemIndex
        for itemIndex = 1, 3 do
            local itemButton = CreateFrame("Button", nil, row)
            itemButton:SetWidth(86)
            itemButton:SetHeight(20)
            itemButton:SetPoint("TOPRIGHT", row, "TOPRIGHT", -5 - ((itemIndex - 1) * 89), -25)
            itemButton.text = CreateText(itemButton, "", "GameFontHighlightSmall")
            itemButton.text:SetAllPoints(itemButton)
            itemButton.text:SetJustifyH("RIGHT")
            itemButton:SetScript("OnEnter", function()
                if this.itemLink then
                    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                    local hyperlink = TB:GetListingTooltipHyperlink({ itemLink = this.itemLink })
                    if hyperlink then GameTooltip:SetHyperlink(hyperlink) end
                    GameTooltip:Show()
                end
            end)
            itemButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
            itemButton:SetScript("OnClick", function()
                if not this.itemLink then return end
                if IsShiftKeyDown() and ChatFrameEditBox and ChatFrameEditBox:IsShown() then
                    ChatFrameEditBox:Insert(this.itemLink)
                elseif SetItemRef then
                    local hyperlink = TB:GetListingTooltipHyperlink({ itemLink = this.itemLink })
                    if hyperlink then SetItemRef(hyperlink, this.itemLink, "LeftButton") end
                end
            end)
            row.itemButtons[itemIndex] = itemButton
        end
        self.Frames.worldLogRows[i] = row
    end

    local count = CreateText(pane, "0 captured messages", "GameFontHighlightSmall", 0.80, 0.75, 0.64)
    count:SetPoint("BOTTOMLEFT", pane, "BOTTOMLEFT", 10, 2)
    self.Frames.worldLogCount = count
    local scroll = CreateText(pane, "SCROLL: use mouse wheel over the message list", "GameFontNormalSmall", 1.00, 0.72, 0.20)
    scroll:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", -10, 2)
end

function TB:UpdateWorldLog()
    if not self.Frames.worldLogRows then return end
    local filtered = self:GetFilteredWorldLog()
    local total = table.getn(filtered)
    local maxOffset = total - self.MAX_WORLD_ROWS
    if maxOffset < 0 then maxOffset = 0 end
    if self.State.worldOffset > maxOffset then self.State.worldOffset = maxOffset end
    if self.State.worldOffset < 0 then self.State.worldOffset = 0 end
    local typeName, button
    for typeName, button in pairs(self.Frames.worldTypeButtons) do SetButtonSelected(button, typeName == self.State.worldType) end
    local i
    for i = 1, self.MAX_WORLD_ROWS do
        local entry = filtered[total - self.State.worldOffset - i + 1]
        local row = self.Frames.worldLogRows[i]
        if entry then
            local stamp = date and date("%m-%d %H:%M", entry.timestamp) or tostring(entry.timestamp)
            local guild = entry.guild and entry.guild ~= "" and (" <" .. entry.guild .. ">") or ""
            local level = entry.level and (" L" .. entry.level) or " L?"
            local typeColor = entry.type == "WTS" and "66ff66" or (entry.type == "WTB" and "ffcc55" or "66ccff")
            row.meta:SetText(stamp .. "  |cff" .. typeColor .. entry.type .. "|r  " .. entry.sender .. level .. guild)
            row.message:SetText(entry.message)
            local itemIndex
            for itemIndex = 1, 3 do
                local itemButton = row.itemButtons[itemIndex]
                local link = entry.items and entry.items[itemIndex]
                if link then itemButton.itemLink = link; itemButton.text:SetText(link); itemButton:Show() else itemButton.itemLink = nil; itemButton:Hide() end
            end
            row:Show()
        else
            row:Hide()
        end
    end
    self.Frames.worldLogCount:SetText(total .. (total == 1 and " captured message" or " captured messages"))
end

function TB:SetActiveTab(tabName)
    self.State.activeTab = tabName
    if tabName ~= "My Listings" then
        self.bagPickMode = nil
    end
    self.Frames.browsePane:Hide()
    self.Frames.myListingsPane:Hide()
    self.Frames.tradeChainsPane:Hide()
    self.Frames.professionsPane:Hide()
    self.Frames.worldLogPane:Hide()

    if tabName == "Browse" then
        self.Frames.browsePane:Show()
        self:UpdateBrowse()
    elseif tabName == "My Listings" then
        self.Frames.myListingsPane:Show()
        self:UpdateListingEditor()
        self:UpdateMyListings()
    elseif tabName == "Trade Chains" then
        self.Frames.tradeChainsPane:Show()
        self:UpdateTradeChains()
    elseif tabName == "Professions" then
        self.Frames.professionsPane:Show()
        self:UpdateProfessions()
    else
        self.Frames.worldLogPane:Show()
        self:UpdateWorldLog()
    end

    local name, tab
    for name, tab in pairs(self.Frames.tabs) do
        SetButtonSelected(tab, name == tabName)
    end
end

function TB:SyncFilterControls()
    local state = self.State
    self.Frames.searchField:SetText(state.search or "")
    self.Frames.rangeCheck:SetCheckedValue(state.myLevelRange)
    self.Frames.onlineCheck:SetCheckedValue(state.onlineOnly)

    if state.minLevel and state.minLevel > 0 then
        self.Frames.minLevel:SetText(tostring(state.minLevel))
    else
        self.Frames.minLevel:SetText("")
    end
    if state.maxLevel and state.maxLevel > 0 then
        self.Frames.maxLevel:SetText(tostring(state.maxLevel))
    else
        self.Frames.maxLevel:SetText("")
    end

    local quality
    for quality = 1, 5 do
        self.Frames.rarityChecks[quality]:SetCheckedValue(state.rarities[quality])
    end
end

function TB:UpdateBrowse()
    local state = self.State
    state.search = self.Frames.searchField:GetText() or ""
    state.minLevel = tonumber(self.Frames.minLevel:GetText()) or 0
    state.maxLevel = tonumber(self.Frames.maxLevel:GetText()) or 0

    self.Frames.rangeCheck.label:SetText(self:GetTraderRangeLabel())
    if state.levelType == "required" then
        self.Frames.levelTypeButton.label:SetText("Required Level")
    else
        self.Frames.levelTypeButton.label:SetText("Item Level")
    end

    self:RefreshCategoryPanel()

    local listingType, typeButton
    for listingType, typeButton in pairs(self.Frames.listingTypeButtons) do
        SetButtonSelected(typeButton, listingType == state.listingType)
    end

    local sortKey, sortHeader
    for sortKey, sortHeader in pairs(self.Frames.sortHeaders) do
        if sortKey == state.sortKey then
            sortHeader.arrow:Show()
            sortHeader.label:SetTextColor(1.00, 0.86, 0.32)
            if state.sortAscending then
                sortHeader.arrow:SetTexCoord(0, 0.5625, 1.0, 0)
            else
                sortHeader.arrow:SetTexCoord(0, 0.5625, 0, 1.0)
            end
        else
            sortHeader.arrow:Hide()
            sortHeader.label:SetTextColor(0.92, 0.78, 0.45)
        end
    end

    local filtered = self:GetFilteredListings()
    local maxOffset = table.getn(filtered) - self.MAX_VISIBLE_ROWS
    if maxOffset < 0 then
        maxOffset = 0
    end
    if state.browseOffset > maxOffset then
        state.browseOffset = maxOffset
    end
    if state.browseOffset < 0 then
        state.browseOffset = 0
    end

    self:UpdateBrowseRows(filtered)
end

function TB:UpdateBrowseRows(filtered)
    local total = table.getn(filtered)
    local offset = self.State.browseOffset
    local i

    for i = 1, self.MAX_VISIBLE_ROWS do
        local row = self.Frames.resultRows[i]
        local listing = filtered[offset + i]
        if listing then
            local cachedName, cachedLink, cachedQuality, cachedItemLevel, cachedRequired, cachedType, cachedSubType, cachedStack, cachedEquip, cachedTexture = GetItemInfo(listing.itemLink)
            if cachedName then
                listing.name = cachedName
                listing.itemLink = cachedLink or listing.itemLink
            end
            if cachedTexture then
                listing.texture = cachedTexture
            end
            local info = self.Quality[listing.quality] or self.Quality[1]
            row.listing = listing
            row.icon:SetTexture(listing.texture or "Interface\\Icons\\INV_Misc_QuestionMark")
            if listing.orderType == "BUY" then
                row.itemName:SetText("WTB: " .. listing.name)
            else
                row.itemName:SetText(listing.name)
            end
            row.itemName:SetTextColor(info.r, info.g, info.b)
            row.quantity:SetText(tostring(listing.quantity))
            row.required:SetText(tostring(listing.requiredLevel))
            row.itemLevel:SetText(tostring(listing.itemLevel))
            row.price:SetText(self:FormatMoney(listing.unitPrice))
            row.trader:SetText(listing.trader)
            row.guild:SetText(listing.guild and listing.guild ~= "" and listing.guild or "-")
            row.traderLevel:SetText(tostring(listing.traderLevel))
            if listing.online then
                row.status:SetText("Online")
                row.status:SetTextColor(0.20, 1.00, 0.20)
                row:SetAlpha(1.00)
            else
                row.status:SetText("Seen " .. self:FormatLastSeen(listing.lastSeenAt))
                row.status:SetTextColor(0.55, 0.55, 0.55)
                row:SetAlpha(0.48)
            end
            if self.State.selectedListing == listing then
                row.selected:Show()
            else
                row.selected:Hide()
            end
            row:Show()
        else
            row.listing = nil
            row:Hide()
        end
    end

    local activeTotal = table.getn(self.Listings)
    local hidden = activeTotal - total
    if hidden > 0 then
        self.Frames.resultCount:SetText(total .. " matching / " .. activeTotal .. " active (filters hide " .. hidden .. ")")
    elseif total == 1 then
        self.Frames.resultCount:SetText("1 matching listing")
    else
        self.Frames.resultCount:SetText(total .. " matching listings")
    end
end

function TB:UpdateTradeChains()
    local index = self.State.selectedChain
    local chain = index and self.Chains[index]
    if not chain then
        if table.getn(self.Chains) > 0 then
            index = 1
            self.State.selectedChain = 1
            chain = self.Chains[1]
        else
            self.State.selectedChain = nil
        end
    end

    local i
    local maxOffset = table.getn(self.Chains) - 8
    if maxOffset < 0 then
        maxOffset = 0
    end
    if self.State.chainOffset > maxOffset then
        self.State.chainOffset = maxOffset
    end
    if index and index <= self.State.chainOffset then
        self.State.chainOffset = index - 1
    elseif index and index > self.State.chainOffset + 8 then
        self.State.chainOffset = index - 8
    end
    for i = 1, 8 do
        local chainButton = self.Frames.chainButtons[i]
        local chainIndex = self.State.chainOffset + i
        if self.Chains[chainIndex] then
            chainButton.chainIndex = chainIndex
            chainButton.label:SetText(self.Chains[chainIndex].name)
            SetButtonSelected(chainButton, chainIndex == index)
            chainButton:Show()
        else
            chainButton.chainIndex = nil
            chainButton:Hide()
        end
    end

    if not chain then
        self.Frames.chainTitle:SetText("No trade chains listed yet")
        for i = 1, 12 do
            local emptyNode = self.Frames.chainNodes[i]
            emptyNode.level:SetText("Lv " .. (i * 5))
            emptyNode.memberName:SetText("Waiting...")
            emptyNode.dot:SetVertexColor(0.38, 0.38, 0.38)
            emptyNode:SetBackdropBorderColor(0.30, 0.28, 0.22, 1)
        end
        self.Frames.chainOnline:SetText("0/12 available")
        self.Frames.chainFilled:SetText("0/12 slots filled")
        self.Frames.chainFaction:SetText("Peer-synced")
        return
    end

    self.Frames.chainTitle:SetText(chain.name .. (chain.owner and (" - " .. chain.owner) or ""))
    local onlineCount = 0
    local filledCount = 0
    for i = 1, 12 do
        local member = chain.members[i]
        local node = self.Frames.chainNodes[i]
        node.level:SetText("Lv " .. member.level)
        node.memberName:SetText(member.name)
        if member.filled then
            filledCount = filledCount + 1
        end
        local memberOnline = member.online
        if not memberOnline and self.Network and self.Network.peers[string.lower(member.name or "")] then
            local peer = self.Network.peers[string.lower(member.name or "")]
            if GetTime() - peer.lastSeen < self.REMOTE_TTL then
                memberOnline = 1
            end
        end
        if memberOnline then
            onlineCount = onlineCount + 1
            node.dot:SetVertexColor(0.20, 1.00, 0.20)
            node:SetBackdropBorderColor(0.45, 0.55, 0.22, 1)
        else
            node.dot:SetVertexColor(0.38, 0.38, 0.38)
            node:SetBackdropBorderColor(0.30, 0.28, 0.22, 1)
        end
    end

    self.Frames.chainOnline:SetText(onlineCount .. "/12 available")
    if filledCount == 12 then
        self.Frames.chainFilled:SetText("Full 5-60 chain")
    else
        self.Frames.chainFilled:SetText(filledCount .. "/12 slots filled")
    end
    if chain.crossFaction then
        self.Frames.chainFaction:SetText("Cross-faction")
    else
        self.Frames.chainFaction:SetText("Same faction")
    end
end

function TB:Toggle()
    if self.Frames.main:IsShown() then
        self:Close()
    else
        self.Frames.main:Show()
        self:SetActiveTab(self.State.activeTab)
        self:ProbeAndSync()
        self.Network.nextOpenSync = GetTime() + self.AUTO_SYNC_INTERVAL
        self:SetStatus("Automatic sync requested; refreshes every minute while HC TradeBoard is open.")
    end
end

function TB:Initialize()
    self:CreateMainFrame()
    self:CreateMinimapButton()
    self:SyncFilterControls()
    self:SetActiveTab("Browse")
    self.Frames.main:Hide()
    self:InitializeNetwork()

    SLASH_TRADEBOARD1 = "/tradeboard"
    SLASH_TRADEBOARD2 = "/tb"
    SlashCmdList["TRADEBOARD"] = function(message)
        local command = string.lower(message or "")
        if command == "probe" or command == "sync" then
            TB:ProbeAndSync()
            TB:SetStatus("Peer probe and listing sync requested.")
        else
            TB:Toggle()
        end
    end

    local events = CreateFrame("Frame", nil, UIParent)
    events:RegisterEvent("VARIABLES_LOADED")
    events:RegisterEvent("PLAYER_ENTERING_WORLD")
    events:RegisterEvent("PLAYER_LEVEL_UP")
    events:SetScript("OnEvent", function()
        if event == "VARIABLES_LOADED" then
            if not TradeBoardDB then
                TradeBoardDB = {}
            end
            TB:SetMinimapButtonAngle(TradeBoardDB.minimapAngle or -2.52)
            TB:UpdateBrowse()
        elseif event == "PLAYER_ENTERING_WORLD" then
            TB:UpdateBrowse()
            if not TB.hasEnteredWorld then
                TB.hasEnteredWorld = 1
                DEFAULT_CHAT_FRAME:AddMessage(TB.COLORED_TITLE .. " loaded. Type |cffffffff/tb|r to open or |cffffffff/tb probe|r to resync.")
            end
        elseif event == "PLAYER_LEVEL_UP" then
            TB:RefreshOwnListingLevels(arg1)
            TB:QueueOwnData(0)
            TB:UpdateBrowse()
        end
    end)
end

TB:Initialize()
