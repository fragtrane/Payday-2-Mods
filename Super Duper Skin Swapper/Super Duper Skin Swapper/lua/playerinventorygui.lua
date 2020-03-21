dofile(ModPath .. "lua/setup.lua")

--Refresh icons after opening weapon modification menu
--0.1 too fast sometimes, better 0.25 to be safe
Hooks:PostHook(PlayerInventoryGui, "_open_crafting_node", "sdss_post_PlayerInventoryGui__open_crafting_node", function()
	DelayedCalls:Add("sdss_icon_refresh_2", 0.25, function()
		--Don't reload if not in crafting anymore
		if managers.menu_scene and managers.menu_scene:get_current_scene_template() == "blackmarket_crafting" then
			local bmg = managers.menu_component._blackmarket_gui
			bmg:reload()
		end
	end)
end)

--Clear useless/misleading stats from inventory loadout menu when skin mini-icon is highlighted
--Only affects first generation legendaries, other skins do not show anything since their default_blueprint was completely removed
Hooks:PostHook(PlayerInventoryGui, "_update_stats", "sdss_post_PlayerInventoryGui__update_stats", function(self, name)
	local box = self._boxes_by_name[name]
	if box and box.params and box.params.mod_data then
		if box.params.mod_data.selected_tab == "weapon_cosmetics" then
			local cosmetics = managers.blackmarket:get_weapon_cosmetics(box.params.mod_data.category, box.params.mod_data.slot)
			if cosmetics then
				self._info_panel:clear()
			end
		end
	end
end)
