--Well this is kind of hacky but it was the only way I could get it to work with BeardLib
Hooks:PostHook(Setup, "init_managers", "sdss_Setup_init_managers", function()	
	--The vanilla get_weapon_icon_path (as of Update 199 Mark II Hotfix 2)
	local function orig_BlackMarketManager_get_weapon_icon_path(self, weapon_id, cosmetics)
		local akimbo_gui_data = tweak_data.weapon[weapon_id] and tweak_data.weapon[weapon_id].akimbo_gui_data
		local use_cosmetics = cosmetics and cosmetics.id and cosmetics.id ~= "nil" and true or false
		local data = use_cosmetics and tweak_data.blackmarket.weapon_skins or tweak_data.weapon
		local id = use_cosmetics and cosmetics.id or akimbo_gui_data and akimbo_gui_data.weapon_id or weapon_id
		local path = use_cosmetics and "weapon_skins/" or "textures/pd2/blackmarket/icons/weapons/"
		local weapon_tweak = data and id and data[id]
		local texture_path, rarity_path = nil

		if weapon_tweak then
			local guis_catalog = "guis/"
			local bundle_folder = weapon_tweak.texture_bundle_folder

			if bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
			end

			local texture_name = weapon_tweak.texture_name or tostring(id)
			texture_path = guis_catalog .. path .. texture_name

			if use_cosmetics then
				if weapon_tweak.color then
					rarity_path = guis_catalog .. "textures/pd2/blackmarket/icons/rarity_color"
					texture_path = self:get_weapon_icon_path(weapon_id, nil)
				else
					local rarity = weapon_tweak.rarity or "common"
					rarity_path = tweak_data.economy.rarities[rarity] and tweak_data.economy.rarities[rarity].bg_texture
				end
			end
		end

		return texture_path, rarity_path
	end
	
	--New get_weapon_icon_path, retains support for BeardLib's universal skin icons
	function BlackMarketManager:get_weapon_icon_path(weapon_id, cosmetics)
		--Handle BeardLib's universal skin icons, only use in weapon modification menu
        local use_cosmetics = cosmetics and cosmetics.id and cosmetics.id ~= "nil" and true or false
        local data = use_cosmetics and tweak_data.blackmarket.weapon_skins or tweak_data.weapon
        local id = use_cosmetics and cosmetics.id or weapon_id
		if data and id and data[id] then
			if use_cosmetics then
                if data[id].universal then
					local open_menus = managers.menu._open_menus
					local open_menu = (#open_menus >= 1) and open_menus[#open_menus]
					local node_name = open_menu and open_menu.logic:selected_node() and open_menu.logic:selected_node_name()
					local rarity = data[id].rarity or "common"
					local rarity_path = tweak_data.economy.rarities[rarity] and tweak_data.economy.rarities[rarity].bg_texture
					local texture_path = nil
					if node_name ~= "blackmarket_crafting_node" then
						--Use SDSS method when not in weapon mod menu, show gun over rarity
						texture_path = self:get_weapon_icon_path(weapon_id, nil)
					else
						--Use universal icon in weapon mod menu, copied from BeardLib
						local path = use_cosmetics and "weapon_skins/" or "textures/pd2/blackmarket/icons/weapons/"
						local guis_catalog = "guis/"
						local bundle_folder = data[id].texture_bundle_folder
						if bundle_folder then
							guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
						end
						texture_path = guis_catalog .. path .. data[id].universal_id
						return texture_path, rarity_path
					end
					return texture_path, rarity_path
				end
			end
		end
		--SDSS
		local id = cosmetics and cosmetics.id
		if id then
			local weapon_skin = tweak_data.blackmarket.weapon_skins[id]
			if weapon_skin then
				--Fix mistake in dump
				--Check if right weapon
				local found_weapon = (weapon_skin.weapon_ids and table.contains(weapon_skin.weapon_ids, weapon_id)) or (weapon_skin.weapon_id and weapon_skin.weapon_id == weapon_id)
				if weapon_skin.use_blacklist then
					found_weapon = not found_weapon
				end
				--Don't swap icons in modify weapon screen. Adapted from SSS
				if not found_weapon then
					local open_menus = managers.menu._open_menus
					local open_menu = (#open_menus >= 1) and open_menus[#open_menus]
					local node_name = open_menu and open_menu.logic:selected_node() and open_menu.logic:selected_node_name()
					--Note: icons are wrong when modify weapon screen is first opened. Use delayed call to refresh.
					if node_name == "blackmarket_crafting_node" then
						found_weapon = true
					end
				end
				--Wrong weapon, put default icon over rarity
				if not found_weapon then
					local rarity = weapon_skin.rarity or "common"
					local rarity_path = tweak_data.economy.rarities[rarity] and tweak_data.economy.rarities[rarity].bg_texture
					local texture_path = self:get_weapon_icon_path(weapon_id, nil)
					return texture_path, rarity_path
				end
			end
		end
		--Otherwise use original
		return orig_BlackMarketManager_get_weapon_icon_path(self, weapon_id, cosmetics)
	end
end)
