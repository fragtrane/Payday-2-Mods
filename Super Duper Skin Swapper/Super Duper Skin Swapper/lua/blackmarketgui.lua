dofile(ModPath .. "lua/setup.lua")

--New in v2.1
--Hide attachments the proper way lmao.
Hooks:PreHook(BlackMarketGui, "populate_mods", "sdss_pre_BlackMarketGui_populate_mods", function(self, data)
	if not SDSS._settings.sdss_allow_variants then
		--Hide Anarcho Barrel on Akimbo
		if data.prev_node_data and data.prev_node_data.name == "x_judge" and data.name == "barrel" then
			for index, mod_t in ipairs(data.on_create_data or {}) do
				if mod_t[1] == "wpn_fps_pis_judge_b_legend" then
					table.remove(data.on_create_data, index)
				end
			end
		end
		--Hide Anarcho Grip on Akimbo
		if data.prev_node_data and data.prev_node_data.name == "x_judge" and data.name == "grip" then
			for index, mod_t in ipairs(data.on_create_data or {}) do
				if mod_t[1] == "wpn_fps_pis_judge_g_legend" then
					table.remove(data.on_create_data, index)
				end
			end
		end
		--Hide Alamo Dallas Barrel on Akimbo
		if data.prev_node_data and data.prev_node_data.name == "x_p90" and data.name == "slide" then
			for index, mod_t in ipairs(data.on_create_data or {}) do
				if mod_t[1] == "wpn_fps_smg_p90_b_legend" then
					table.remove(data.on_create_data, index)
				end
			end
		end
	end
end)

--New in v2.0
--Set default weapon color wear, paint scheme, pattern scale when equipping weapon color
Hooks:PreHook(BlackMarketGui, "equip_weapon_color_callback", "sdss_pre_BlackMarketGui_equip_weapon_color_callback", function(self, data)
	--Set wear if setting is not "off"
	local wear = SDSS:get_multi_name("sdss_color_wear")
	if wear ~= "off" then
		data.cosmetic_quality = wear
	end
	
	--Set paint scheme, shift index by 1 because first option is "off"
	if SDSS._settings.sdss_paint_scheme > 1 then
		data.cosmetic_color_index = SDSS._settings.sdss_paint_scheme - 1
	end
	
	--Set pattern scale, shift index by 1 because first option is "off"
	--No restart required when equipping a weapon color
	--When changing from a weapon color which does not have pattern scale to one that does, the default weapon scale in BlackMarketTweakData is used.
	--We also overwrite that value in weaponskinstweakdata.lua (for that one a restart is required)
	--Actually we don't do that anymore, because that also affects some skins and not just weapon colors
	if SDSS._settings.sdss_pattern_scale > 1 then
		data.cosmetic_pattern_scale = SDSS._settings.sdss_pattern_scale - 1
	end
end)

--New in v2.0
--Also apply settings when previewing a weapon color
Hooks:PreHook(BlackMarketGui, "preview_cosmetic_on_weapon_callback", "sdss_pre_BlackMarketGui_preview_cosmetic_on_weapon_callback", function(self, data)
	if data.is_a_color_skin then
		local wear = SDSS:get_multi_name("sdss_color_wear")
		if wear ~= "off" then
			if data.is_a_color_skin then
				data.cosmetic_quality = wear
			end
		end
		
		if SDSS._settings.sdss_paint_scheme > 1 then
			data.cosmetic_color_index = SDSS._settings.sdss_paint_scheme - 1
		end
		
		if SDSS._settings.sdss_pattern_scale > 1 then
			data.cosmetic_pattern_scale = SDSS._settings.sdss_pattern_scale - 1
		end
	end
end)

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

--Mini skin icon in corner when a weapon with a swapped skin is selected
Hooks:PostHook(BlackMarketGui, "populate_weapon_category_new", "sdss_post_BlackMarketGui_populate_weapon_category_new", function(self, data)
	local category = data.category
	local crafted_category = managers.blackmarket:get_crafted_category(category) or {}
	
	local max_items = data.override_slots and data.override_slots[1] * data.override_slots[2] or 9
	local max_rows = tweak_data.gui.WEAPON_ROWS_PER_PAGE or 3
	max_items = max_rows * (data.override_slots and data.override_slots[1] or 3)
	
	for i = 1, max_items, 1 do
		local slot = data[i].slot
		if slot and crafted_category[slot] and crafted_category[slot].cosmetics and crafted_category[slot].cosmetics.id then
			local crafted = crafted_category[slot]
			local weapon_id = crafted.weapon_id
			local id = crafted.cosmetics.id
			local weapon_skin = tweak_data.blackmarket.weapon_skins[id]
			if weapon_skin then
				--Check that it's not a BeardLib universal skin
				if not weapon_skin.universal then
					--SDSS
					local found_weapon = (weapon_skin.weapon_ids and table.contains(weapon_skin.weapon_ids, weapon_id)) or (weapon_skin.weapon_id and weapon_skin.weapon_id == weapon_id)
					if weapon_skin.use_blacklist then
						found_weapon = not found_weapon
					end
					if not found_weapon then
						local guis_catalog = "guis/"
						local bundle_folder = weapon_skin.texture_bundle_folder
						if bundle_folder then
							guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
						end
						local texture_name = weapon_skin.texture_name or tostring(id)
						local path = "weapon_skins/"
						local texture_path = guis_catalog .. path .. texture_name
						
						local icon_list = managers.menu_component:create_weapon_mod_icon_list(crafted.weapon_id, category, crafted.factory_id, slot)
						data[i].mini_icons = data[i].mini_icons or {}
						table.insert(data[i].mini_icons, {
							stream = true,
							h = 24,--Scale down
							layer = 0,
							w = 48,--Scale down
							right = 0,--Move left
							texture = texture_path,
							bottom = math.floor((#icon_list - 1) / 11) * 25 + 24
						})
					end
				else
					--v2.0: BeardLib universal skins use weapon color system now so we don't need to do anything.
				end
			end
		end
	end
end)
