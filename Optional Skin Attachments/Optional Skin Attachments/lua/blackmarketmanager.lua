dofile(ModPath .. "lua/setup.lua")

--Allow mods to be previewed on locked legendary skins
function BlackMarketManager:is_previewing_legendary_skin()
	return false
end

--OSA preview skin function
function BlackMarketManager:osa_view_weapon_with_cosmetics(category, slot, cosmetics, open_node_cb, spawn_workbench, custom_data)
	if not self._global.crafted_items[category] or not self._global.crafted_items[category][slot] then
		Application:error("[BlackMarketManager:view_weapon] Trying to view weapon that doesn't exist", category, slot)

		return
	end

	local weapon = self._global.crafted_items[category][slot]
	local blueprint = weapon.blueprint

	--Choose attachments
	if OSA._state_preview.attach == "keep" then
		blueprint = deep_clone(self._preview_blueprint.blueprint)
	elseif OSA._state_preview.attach == "replace" then
		if cosmetics and tweak_data.blackmarket.weapon_skins[cosmetics.id] then
			if tweak_data.blackmarket.weapon_skins[cosmetics.id].default_blueprint then
				blueprint = tweak_data.blackmarket.weapon_skins[cosmetics.id].default_blueprint
			end
		end
	elseif OSA._state_preview.attach == "remove" then
		blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(weapon.factory_id))
	end
	
	if cosmetics and tweak_data.blackmarket.weapon_skins[cosmetics.id] then
		self._last_viewed_cosmetic_id = cosmetics.id
	end
	
	--Rest unchanged
	self:get_preview_blueprint(category, slot)

	self._preview_blueprint.blueprint = deep_clone(blueprint)

	self:set_preview_cosmetics(category, slot, cosmetics)

	local texture_switches = self:get_weapon_texture_switches(category, slot, weapon)

	self:preload_weapon_blueprint("preview", weapon.factory_id, blueprint, spawn_workbench)

	if spawn_workbench then
		table.insert(self._preloading_list, {
			done_cb = function ()
				managers.menu_scene:spawn_workbench_room()
			end
		})
	end

	table.insert(self._preloading_list, {
		done_cb = function ()
			managers.menu_scene:spawn_item_weapon(weapon.factory_id, blueprint, cosmetics, texture_switches, custom_data)
		end
	})
	table.insert(self._preloading_list, {
		done_cb = open_node_cb
	})
end

--Buy mod function. Need to check settings and threshold before calling.
--Based on BlackMarketManager:add_to_inventory
function BlackMarketManager:osa_buy_mod(part_id)
	managers.custom_safehouse:deduct_coins(6)
	local parts_tweak_data = tweak_data.weapon.factory.parts
	local global_value = parts_tweak_data[part_id].dlc or "normal"
	local category = "weapon_mods"
	self._global.inventory[global_value] = self._global.inventory[global_value] or {}
	self._global.inventory[global_value][category] = self._global.inventory[global_value][category] or {}
	self._global.inventory[global_value][category][part_id] = (self._global.inventory[global_value][category][id] or 0) + 1
	self:alter_global_value_item(global_value, category, nil, part_id, INV_ADD)
	self:dispatch_event("added_to_inventory", part_id, category, global_value)
end

--Set OSA._skip_omw to skip this function when the skin is being applied.
--If we don't do this, we get crashes
local orig_BlackMarketManager__on_modified_weapon = BlackMarketManager._on_modified_weapon
function BlackMarketManager:_on_modified_weapon(category, slot)
	if OSA._skip_omw == true then
		return
	end
	orig_BlackMarketManager__on_modified_weapon(self, category, slot)
end

--Changed to call _osa_set_weapon_cosmetics
function BlackMarketManager:osa_on_equip_weapon_cosmetics(category, slot, instance_id)
	local item_data = self:get_inventory_tradable()[instance_id]
	
	if not item_data then
		local is_not_steam_inventory_item = tweak_data.blackmarket.weapon_skins[instance_id] and tweak_data.blackmarket.weapon_skins[instance_id].is_a_unlockable

		if is_not_steam_inventory_item then
			item_data = {
				quality = "mint",
				entry = instance_id
			}
		end
	end
	
	if item_data then
		self:_osa_set_weapon_cosmetics(category, slot, {
			id = item_data.entry,
			instance_id = instance_id,
			quality = item_data.quality,
			bonus = item_data.bonus or false
		}, true)
	end
end

--Changed to call _osa_set_weapon_cosmetics
function BlackMarketManager:osa_on_equip_weapon_color(category, slot, color_id, color_index, color_quality, update_weapon_unit)
	return self:_osa_set_weapon_cosmetics(category, slot, {
		bonus = false,
		id = color_id,
		instance_id = color_id,
		color_index = color_index,
		quality = color_quality
	}, update_weapon_unit)
end

--Most of the old on_equip_weapon_cosmetics function has been moved here
function BlackMarketManager:_osa_set_weapon_cosmetics(category, slot, cosmetics, update_weapon_unit)
	local crafted = self._global.crafted_items[category][slot]

	if not crafted then
		return
	end
	
	if not self:weapon_cosmetics_type_check(crafted.weapon_id, cosmetics.id) then
		return
	end
	
	local weapon_skin_data = tweak_data.blackmarket.weapon_skins[cosmetics.id]
	
	if not weapon_skin_data then
		return
	end
	
	--Blueprints
	local old_cosmetic_id = crafted.cosmetics and crafted.cosmetics.id
	local old_cosmetic_data = old_cosmetic_id and tweak_data.blackmarket.weapon_skins[old_cosmetic_id]
	--Blueprint of old skin (not old gun)
	local old_cosmetic_default_blueprint = old_cosmetic_data and old_cosmetic_data.default_blueprint
	--Blueprint of new skin, renamed for clarity
	local new_cosmetic_default_blueprint = weapon_skin_data.default_blueprint
	--Currently equipped attachments
	local gun_current_blueprint = deep_clone(crafted.blueprint)
	--Weapon default attachments
	local gun_default_blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id))
	
	--Initialize
	local customize_locked = weapon_skin_data.locked and not OSA._state_apply.unlock
	local parts_tweak_data = tweak_data.weapon.factory.parts
	--Skip update of mods until end (to prevent crashing)
	OSA._skip_omw = true
	--Initialize menu message
	local message = false
	
	--Handle three states: keep, replace, remove
	if OSA._state_apply.attach == "keep" then
		--Remove all mods
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
		crafted.global_values = nil--Just in case
		crafted.blueprint = deep_clone(gun_default_blueprint)
		
		--Setup
		local new_skin = {}--Mods that are included on the new skin
		local no_dlc = {}--Mods that have been removed due to lack of DLC
		local in_stock = {}--Mods that are in stock/available
		local out_of_stock = {}--Mods that are out of stock. Try to buy if possible.
		local not_available = {}--Mods that are out of stock and cannot be bought (unlockables)
		local legend = {}--Legendary parts (removed)
		
		--Step 1: Replace Community 000 Buckshot with Shotgun Pack if available.
		if OSA._settings.osa_prefer_sp_buck and managers.dlc:is_dlc_unlocked("gage_pack_shotgun") then
			if table.contains(gun_current_blueprint, "wpn_fps_upg_a_custom_free") then
				table.delete(gun_current_blueprint, "wpn_fps_upg_a_custom_free")
				table.insert(gun_current_blueprint, "wpn_fps_upg_a_custom")
			end
		end
		
		--Step 2: Delete parts that are part of the default blueprint.
		for _, part_id in ipairs(gun_default_blueprint) do
			table.delete(gun_current_blueprint, part_id)
		end
		
		--Step 3: Log parts that are included on the new skin. Delete from old list in second loop.
		for _, part_id in ipairs(gun_current_blueprint) do
			if table.contains(new_cosmetic_default_blueprint or {}, part_id) then
				table.insert(new_skin, part_id)
			end
		end
		for _, part_id in ipairs(new_skin) do
			table.delete(gun_current_blueprint, part_id)
		end
		
		--Step 4: Log parts that are not available anymore due to missing DLC. Delete from old list in second loop.
		--If Shotgun Pack is not owned, try to use the Community 000 Buckshot instead.
		for _, part_id in ipairs(gun_current_blueprint) do
			dlc = parts_tweak_data[part_id].dlc or "normal"
			if dlc ~= "normal" and not managers.dlc:is_dlc_unlocked(dlc) then
				table.insert(no_dlc, part_id)
			end
		end
		for _, part_id in ipairs(no_dlc) do
			table.delete(gun_current_blueprint, part_id)
		end
		if table.contains(no_dlc, "wpn_fps_upg_a_custom") then
			table.insert(gun_current_blueprint, "wpn_fps_upg_a_custom_free")
			table.delete(no_dlc, "wpn_fps_upg_a_custom")
		end
		
		--Step 5: Check which parts are available in inventory. Sort into four tables: in_stock, out_of_stock, not_available, legend
		for _, part_id in ipairs(gun_current_blueprint) do
			local g_v = parts_tweak_data[part_id].dlc or "normal"
			local amount = self._global.inventory[g_v]["weapon_mods"][part_id] or 0
			if amount > 0 then
				table.insert(in_stock, part_id)
			else
				if parts_tweak_data[part_id].is_a_unlockable then
					if parts_tweak_data[part_id].is_legendary_part then
						table.insert(legend, part_id)
					else
						table.insert(not_available, part_id)
					end
				else
					table.insert(out_of_stock, part_id)
				end
			end
		end
		
		--Step 6: Try to buy mods that are out of stock. If bought, move the part to in_stock table.
		if OSA._settings.osa_autobuy then
			for _, part_id in ipairs(out_of_stock) do
				if parts_tweak_data[part_id].type ~= "bonus" then
					local coins = math.floor(Application:digest_value(managers.custom_safehouse._global.total)) or 0
					--Don't autobuy if coins will drop below threshold.
					if coins-6  >= OSA._settings.osa_autobuy_threshold then
						self:osa_buy_mod(part_id)
						table.insert(in_stock, part_id)
					else
						--If coins will drop below threshold, stop because we can't buy anymore.
						break
					end
				end
			end
			for _, part_id in ipairs(in_stock) do
				table.delete(out_of_stock, part_id)
			end
		end
		
		--Step 7: Apply weapon mods. Use two passes because some mods depend on each other and may fail on the first pass.
		--First pass
		local new_skin_defer = {}
		local in_stock_defer = {}
		for _, part_id in pairs(new_skin) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, true)
			else
				table.insert(new_skin_defer, part_id)
			end
		end
		for _, part_id in pairs(in_stock) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(in_stock_defer, part_id)
			end
		end
		--Second pass
		for _, part_id in pairs(new_skin_defer) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, true)
			end
		end
		for _, part_id in pairs(in_stock_defer) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			end
		end
		--Clean up list so we know which mods failed
		for _, part_id in ipairs(crafted.blueprint) do
			table.delete(new_skin_defer, part_id)
			table.delete(in_stock_defer, part_id)
		end
		
		--Step 8: Build message for mods that could not be applied.
		if next(no_dlc) ~= nil or next(legend) ~= nil or next(not_available) ~= nil or next(out_of_stock) ~= nil or next(new_skin_defer) ~= nil or next(in_stock_defer) ~= nil then
			message = managers.localization:text("osa_dialog_could_not_keep")
		end
		--Missing DLC Parts
		if next(no_dlc) ~= nil then
			message = message.."\n\n"..managers.localization:text("osa_dialog_reason_dlc")..":"
			for _, part_id in ipairs(no_dlc) do
				message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
			end
		end
		--Legendary Parts
		if next(legend) ~= nil then
			message = message.."\n\n"..managers.localization:text("osa_dialog_reason_legendary")..":"
			for _, part_id in ipairs(legend) do
				message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
			end
		end
		--Unavailable parts (is_a_unlockable)
		if next(not_available) ~= nil then
			message = message.."\n\n"..managers.localization:text("osa_dialog_reason_unavailable")..":"
			for _, part_id in ipairs(not_available) do
				message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
			end
		end
		--Out of stock
		if next(out_of_stock) ~= nil then
			message = message.."\n\n"..managers.localization:text("osa_dialog_reason_stock")..":"
			for _, part_id in ipairs(out_of_stock) do
				message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
			end
		end
		--In stock or part of the new skin but cannot be used (incompatible)
		if next(new_skin_defer) ~= nil or next(in_stock_defer) ~= nil then
			message = message.."\n\n"..managers.localization:text("osa_dialog_reason_incompatible")..":"
			for _, part_id in ipairs(new_skin_defer) do
				message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
			end
			for _, part_id in ipairs(in_stock_defer) do
				message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
			end
		end
		
	elseif OSA._state_apply.attach == "replace" then
		--Clone directly if locked. If not locked, we can clone directly if we don't need to remove legendary parts and we don't have to swap 000.
		if customize_locked or (not OSA._state_apply.nolegend and not OSA._settings.osa_prefer_sp_buck) then
			self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
			crafted.global_values = nil--Just in case
			crafted.blueprint = deep_clone(new_cosmetic_default_blueprint)
		else
			--Otherwise, clone default and add parts
			self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
			crafted.global_values = nil--Just in case
			crafted.blueprint = deep_clone(gun_default_blueprint)
			
			--First pass
			local second_pass = {}
			for _, part_id in pairs(new_cosmetic_default_blueprint) do
				if parts_tweak_data[part_id].is_legendary_part then
					if not OSA._state_apply.nolegend then
						if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
							self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, true)
						else
							table.insert(second_pass, part_id)
						end
					end
				else
					if (part_id == "wpn_fps_upg_a_custom_free") and OSA._settings.osa_prefer_sp_buck and managers.dlc:is_dlc_unlocked("gage_pack_shotgun") then
						if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
							self:buy_and_modify_weapon(category, slot, parts_tweak_data["wpn_fps_upg_a_custom"].dlc or "normal", "wpn_fps_upg_a_custom", true, true)
						else
							table.insert(second_pass, part_id)
						end
					else
						if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
							self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, true)
						else
							table.insert(second_pass, part_id)
						end
					end
				end
			end
			--Second pass
			for _, part_id in pairs(second_pass) do
				if parts_tweak_data[part_id].is_legendary_part then
					if not OSA._state_apply.nolegend then
						if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
							self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, true)
						end
					end
				else
					if (part_id == "wpn_fps_upg_a_custom_free") and OSA._settings.osa_prefer_sp_buck and managers.dlc:is_dlc_unlocked("gage_pack_shotgun") then
						if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
							self:buy_and_modify_weapon(category, slot, parts_tweak_data["wpn_fps_upg_a_custom"].dlc or "normal", "wpn_fps_upg_a_custom", true, true)
						end
					else
						if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
							self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, true)
						end
					end
				end
			end
			--Build message for mods that could not be applied.
			for _, part_id in ipairs(crafted.blueprint) do
				table.delete(second_pass, part_id)
			end
			if next(second_pass) ~= nil then
				message = managers.localization:text("osa_dialog_could_not_keep")
				message = message.."\n\n"..managers.localization:text("osa_dialog_reason_incompatible")..":"
				for _, part_id in ipairs(second_pass) do
					message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
				end
			end
		end
		
	elseif OSA._state_apply.attach == "remove" then
		--Remove everything
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
		crafted.global_values = nil--Just in case
		crafted.blueprint = deep_clone(gun_default_blueprint)
	end
	
	--Enable update again
	OSA._skip_omw = false
	
	--Set crafted data
	--Check state to see if skin should be unlocked
	crafted.customize_locked = weapon_skin_data.locked and not OSA._state_apply.unlock
	--Check settings to see if rename is allowed
	crafted.locked_name = weapon_skin_data.rarity == "legendary" and not OSA._settings.osa_rename_legendary
	crafted.cosmetics = cosmetics
	--Overwrite bonus (bonus is always set in state)
	crafted.cosmetics.bonus = OSA._state_apply.boost
	
	--Rest unchanged except for showing the dialog menu
	if old_cosmetic_id then
		local global_value = old_cosmetic_data.global_value or managers.dlc:dlc_to_global_value(old_cosmetic_data.dlc)
		
		self:alter_global_value_item(global_value, category, slot, old_cosmetic_id, CRAFT_REMOVE)
	end
	
	if cosmetics.id then
		local global_value = weapon_skin_data.global_value or managers.dlc:dlc_to_global_value(weapon_skin_data.dlc)
		
		self:alter_global_value_item(global_value, category, slot, cosmetics.id, CRAFT_ADD)
	end
	
	if update_weapon_unit and managers.menu_scene then
		local data = category == "primaries" and self:equipped_primary() or self:equipped_secondary()
		
		if data then
			managers.menu_scene:set_character_equipped_weapon(nil, data.factory_id, data.blueprint, category == "primaries" and "primary" or "secondary", data.cosmetics)
			
			if managers.menu_scene:get_current_scene_template() == "blackmarket_crafting" then
				self:view_weapon(category, slot, function ()
				end, nil, BlackMarketGui.get_crafting_custom_data())
			end
		end
	end
	
	--Show message if not all mods were applied successfully
	if message then
		local title = managers.localization:text("osa_dialog_title")
		OSA:ok_menu(title, message, false, false)
	end
	
	MenuCallbackHandler:_update_outfit_information()
end

--OSA remove skin function
function BlackMarketManager:osa_on_remove_weapon_cosmetics(category, slot, skip_update)
	local crafted = self._global.crafted_items[category][slot]

	if not crafted then
		return
	end
	
	--Blueprints
	local old_cosmetic_id = crafted.cosmetics and crafted.cosmetics.id
	local old_cosmetic_data = old_cosmetic_id and tweak_data.blackmarket.weapon_skins[old_cosmetic_id]
	--Blueprint of old skin (not old gun)
	local old_cosmetic_default_blueprint = old_cosmetic_data and old_cosmetic_data.default_blueprint
	--Currently equipped attachments
	local gun_current_blueprint = deep_clone(crafted.blueprint)
	--Weapon default attachments
	local gun_default_blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id))
	
	--Initialize
	local parts_tweak_data = tweak_data.weapon.factory.parts
	--Skip update of mods until end (to prevent crashing)
	OSA._skip_omw = true
	--Initialize menu message
	local message = false
	
	--Handle two states: keep, remove
	if OSA._state_remove.keep then
		--Remove all mods
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
		crafted.global_values = nil--Just in case
		crafted.blueprint = deep_clone(gun_default_blueprint)
		
		--Setup
		local no_dlc = {}--Mods that have been removed due to lack of DLC
		local in_stock = {}--Mods that are in stock/available
		local out_of_stock = {}--Mods that are out of stock. Try to buy if possible.
		local not_available = {}--Mods that are out of stock and cannot be bought (unlockables)
		local legend = {}--Legendary parts (removed)
		
		--Step 1: Replace Community 000 Buckshot with Shotgun Pack if available.
		if OSA._settings.osa_prefer_sp_buck and managers.dlc:is_dlc_unlocked("gage_pack_shotgun") then
			if table.contains(gun_current_blueprint, "wpn_fps_upg_a_custom_free") then
				table.delete(gun_current_blueprint, "wpn_fps_upg_a_custom_free")
				table.insert(gun_current_blueprint, "wpn_fps_upg_a_custom")
			end
		end
		
		--Step 2: Delete parts that are part of the default blueprint.
		for _, part_id in ipairs(gun_default_blueprint) do
			table.delete(gun_current_blueprint, part_id)
		end
		
		--Step 3: Log parts that are included on the new skin. Delete from old list in second loop.
		--No new blueprint, go directly to step 4
		
		--Step 4: Log parts that are not available anymore due to missing DLC. Delete from old list in second loop.
		--If Shotgun Pack is not owned, try to use the Community 000 Buckshot instead.
		for _, part_id in ipairs(gun_current_blueprint) do
			dlc = parts_tweak_data[part_id].dlc or "normal"
			if dlc ~= "normal" and not managers.dlc:is_dlc_unlocked(dlc) then
				table.insert(no_dlc, part_id)
			end
		end
		for _, part_id in ipairs(no_dlc) do
			table.delete(gun_current_blueprint, part_id)
		end
		if table.contains(no_dlc, "wpn_fps_upg_a_custom") then
			table.insert(gun_current_blueprint, "wpn_fps_upg_a_custom_free")
			table.delete(no_dlc, "wpn_fps_upg_a_custom")
		end
		
		--Step 5: Check which parts are available in inventory. Sort into four tables: in_stock, out_of_stock, not_available, legend
		for _, part_id in ipairs(gun_current_blueprint) do
			local g_v = parts_tweak_data[part_id].dlc or "normal"
			local amount = self._global.inventory[g_v]["weapon_mods"][part_id] or 0
			if amount > 0 then
				table.insert(in_stock, part_id)
			else
				if parts_tweak_data[part_id].is_a_unlockable then
					if parts_tweak_data[part_id].is_legendary_part then
						table.insert(legend, part_id)
					else
						table.insert(not_available, part_id)
					end
				else
					table.insert(out_of_stock, part_id)
				end
			end
		end
		
		--Step 6: Try to buy mods that are out of stock. If bought, move the part to in_stock table.
		if OSA._settings.osa_autobuy then
			for _, part_id in ipairs(out_of_stock) do
				if parts_tweak_data[part_id].type ~= "bonus" then
					local coins = math.floor(Application:digest_value(managers.custom_safehouse._global.total)) or 0
					--Don't autobuy if coins will drop below threshold.
					if coins-6  >= OSA._settings.osa_autobuy_threshold then
						self:osa_buy_mod(part_id)
						table.insert(in_stock, part_id)
					else
						--If coins will drop below threshold, stop because we can't buy anymore.
						break
					end
				end
			end
			for _, part_id in ipairs(in_stock) do
				table.delete(out_of_stock, part_id)
			end
		end
		
		--Step 7: Apply weapon mods. Use two passes because some mods depend on each other and may fail on the first pass.
		--First pass
		local in_stock_defer = {}
		for _, part_id in pairs(in_stock) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(in_stock_defer, part_id)
			end
		end
		--Second pass
		for _, part_id in pairs(in_stock_defer) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			end
		end
		--Clean up list so we know which mods failed
		for _, part_id in ipairs(crafted.blueprint) do
			table.delete(in_stock_defer, part_id)
		end
		
		--Step 8: Build message for mods that could not be applied.
		if next(no_dlc) ~= nil or next(legend) ~= nil or next(not_available) ~= nil or next(out_of_stock) ~= nil or next(in_stock_defer) ~= nil then
			message = managers.localization:text("osa_dialog_could_not_keep")
		end
		--Missing DLC Parts
		if next(no_dlc) ~= nil then
			message = message.."\n\n"..managers.localization:text("osa_dialog_reason_dlc")..":"
			for _, part_id in ipairs(no_dlc) do
				message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
			end
		end
		--Legendary Parts
		if next(legend) ~= nil then
			message = message.."\n\n"..managers.localization:text("osa_dialog_reason_legendary")..":"
			for _, part_id in ipairs(legend) do
				message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
			end
		end
		--Unavailable parts (is_a_unlockable)
		if next(not_available) ~= nil then
			message = message.."\n\n"..managers.localization:text("osa_dialog_reason_unavailable")..":"
			for _, part_id in ipairs(not_available) do
				message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
			end
		end
		--Out of stock
		if next(out_of_stock) ~= nil then
			message = message.."\n\n"..managers.localization:text("osa_dialog_reason_stock")..":"
			for _, part_id in ipairs(out_of_stock) do
				message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
			end
		end
		--In stock or part of the new skin but cannot be used (incompatible)
		if next(in_stock_defer) ~= nil then
			message = message.."\n\n"..managers.localization:text("osa_dialog_reason_incompatible")..":"
			for _, part_id in ipairs(in_stock_defer) do
				message = message.."\n"..managers.localization:text(parts_tweak_data[part_id].name_id)
			end
		end
	else
		--Remove everything
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
		crafted.global_values = nil--Just in case
		crafted.blueprint = deep_clone(gun_default_blueprint)
	end
	
	--Enable update again
	OSA._skip_omw = false
	
	--Set crafted data
	crafted.customize_locked = nil
	crafted.cosmetics = nil
	--Bugfix: locked name is not reset when skin is removed in base game
	crafted.locked_name = nil
	
	--Bugfix: global value not removed?
	if old_cosmetic_id then
		local global_value = old_cosmetic_data.global_value or managers.dlc:dlc_to_global_value(old_cosmetic_data.dlc)
		
		self:alter_global_value_item(global_value, category, slot, old_cosmetic_id, CRAFT_REMOVE)
	end
	
	--Rest unchanged except for showing the dialog menu
	self:_verfify_equipped_category(category)
	
	if not skip_update then
		if managers.menu_scene then
			local data = category == "primaries" and self:equipped_primary() or self:equipped_secondary()
			
			if data then
				managers.menu_scene:set_character_equipped_weapon(nil, data.factory_id, data.blueprint, category == "primaries" and "primary" or "secondary", data.cosmetics)
				
				if managers.menu_scene:get_current_scene_template() == "blackmarket_crafting" then
					self:view_weapon(category, slot, function ()
					end, nil, BlackMarketGui.get_crafting_custom_data())
				end
			end
		end
		
		--Show message if not all mods were applied successfully
		if message then
			local title = managers.localization:text("osa_dialog_title")
			OSA:ok_menu(title, message, false, false)
		end
		
		MenuCallbackHandler:_update_outfit_information()
	end
end

--skip_update is set when the blackmarket does cleanup
--if skip_update and OSA._settings.osa_save_removed, try to keep as many attachments as we can
local orig_BlackMarketManager_on_remove_weapon_cosmetics = BlackMarketManager.on_remove_weapon_cosmetics
function BlackMarketManager:on_remove_weapon_cosmetics(category, slot, skip_update)
	if skip_update and OSA._settings.osa_save_removed then
		OSA._state_remove.keep = true
		self:osa_on_remove_weapon_cosmetics(category, slot, skip_update)
		return
	end
	
	orig_BlackMarketManager_on_remove_weapon_cosmetics(self, category, slot, skip_update)
	
	--Bugfix: locked name is not reset when skin is removed in base game
	local crafted = self._global.crafted_items[category][slot]
	if not crafted then
		return
	end
	crafted.locked_name = nil
	
	--Bugfix: global value not removed?
	local old_cosmetic_id = crafted.cosmetics and crafted.cosmetics.id
	local old_cosmetic_data = old_cosmetic_id and tweak_data.blackmarket.weapon_skins[old_cosmetic_id]
	if old_cosmetic_id then
		local global_value = old_cosmetic_data.global_value or managers.dlc:dlc_to_global_value(old_cosmetic_data.dlc)
		
		self:alter_global_value_item(global_value, category, slot, old_cosmetic_id, CRAFT_REMOVE)
	end
end
