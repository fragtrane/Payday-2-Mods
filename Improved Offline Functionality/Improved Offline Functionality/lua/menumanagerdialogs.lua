dofile(ModPath .. "lua/setup.lua")

--Suppress inventory load failed dialog
local orig_MenuManager_show_inventory_load_fail_dialog = MenuManager.show_inventory_load_fail_dialog
function MenuManager:show_inventory_load_fail_dialog()
	if not Steam:logged_on() and IOF._settings.iof_inventory then
		return
	end
	orig_MenuManager_show_inventory_load_fail_dialog(self)
end
