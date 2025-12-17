--***********************************************************
--**              	  VORSHIM                       **
--***********************************************************

ISPlayerSafehousesListUI = ISPanel:derive("ISPlayerSafehousesListUI");
ISPlayerSafehousesListUI.messages = {};

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

--************************************************************************--
--** ISPlayerSafehousesListUI:initialise
--**
--************************************************************************--

function ISPlayerSafehousesListUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    self.no = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_CraftUI_Close"), self, ISPlayerSafehousesListUI.onClick);
    self.no.internal = "CANCEL";
    self.no.anchorTop = false
    self.no.anchorBottom = true
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.no);

    local listY = 20 + FONT_HGT_MEDIUM + 20
    self.datas = ISScrollingListBox:new(10, listY, self.width - 20, self.height - padBottom - btnHgt - padBottom - listY);
    self.datas:initialise();
    self.datas:instantiate();
    self.datas.itemheight = FONT_HGT_SMALL + 2 * 2;
    self.datas.selected = 0;
    self.datas.joypadParent = self;
    self.datas.font = UIFont.NewSmall;
    self.datas.doDrawItem = self.drawDatas;
    self.datas.drawBorder = true;
    self:addChild(self.datas);


    self.viewBtn = ISButton:new(self:getWidth() - btnWid - 10,  self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_PlayerStats_View"), self, ISPlayerSafehousesListUI.onClick);
    self.viewBtn.internal = "VIEW";
    self.viewBtn.anchorTop = false
    self.viewBtn.anchorBottom = true
    self.viewBtn:initialise();
    self.viewBtn:instantiate();
    self.viewBtn.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.viewBtn);
    self.viewBtn.enable = false;

    self.searchField = ISTextEntryBox:new("", self.width/2 - 100/2, 40, 100, 10);
        self.searchField:initialise()
        self.searchField.tooltip = getText("ContextMenu_searchTip")
        self.searchField.onTextChange = function()
            local searchFilter = self.searchField:getInternalText()
            self:populateList(searchFilter)
        end
    self.searchField.backgroundColor = { r = 0, g = 0, b = 0, a = 1 }
    self:addChild(self.searchField)
    self.searchField:setVisible(true)

    self:populateList();

end

function ISPlayerSafehousesListUI:populateList(searchFilter)
    self.datas:clear();
    local username = self.player:getUsername();
    local ownerSafehouses = {}
    local memberSafehouses = {}

    local matchingSafehouses = {}
    local nonMatchingSafehouses = {}
    
    -- Separa le safehouse in due liste: owner e member
    for i = 0, SafeHouse.getSafehouseList():size() - 1 do
        local safe = SafeHouse.getSafehouseList():get(i);
        if safe:getOwner() == username then
            table.insert(ownerSafehouses, safe)
        elseif safe:getPlayers():contains(username) then --cambiare con playerallowed?
            table.insert(memberSafehouses, safe)
        end
    end
    
    -- Concatena le due liste con le safehouse del proprietario prima
    local sortedSafehouses = ownerSafehouses
    for _, safe in ipairs(memberSafehouses) do
        table.insert(sortedSafehouses, safe)
    end

    -- Filtra le safehouse in base al filtro di ricerca
    if searchFilter then
        -- Converti il filtro di ricerca in minuscolo per una comparazione case-insensitive
        local searchFilterLower = string.lower(searchFilter or "")
        for _, safe in ipairs(sortedSafehouses) do
            if string.find(string.lower(safe:getOwner()), searchFilterLower) then
                table.insert(matchingSafehouses, safe)
            else
                table.insert(nonMatchingSafehouses, safe)
            end
        end
        sortedSafehouses = matchingSafehouses
        for _, safe in ipairs(nonMatchingSafehouses) do
            table.insert(sortedSafehouses, safe)
        end
    end

    
    -- Aggiunge le safehouse ordinate alla lista
    for _, safe in ipairs(sortedSafehouses) do
        self.datas:addItem(safe:getTitle(), safe)
    end
end

function ISPlayerSafehousesListUI:drawDatas(y, item, alt)
    local a = 0.9;

--    self.parent.selectedSafehouse = nil;
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
        self.parent.viewBtn.enable = true;
        self.parent.selectedSafehouse = item.item;
    end

    self:drawText(item.item:getTitle() .. " - " .. getText("IGUI_FactionUI_FactionsListPlayers", item.item:getPlayers():size() + 1, item.item:getOwner()), 10, y + 2, 1, 1, 1, a, self.font);

    return y + self.itemheight;
end

function ISPlayerSafehousesListUI:prerender()
    local z = 20;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_AdminPanel_SeeSafehouses"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_AdminPanel_SeeSafehouses")) / 2), z, 1,1,1,1, UIFont.Medium);
    z = z + 30;
end

function ISPlayerSafehousesListUI:render()

    if self.searchField:isVisible() then
        local x
        local y
        x = 85
        y = 3
        self.searchField:drawTexture(getTexture("media/ui/searchicon.png"), x, y, 1, 1, 1, 1)
    end
end

function ISPlayerSafehousesListUI:onClick(button)
    if button.internal == "CANCEL" then
        self:close()
    end
    if button.internal == "VIEW" then
        local safehouseUI = ISSafehouseUI:new(getCore():getScreenWidth() / 2 - 250,getCore():getScreenHeight() / 2 - 225, 500, 450, self.selectedSafehouse, self.player);
        safehouseUI:initialise()
        safehouseUI:addToUIManager()
    end
end

function ISPlayerSafehousesListUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    ISPlayerSafehousesListUI.instance = nil
end

--************************************************************************--
--** ISPlayerSafehousesListUI:new
--**
--************************************************************************--
function ISPlayerSafehousesListUI:new(x, y, width, height, player)
    local o = {}
    x = getCore():getScreenWidth() / 2 - (width / 2);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self

    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.width = width;
    o.height = height;
    o.player = player;
    o.selectedFaction = nil;
    o.moveWithMouse = true;
    ISPlayerSafehousesListUI.instance = o;
    return o;
end

function ISPlayerSafehousesListUI.OnSafehousesChanged()
    if ISPlayerSafehousesListUI.instance then
        ISPlayerSafehousesListUI.instance:populateList()
    end
end

Events.OnSafehousesChanged.Add(ISPlayerSafehousesListUI.OnSafehousesChanged)

