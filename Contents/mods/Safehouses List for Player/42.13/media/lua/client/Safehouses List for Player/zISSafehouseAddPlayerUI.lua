require "ISUI/UserPanel/ISSafehouseAddPlayerUI"
require "ISUI/UserPanel/ISSafehouseUI"
local original_ISSafehouseAddPlayerUI_populateList = ISSafehouseAddPlayerUI.populateList

function ISSafehouseAddPlayerUI:populateList()
    self.playerList:clear();
    if not self.scoreboard then return end
    for i=1,self.scoreboard.usernames:size() do
        local username = self.scoreboard.usernames:get(i-1)
        local displayName = self.scoreboard.displayNames:get(i-1)
        if self.safehouse:getOwner() ~= username then
            local newPlayer = {};
            newPlayer.username = username;
            local alreadySafe = self.safehouse:alreadyHaveSafehouse(username);
            -- if alreadySafe and alreadySafe ~= self.safehouse then
            --     if alreadySafe:getTitle() ~= "Safehouse" then
            --         newPlayer.tooltip = getText("IGUI_SafehouseUI_AlreadyHaveSafehouse", "(" .. alreadySafe:getTitle() .. ")");
            --     else
            --         newPlayer.tooltip = getText("IGUI_SafehouseUI_AlreadyHaveSafehouse" , "");
            --     end
            -- end
            local item = self.playerList:addItem(displayName, newPlayer);
            if newPlayer.tooltip then
               item.tooltip = newPlayer.tooltip;
            end
        end
    end
end

local original_ISSafehouseUI_ReceiveSafehouseInvite = ISSafehouseUI.ReceiveSafehouseInvite

ISSafehouseUI.ReceiveSafehouseInvite = function(safehouse, host)
    if ISSafehouseUI.inviteDialogs[host] then
        if ISSafehouseUI.inviteDialogs[host]:isReallyVisible() then return end
        ISSafehouseUI.inviteDialogs[host] = nil
    end

    if true then
        local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - 175,getCore():getScreenHeight() / 2 - 75, 350, 150, getText("IGUI_SafehouseUI_Invitation", host), true, nil, ISSafehouseUI.onAnswerSafehouseInvite);
        modal:initialise()
        modal:addToUIManager()
        modal.safehouse = safehouse;
        modal.host = host;
        modal.moveWithMouse = true;
        ISSafehouseUI.inviteDialogs[host] = modal
    end
end