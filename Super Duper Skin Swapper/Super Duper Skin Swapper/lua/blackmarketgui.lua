dofile(ModPath .. "lua/setup.lua")

--Refresh icons after opening weapon modification menu
--0.1 too fast sometimes, better 0.25 to be safe
Hooks:PostHook(BlackMarketGui, "_open_crafting_node", "sdss_post_BlackMarketGui__open_crafting_node", function()
	DelayedCalls:Add("sdss_icon_refresh_1", 0.25, function()
		--Don't reload if not in crafting anymore
		if managers.menu_scene and managers.menu_scene:get_current_scene_template() == "blackmarket_crafting" then
			local bmg = managers.menu_component._blackmarket_gui
			bmg:reload()
		end
	end)
end)

--Add mod icons to legendary parts
Hooks:PostHook(BlackMarketGui, "populate_mods", "sdss_post_BlackMarketGui_populate_mods", function(self, data)
	local parts_tweak_data = tweak_data.weapon.factory.parts
	for index, _ in ipairs(data) do
		local mod_name = data[index].name
		if mod_name and parts_tweak_data[mod_name] and parts_tweak_data[mod_name].is_legendary_part then
			for skin, part_list in pairs(SDSS._gen_1_mods) do
				if table.contains(part_list, mod_name) then
					data[index].bitmap_texture = SDSS._gen_1_folders[skin]
					break
				end
			end
		end
	end
end)

--Clear useless/misleading stats of skins from weapon modification menu
--Only affects first generation legendaries, other skins do not show anything since their default_blueprint was completely removed
Hooks:PreHook(BlackMarketGui, "update_info_text", "sdss_pre_BlackMarketGui_update_info_text", function(self)
	local slot_data = self._slot_data
	local tab_data = self._tabs[self._selected]._data
	local prev_data = tab_data.prev_node_data
	local ids_category = Idstring(slot_data.category)
	local identifier = tab_data.identifier
	if identifier == self.identifiers.weapon_cosmetic then
		slot_data.comparision_data = nil
	end
end)
Hooks:PostHook(BlackMarketGui, "update_info_text", "sdss_post_BlackMarketGui_update_info_text", function(self)
	local slot_data = self._slot_data
	local tab_data = self._tabs[self._selected]._data
	local prev_data = tab_data.prev_node_data
	local ids_category = Idstring(slot_data.category)
	local identifier = tab_data.identifier
	if identifier == self.identifiers.weapon_cosmetic then
		self._stats_panel:hide()
	end
end)
