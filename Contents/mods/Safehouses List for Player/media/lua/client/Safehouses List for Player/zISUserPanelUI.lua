-- Salva la funzione originale
local ISUserPanelUI_onOptionMouseDown_ext = ISUserPanelUI.onOptionMouseDown

-- Sovrascrivi la funzione onOptionMouseDown
function ISUserPanelUI:onOptionMouseDown(button, x, y)
    -- Verifica se il pulsante premuto è quello per le safehouse
    if button.internal == "SAFEHOUSEPANEL" then
        if ISPlayerSafehousesListUI.instance then
            ISPlayerSafehousesListUI.instance:close()
        end
        local ui = ISPlayerSafehousesListUI:new(50, 50, 600, 600, getPlayer());
        ui:initialise();
        ui:addToUIManager();
    else
        -- Richiama la funzione originale per gestire gli altri pulsanti
        ISUserPanelUI_onOptionMouseDown_ext(self, button, x, y)
    end
end