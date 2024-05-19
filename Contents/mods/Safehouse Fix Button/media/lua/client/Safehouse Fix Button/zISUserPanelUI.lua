-- Salva la funzione originale
local ISUserPanelUI_onOptionMouseDown_ext = ISUserPanelUI.onOptionMouseDown

-- Sovrascrivi la funzione onOptionMouseDown
function ISUserPanelUI:onOptionMouseDown(button, x, y)
    -- Verifica se il pulsante premuto è quello per le safehouse
    if button.internal == "SAFEHOUSEPANEL" then
        if ISSafehouseListUI.instance then
            ISSafehouseListUI.instance:close()
        end
        local ui = ISSafehouseListUI:new(50, 50, 600, 600, getPlayer());
        ui:initialise();
        ui:addToUIManager();
    else
        -- Richiama la funzione originale per gestire gli altri pulsanti
        ISUserPanelUI_onOptionMouseDown_ext(self, button, x, y)
    end
end





--***********************************************************
--**              	  VORSHIM                       **
--***********************************************************

ISSafehouseListUI = ISPanel:derive("ISSafehouseListUI");
ISSafehouseListUI.messages = {};

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

--************************************************************************--
--** ISSafehouseListUI:initialise
--**
--************************************************************************--

function ISSafehouseListUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    self.no = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_CraftUI_Close"), self, ISSafehouseListUI.onClick);
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


    self.viewBtn = ISButton:new(self:getWidth() - btnWid - 10,  self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_PlayerStats_View"), self, ISSafehouseListUI.onClick);
    self.viewBtn.internal = "VIEW";
    self.viewBtn.anchorTop = false
    self.viewBtn.anchorBottom = true
    self.viewBtn:initialise();
    self.viewBtn:instantiate();
    self.viewBtn.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.viewBtn);
    self.viewBtn.enable = false;

    self:populateList();

end

function ISSafehouseListUI:populateList()
    self.datas:clear();
    local username = self.player:getUsername();
    local ownerSafehouses = {}
    local memberSafehouses = {}
    
    -- Separa le safehouse in due liste: owner e member
    for i = 0, SafeHouse.getSafehouseList():size() - 1 do
        local safe = SafeHouse.getSafehouseList():get(i);
        if safe:getOwner() == username then
            table.insert(ownerSafehouses, safe)
        elseif safe:getPlayers():contains(username) then
            table.insert(memberSafehouses, safe)
        end
    end
    
    -- Concatena le due liste con le safehouse del proprietario prima
    local sortedSafehouses = ownerSafehouses
    for _, safe in ipairs(memberSafehouses) do
        table.insert(sortedSafehouses, safe)
    end
    
    -- Aggiunge le safehouse ordinate alla lista
    for _, safe in ipairs(sortedSafehouses) do
        self.datas:addItem(safe:getTitle(), safe)
    end
end

function ISSafehouseListUI:drawDatas(y, item, alt)
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

function ISSafehouseListUI:prerender()
    local z = 20;
    local splitPoint = 100;
    local x = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_AdminPanel_SeeSafehouses"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_AdminPanel_SeeSafehouses")) / 2), z, 1,1,1,1, UIFont.Medium);
    z = z + 30;
end

function ISSafehouseListUI:onClick(button)
    if button.internal == "CANCEL" then
        self:close()
    end
    if button.internal == "VIEW" then
        local safehouseUI = ISSafehouseUI:new(getCore():getScreenWidth() / 2 - 250,getCore():getScreenHeight() / 2 - 225, 500, 450, self.selectedSafehouse, self.player);
        safehouseUI:initialise()
        safehouseUI:addToUIManager()
    end
end

function ISSafehouseListUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    ISSafehouseListUI.instance = nil
end

--************************************************************************--
--** ISSafehouseListUI:new
--**
--************************************************************************--
function ISSafehouseListUI:new(x, y, width, height, player)
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
    ISSafehouseListUI.instance = o;
    return o;
end

function ISSafehouseListUI.OnSafehousesChanged()
    if ISSafehouseListUI.instance then
        ISSafehouseListUI.instance:populateList()
    end
end

Events.OnSafehousesChanged.Add(ISSafehouseListUI.OnSafehousesChanged)

