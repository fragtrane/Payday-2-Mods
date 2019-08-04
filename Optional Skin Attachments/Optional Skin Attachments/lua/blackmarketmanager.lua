dofile(ModPath .. "lua/setup.lua")

--This lets us preview mods on legendary skins if unlock is enabled.
function BlackMarketManager:is_previewing_legendary_skin()
	if OSA._settings.osa_allow_unlock then
		return false
	end
	return tweak_data.blackmarket.weapon_skins[self._last_viewed_cosmetic_id] and tweak_data.blackmarket.weapon_skins[self._last_viewed_cosmetic_id].locked or false
end

--Buy mod function. Need to check settings and threshold before calling.
--Based on BlackMarketManager:add_to_inventory
function BlackMarketManager:osa_buy_mod(part_id)
	managers.custom_safehouse:add_coins(-6)
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

--OSA equip skin function
function BlackMarketManager:osa_on_equip_weapon_cosmetics(category, slot, instance_id)
	local crafted = self._global.crafted_items[category][slot]

	if not crafted then
		return
	end

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

	if not item_data then
		return
	end

	if not self:weapon_cosmetics_type_check(crafted.weapon_id, item_data.entry) then
		return
	end

	local weapon_skin = tweak_data.blackmarket.weapon_skins[item_data.entry]
	local blueprint = weapon_skin.default_blueprint
	local customize_locked = weapon_skin.locked
	local locked_name = weapon_skin.rarity == "legendary"
	local bonus = item_data.bonus
	local quality = item_data.quality

	--OSA Overrides
	--Check settings to see if rename is allowed
	locked_name = locked_name and not OSA._settings.osa_rename_legendary
	--Check state to see if skin should be unlocked
	customize_locked = customize_locked and not OSA._state_apply.unlock
	--Overwrite bonus (bonus is always set in state)
	bonus = OSA._state_apply.boost
	
	--Skip update of mods until end (to prevent crashing)
	OSA._skip_omw = true
	--Initialize menu message
	local message = false
	
	--Handle three states: keep, replace, remove
	if OSA._state_apply.attach == "keep" then
		--Save blueprints
		local old_blueprint = deep_clone(self._global.crafted_items[category][slot].blueprint)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(self._global.crafted_items[category][slot].factory_id)
		local old_skin_blueprint = crafted.cosmetics and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint or {}
		
		--Remove all mods
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, crafted.cosmetics and crafted.cosmetics.id and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id] and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint)
		self._global.crafted_items[category][slot].global_values = nil--Just in case
		crafted.blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id))
		
		--Setup
		local parts_tweak_data = tweak_data.weapon.factory.parts
		local new_skin = {}--Mods that are included on the new skin
		local no_dlc = {}--Mods that have been removed due to lack of DLC
		local in_stock = {}--Mods that are in stock/available
		local out_of_stock = {}--Mods that are out of stock. Try to buy if possible.
		local not_available = {}--Mods that are out of stock and cannot be bought (unlockables)
		local legend = {}--Legendary parts (removed)
		
		--Step 1: Replace Community 000 Buckshot with Shotgun Pack if available.
		if OSA._settings.osa_prefer_sp_buck and managers.dlc:is_dlc_unlocked("gage_pack_shotgun") then
			local use_sp_buck = false
			for _, part_id in ipairs(old_blueprint) do
				if part_id == "wpn_fps_upg_a_custom_free" then
					use_sp_buck = true
					break
				end
			end
			if use_sp_buck then
				table.delete(old_blueprint, "wpn_fps_upg_a_custom_free")
				table.insert(old_blueprint, "wpn_fps_upg_a_custom")
			end
		end
		
		--Step 2: Delete parts that are part of the default blueprint.
		for _, part_id in ipairs(default_blueprint) do
			table.delete(old_blueprint, part_id)
		end
		
		--Step 3: Log parts that are included on the new skin. Delete from old list in second loop.
		for _, old_part_id in ipairs(old_blueprint) do
			for _, part_id in ipairs(blueprint or {}) do
				if old_part_id == part_id then
					table.insert(new_skin, part_id)
					break
				end
			end
		end
		for _, part_id in ipairs(new_skin) do
			table.delete(old_blueprint, part_id)
		end
		
		--Step 4: Log parts that are not available anymore due to missing DLC. Delete from old list in second loop.
		--If Shotgun Pack is not owned, try to use the Community 000 Buckshot instead.
		local use_com_buck = false
		for _, part_id in ipairs(old_blueprint) do
			dlc = parts_tweak_data[part_id].dlc or "normal"
			if dlc ~= "normal" and not managers.dlc:is_dlc_unlocked(dlc) then
				table.insert(no_dlc, part_id)
				if part_id == "wpn_fps_upg_a_custom" then
					use_com_buck = true
				end
			end
		end
		for _, part_id in ipairs(no_dlc) do
			table.delete(old_blueprint, part_id)
		end
		if use_com_buck then
			table.insert(old_blueprint, "wpn_fps_upg_a_custom_free")
			table.delete(no_dlc, "wpn_fps_upg_a_custom")
		end
		
		--Step 5: Check which parts are available in inventory. Sort into four tables: in_stock, out_of_stock, not_available, legend
		for _, part_id in ipairs(old_blueprint) do
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
			self:add_crafted_weapon_blueprint_to_inventory(category, slot, crafted.cosmetics and crafted.cosmetics.id and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id] and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint)
			self._global.crafted_items[category][slot].global_values = nil--Just in case
			crafted.blueprint = deep_clone(blueprint)
		else
			--Otherwise, clone default and add parts
			self:add_crafted_weapon_blueprint_to_inventory(category, slot, crafted.cosmetics and crafted.cosmetics.id and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id] and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint)
			self._global.crafted_items[category][slot].global_values = nil--Just in case
			crafted.blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id))
			
			local parts_tweak_data = tweak_data.weapon.factory.parts
			
			--First pass
			local second_pass = {}
			for _, part_id in pairs(blueprint) do
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
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, crafted.cosmetics and crafted.cosmetics.id and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id] and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint)
		self._global.crafted_items[category][slot].global_values = nil--Just in case
		crafted.blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id))
	end
	
	--Enable update again
	OSA._skip_omw = false
	
	--Rest unchanged except for showing the dialog menu
	crafted.customize_locked = customize_locked
	crafted.locked_name = locked_name
	crafted.cosmetics = {
		id = item_data.entry,
		instance_id = instance_id,
		quality = quality,
		bonus = bonus or false
	}

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

--OSA remove skin function
function BlackMarketManager:osa_on_remove_weapon_cosmetics(category, slot, skip_update)
	local crafted = self._global.crafted_items[category][slot]

	if not crafted then
		return
	end
	
	--Skip update of mods until end (to prevent crashing)
	OSA._skip_omw = true
	--Initialize menu message
	local message = false

	--Handle two states: keep, remove
	if OSA._state_remove.keep then
		--Save blueprints
		local old_blueprint = deep_clone(self._global.crafted_items[category][slot].blueprint)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(self._global.crafted_items[category][slot].factory_id)
		local old_skin_blueprint = crafted.cosmetics and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint or {}
		
		--Remove all mods
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, crafted.cosmetics and crafted.cosmetics.id and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id] and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint)
		self._global.crafted_items[category][slot].global_values = nil--Just in case
		crafted.blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id))
		
		--Setup
		local parts_tweak_data = tweak_data.weapon.factory.parts
		local no_dlc = {}--Mods that have been removed due to lack of DLC
		local in_stock = {}--Mods that are in stock/available
		local out_of_stock = {}--Mods that are out of stock. Try to buy if possible.
		local not_available = {}--Mods that are out of stock and cannot be bought (unlockables)
		local legend = {}--Legendary parts (removed)
		
		--Step 1: Replace Community 000 Buckshot with Shotgun Pack if available.
		if OSA._settings.osa_prefer_sp_buck and managers.dlc:is_dlc_unlocked("gage_pack_shotgun") then
			local use_sp_buck = false
			for _, part_id in ipairs(old_blueprint) do
				if part_id == "wpn_fps_upg_a_custom_free" then
					use_sp_buck = true
					break
				end
			end
			if use_sp_buck then
				table.delete(old_blueprint, "wpn_fps_upg_a_custom_free")
				table.insert(old_blueprint, "wpn_fps_upg_a_custom")
			end
		end
		
		--Step 2: Delete parts that are part of the default blueprint.
		for _, part_id in ipairs(default_blueprint) do
			table.delete(old_blueprint, part_id)
		end
		
		--Step 3: Log parts that are included on the new skin. Delete from old list in second loop.
		--No new blueprint, go directly to step 4
		
		--Step 4: Log parts that are not available anymore due to missing DLC. Delete from old list in second loop.
		--If Shotgun Pack is not owned, try to use the Community 000 Buckshot instead.
		local use_com_buck = false
		for _, part_id in ipairs(old_blueprint) do
			dlc = parts_tweak_data[part_id].dlc or "normal"
			if dlc ~= "normal" and not managers.dlc:is_dlc_unlocked(dlc) then
				table.insert(no_dlc, part_id)
				if part_id == "wpn_fps_upg_a_custom" then
					use_com_buck = true
				end
			end
		end
		for _, part_id in ipairs(no_dlc) do
			table.delete(old_blueprint, part_id)
		end
		if use_com_buck then
			table.insert(old_blueprint, "wpn_fps_upg_a_custom_free")
			table.delete(no_dlc, "wpn_fps_upg_a_custom")
		end
		
		--Step 5: Check which parts are available in inventory. Sort into four tables: in_stock, out_of_stock, not_available, legend
		for _, part_id in ipairs(old_blueprint) do
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
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, crafted.cosmetics and crafted.cosmetics.id and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id] and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint)
		self._global.crafted_items[category][slot].global_values = nil--Just in case
		crafted.blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id))
	end
	
	--Enable update again
	OSA._skip_omw = false

	--Rest unchanged except for showing the dialog menu
	crafted.customize_locked = nil
	crafted.cosmetics = nil
	
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
end