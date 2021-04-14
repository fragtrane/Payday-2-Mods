dofile(ModPath .. "lua/setup.lua")

--Modified from SDSS 2.0, show vanilla weapon icon over rarity background when a skin is equipped on the wrong gun
--This way we can see what guns that people with SDSS are actually using
local orig_BlackMarketManager_get_weapon_icon_path = BlackMarketManager.get_weapon_icon_path
function BlackMarketManager:get_weapon_icon_path(weapon_id, cosmetics)
	local id = cosmetics and cosmetics.id
	if id then
		local weapon_skin = tweak_data.blackmarket.weapon_skins[id]
		if weapon_skin then
			--Fix mistake in dump
			--Check if right weapon
			local found_weapon = (weapon_skin.weapon_ids and table.contains(weapon_skin.weapon_ids, weapon_id)) or (weapon_skin.weapon_id and weapon_skin.weapon_id == weapon_id)
			--Wrong weapon, not color skin. Put default icon over rarity.
			if not found_weapon and not weapon_skin.is_a_color_skin then
				local rarity = weapon_skin.rarity or "common"
				local rarity_path = tweak_data.economy.rarities[rarity] and tweak_data.economy.rarities[rarity].bg_texture
				--local texture_path = self:get_weapon_icon_path(weapon_id, nil)
				--Use original function for getting icon, might be more stable
				local texture_path = orig_BlackMarketManager_get_weapon_icon_path(self, weapon_id, nil)
				return texture_path, rarity_path
			end
		end
	end
	--Otherwise use original
	return orig_BlackMarketManager_get_weapon_icon_path(self, weapon_id, cosmetics)
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
	self._global.inventory[global_value][category][part_id] = (self._global.inventory[global_value][category][part_id] or 0) + 1
	self:alter_global_value_item(global_value, category, nil, part_id, INV_ADD)
	self:dispatch_event("added_to_inventory", part_id, category, global_value)
end

--Sorted wanted attachments to make our life easier
--New in v3.0, used by apply/remove skin functions
--TODO: AOLA integration? Switch to add-on if legend not available?
function BlackMarketManager:_sort_wanted_attachments(new_skin, wanted_bp, default_bp, strip_legend)
	local on_new_skin = {}--New skin
	local available = {}--OK
	local no_dlc = {}--Fail: no DLC
	local legend = {}--Fail: legend
	local out_of_stock = {}--Fail: out of stock
	local unavailable = {}--Fail: unavailable
	
	--1. Strip default parts from wanted_bp
	--Modify directly since we cloned before
	for _, part_id in pairs(default_bp) do
		if table.contains(wanted_bp, part_id) then
			table.delete(wanted_bp, part_id)
		end
	end
	
	--2. Buckshot Replacement
	if managers.dlc:is_dlc_unlocked("gage_pack_shotgun") then
		if OSA._settings.osa_prefer_sp_buck then
			--Replace wanted
			if table.contains(wanted_bp, "wpn_fps_upg_a_custom_free") then
				table.delete(wanted_bp, "wpn_fps_upg_a_custom_free")
				table.insert(wanted_bp, "wpn_fps_upg_a_custom")
			end
		else
			--Nothing
		end
	else
		--No DLC
		if table.contains(wanted_bp, "wpn_fps_upg_a_custom") and not table.contains(new_skin, "wpn_fps_upg_a_custom") then
			table.delete(wanted_bp, "wpn_fps_upg_a_custom")
			table.insert(wanted_bp, "wpn_fps_upg_a_custom_free")
		end
	end
	
	--3. Check new skin, strip legendary, check DLC
	local parts_tweak_data = tweak_data.weapon.factory.parts
	for _, part_id in pairs(wanted_bp) do
		--Check if on new skin
		if table.contains(new_skin, part_id) then
			--Always OK unless removing legendary
			if not strip_legend or not parts_tweak_data[part_id].is_legendary_part then
				--New skin OK
				table.insert(on_new_skin, part_id)
			else
				--Put in fail legend (deal with later)
				table.insert(legend, part_id)
			end
		else
			--Check DLC
			local dlc = parts_tweak_data[part_id].dlc or "normal"
			if dlc ~= "normal" and not managers.dlc:is_dlc_unlocked(dlc) then
				table.insert(no_dlc, part_id)
			end
		end
	end
	--Cleanup previous call
	for _, part_id in pairs(on_new_skin) do
		table.delete(wanted_bp, part_id)
	end
	for _, part_id in pairs(no_dlc) do
		table.delete(wanted_bp, part_id)
	end
	for _, part_id in pairs(legend) do
		table.delete(wanted_bp, part_id)
	end
	--If strip legend, removing legend is intended behavior. Drop fail list.
	if strip_legend then
		legend = {}
	end
	
	--4. Check which parts are available in inventory.
	for _, part_id in pairs(wanted_bp) do
		--Legends never okay without skin
		if parts_tweak_data[part_id].is_legendary_part then
			table.insert(legend, part_id)
		else
			local g_v = parts_tweak_data[part_id].dlc or "normal"
			local amount = self._global.inventory[g_v]["weapon_mods"][part_id] or 0
			if amount > 0 then
				table.insert(available, part_id)
			else
				if parts_tweak_data[part_id].is_a_unlockable then
					table.insert(unavailable, part_id)
				else
					table.insert(out_of_stock, part_id)
				end
			end
		end
	end
	
	--Step 5: Try to buy mods that are out of stock.
	if OSA._settings.osa_autobuy then
		for _, part_id in pairs(out_of_stock) do
			if parts_tweak_data[part_id].type ~= "bonus" then
				local coins = math.floor(Application:digest_value(managers.custom_safehouse._global.total)) or 0
				--Don't autobuy if coins will drop below threshold.
				if coins-6  >= OSA._settings.osa_autobuy_threshold then
					self:osa_buy_mod(part_id)
					table.insert(available, part_id)
				else
					--If coins will drop below threshold, stop because we can't buy anymore.
					break
				end
			end
		end
		--Clean out of stock
		for _, part_id in pairs(available) do
			if table.contains(out_of_stock, part_id) then
				table.delete(out_of_stock, part_id)
			end
		end
	end
	
	--Return result
	local result = {
		on_new_skin = on_new_skin,
		available = available,
		no_dlc = no_dlc,
		legend = legend,
		out_of_stock = out_of_stock,
		unavailable = unavailable
	}
	return result
end

--Set OSA._skip_omw to skip this function when applying a bunch of attachments
--If we don't do this, we get crashes
local orig_BlackMarketManager__on_modified_weapon = BlackMarketManager._on_modified_weapon
function BlackMarketManager:_on_modified_weapon(category, slot)
	if OSA._skip_omw == true then
		return
	end
	orig_BlackMarketManager__on_modified_weapon(self, category, slot)
end

--Show dialog when attachments could not be kept
--To-do: sort the list?
function BlackMarketManager:_osa_show_failures(error_params)
	local parts_tweak_data = tweak_data.weapon.factory.parts
	
	local menu_title = managers.localization:text("osa_dialog_title")
	local menu_message = managers.localization:text("osa_dialog_could_not_keep")
	
	local keys = {"no_dlc", "legend", "out_of_stock", "unavailable", "incompatible"}
	
	local show_message = false
	for _, key in ipairs(keys) do
		if error_params[key] and next(error_params[key]) ~= nil then
			show_message = true
			local msg_id = "osa_dialog_reason_" .. key
			menu_message = menu_message .. "\n\n" .. managers.localization:text(msg_id) .. ":"
			
			for _, part_id in pairs(error_params[key]) do
				if parts_tweak_data[part_id] and parts_tweak_data[part_id].name_id then
					menu_message = menu_message .. "\n - " .. managers.localization:text(parts_tweak_data[part_id].name_id)
				end
			end
		end
	end
	
	if show_message then
		OSA:ok_menu(menu_title, menu_message, false, false)
	end
end

--v3.0 overhaul
--Apply weapon skin (or color)
function BlackMarketManager:_set_weapon_cosmetics(category, slot, cosmetics, update_weapon_unit)
	--Checks unchanged
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
	
	--3.0.1 Fix when opening color customization
	if not OSA._state or not OSA._state.options or not OSA._state.options.attach then
		OSA._state = OSA._state or {}
		OSA._state.options = OSA._state.options or {}
		OSA._state.options.attach = "keep"
	end
	
	--Set up blueprints, mostly unchanged
	local old_cosmetic_id = crafted.cosmetics and crafted.cosmetics.id
	local old_cosmetic_data = old_cosmetic_id and tweak_data.blackmarket.weapon_skins[old_cosmetic_id]
	--Blueprint of old skin (not gun)
	--Check osa_no_attachments flag
	local old_cosmetic_default_blueprint = old_cosmetic_data and not old_cosmetic_data.osa_no_attachments and old_cosmetic_data.default_blueprint or {}
	--Blueprint of new skin, renamed for clarity
	--Check osa_no_attachments flag
	local new_cosmetic_default_blueprint = not weapon_skin_data.osa_no_attachments and weapon_skin_data.default_blueprint or {}
	--Currently equipped attachments
	local gun_current_blueprint = deep_clone(crafted.blueprint)
	--Weapon default attachments
	local gun_default_blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id))
	
	--Set up variables
	local is_locked = weapon_skin_data.locked
	local parts_tweak_data = tweak_data.weapon.factory.parts
	
	--Check if we can skip and just clone
	local can_clone = true
	if OSA._state.options.attach == "keep" then
		--Can't clone if blueprint or COM 000
		if #old_cosmetic_default_blueprint ~= 0 or #new_cosmetic_default_blueprint ~= 0 or table.contains(gun_current_blueprint, "wpn_fps_upg_a_custom_free") then
			can_clone = false
		end
	elseif OSA._state.options.attach == "replace" then
		--Check locked legendary
		if is_locked and OSA._state.options.unlock == "no" then
			--Clone if locked and not unlocking
		elseif is_locked and OSA._state.options.unlock == "remove_legend" then
			--Can't clone if remove legendary
			can_clone = false
		elseif table.contains(new_cosmetic_default_blueprint, "wpn_fps_upg_a_custom_free") then
			--Can't clone if COM 000
			can_clone = false
		end
	end
	--Note: "remove" can always be cloned so we don't need to check it
	
	--Debug Clone
	--OSA:ok_menu("Clone", tostring(can_clone), false, false)
	
	if can_clone then
		--Cloning
		if OSA._state.options.attach == "keep" then
			--Nothing
		elseif OSA._state.options.attach == "replace" then
			--Clone new
			self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
			crafted.global_values = nil
			crafted.blueprint = deep_clone(new_cosmetic_default_blueprint)
		elseif OSA._state.options.attach == "remove" then
			--Clone default
			self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
			crafted.global_values = nil
			crafted.blueprint = deep_clone(gun_default_blueprint)
		end
	else
		--Handle attachments
		--Set wanted attachments
		local wanted_raw
		if OSA._state.options.attach == "keep" then
			--Keep
			wanted_raw = deep_clone(crafted.blueprint)
		elseif OSA._state.options.attach == "replace" then
			--Replace
			wanted_raw = deep_clone(new_cosmetic_default_blueprint)
		end
		
		--First strip the gun so parts become in stock again
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
		crafted.global_values = nil
		crafted.blueprint = deep_clone(gun_default_blueprint)
		
		--Check if we need to strip legendary parts
		local strip_legend = is_locked and OSA._state.options.unlock == "remove_legend" or false
		
		--Call _sort_wanted_attachments to handle wanted attachments
		local wanted_parsed = self:_sort_wanted_attachments(new_cosmetic_default_blueprint, wanted_raw, gun_default_blueprint, strip_legend)
		
		--Two-pass apply in case there are dependencies between parts (e.g. scope mounts)
		--Skip update of mods until end (to prevent crashing)
		OSA._skip_omw = true
		
		--Pass 1, add to defer if failed
		local defer_on_new_skin = {}
		local defer_available = {}
		for _, part_id in pairs(wanted_parsed.on_new_skin) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				--Attachments on new skin don't consume
				local no_consume = true
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(defer_on_new_skin, part_id)
			end
		end
		for _, part_id in pairs(wanted_parsed.available) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				--Don't consume if unlockable
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(defer_available, part_id)
			end
		end
		
		--Pass 2, add to incompatible if failed
		local incompatible = {}
		for _, part_id in pairs(defer_on_new_skin) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				--Attachments on new skin don't consume
				local no_consume = true
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(incompatible, part_id)
			end
		end
		for _, part_id in pairs(defer_available) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				--Don't consume if unlockable
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(incompatible, part_id)
			end
		end
		
		--Enable update again
		OSA._skip_omw = false
		
		--Add incompatible to wanted parsed for error params
		--Don't clone just modify directly
		local error_params = wanted_parsed
		error_params.on_new_skin = nil--Don't need this anymore
		error_params.available = nil--Don't need this anymore
		error_params.incompatible = incompatible
		
		--Check/show error message
		self:_osa_show_failures(error_params)
		--OSA:ok_menu("DEBUG", json.encode(error_params), false, false)
	end
	
	--Customize is locked only if we are replacing and there is no unlock flag
	crafted.customize_locked = weapon_skin_data.locked and OSA._state.options.attach == "replace" and OSA._state.options.unlock == "no"
	--Check settings to see if rename is allowed
	crafted.locked_name = weapon_skin_data.rarity == "legendary" and not OSA._settings.osa_rename_legendary
	
	--Rest unchanged
	crafted.cosmetics = cosmetics
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
	
	MenuCallbackHandler:_update_outfit_information()
end

--v3.0 overhaul
--Remove weapon skin (or color)
function BlackMarketManager:on_remove_weapon_cosmetics(category, slot, skip_update)
	--Checks unchanged
	local crafted = self._global.crafted_items[category][slot]
	if not crafted then
		return
	end
	
	--When skip update, options have not been set
	--Do it manually here otherwise we'll crash
	if skip_update then
		OSA._state = OSA._state or {}
		OSA._state.options = OSA._state.options or {}
		OSA._state.options.attach = "keep"
	end
	
	--Set up blueprints
	local old_cosmetic_id = crafted.cosmetics and crafted.cosmetics.id
	local old_cosmetic_data = old_cosmetic_id and tweak_data.blackmarket.weapon_skins[old_cosmetic_id]
	--Blueprint of old skin (not gun)
	--Check osa_no_attachments flag
	local old_cosmetic_default_blueprint = old_cosmetic_data and not old_cosmetic_data.osa_no_attachments and old_cosmetic_data.default_blueprint or {}
	--Blueprint of new skin (i.e. nothing, because we are not applying a new skin)
	local new_cosmetic_default_blueprint = {}
	--Currently equipped attachments
	local gun_current_blueprint = deep_clone(crafted.blueprint)
	--Weapon default attachments
	local gun_default_blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id))
	
	
	--Set up variables
	local parts_tweak_data = tweak_data.weapon.factory.parts
	
	--Check if we can skip and just clone
	local can_clone = true
	if OSA._state.options.attach == "keep" then
		--Can't clone if blueprint or COM 000
		if #old_cosmetic_default_blueprint ~= 0 or table.contains(gun_current_blueprint, "wpn_fps_upg_a_custom_free") then
			can_clone = false
		end
	end
	--Note: "remove" can always be cloned so we don't need to check it
	
	--Debug Clone
	if not skip_update then
		--OSA:ok_menu("Clone", tostring(can_clone), false, false)
	end
	
	if can_clone then
		--Cloning
		if OSA._state.options.attach == "keep" then
			--Nothing
		elseif OSA._state.options.attach == "remove" then
			--Clone default
			self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
			crafted.global_values = nil
			crafted.blueprint = deep_clone(gun_default_blueprint)
		end
	else
		--Handle attachments
		--Set wanted attachments
		local wanted_raw = deep_clone(crafted.blueprint)
		
		--First strip the gun so parts become in stock again
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
		crafted.global_values = nil
		crafted.blueprint = deep_clone(gun_default_blueprint)
		
		--Don't need legendary stripping
		local strip_legend = false
		
		--Call _sort_wanted_attachments to handle wanted attachments
		--Note: there is no blueprint on the new gun, we already set new_cosmetic_default_blueprint = {} at the start
		local wanted_parsed = self:_sort_wanted_attachments(new_cosmetic_default_blueprint, wanted_raw, gun_default_blueprint, strip_legend)
		
		--Two-pass apply in case there are dependencies between parts (e.g. scope mounts)
		--Skip update of mods until end (to prevent crashing)
		OSA._skip_omw = true
		
		--Pass 1, add to defer if failed
		local defer_on_new_skin = {}
		local defer_available = {}
		for _, part_id in pairs(wanted_parsed.on_new_skin) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				--Attachments on new skin don't consume
				local no_consume = true
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(defer_on_new_skin, part_id)
			end
		end
		for _, part_id in pairs(wanted_parsed.available) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				--Don't consume if unlockable
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(defer_available, part_id)
			end
		end
		
		--Pass 2, add to incompatible if failed
		local incompatible = {}
		for _, part_id in pairs(defer_on_new_skin) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				--Attachments on new skin don't consume
				local no_consume = true
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(incompatible, part_id)
			end
		end
		for _, part_id in pairs(defer_available) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				--Don't consume if unlockable
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(incompatible, part_id)
			end
		end
		
		--Enable update again
		OSA._skip_omw = false
		
		--Error message only if not skip_update
		if not skip_update then
			--Add incompatible to wanted parsed for error params
			--Don't clone just modify directly
			local error_params = wanted_parsed
			error_params.on_new_skin = nil--Don't need this anymore
			error_params.available = nil--Don't need this anymore
			error_params.incompatible = incompatible
			
			--Check/show error message
			self:_osa_show_failures(error_params)
			--OSA:ok_menu("DEBUG", json.encode(error_params), false, false)
		end
	end
	
	--Bugfix: global value not removed in base game
	--Added some additional checks to prevent crashes when removing custom skin that no longer exists
	if old_cosmetic_id and old_cosmetic_data and (old_cosmetic_data.global_value or old_cosmetic_data.dlc) then
		local global_value = old_cosmetic_data.global_value or managers.dlc:dlc_to_global_value(old_cosmetic_data.dlc)
		if global_value then
			self:alter_global_value_item(global_value, category, slot, old_cosmetic_id, CRAFT_REMOVE)
		end
	end
	
	--Bugfix: locked name is not reset when skin is removed in base game
	crafted.locked_name = nil
	
	--Rest unchanged
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
		
		MenuCallbackHandler:_update_outfit_information()
	end
end

--Allow mods to be previewed on locked legendary skins
function BlackMarketManager:is_previewing_legendary_skin()
	return false
end

--v3.0 overhaul
--Preview weapon skin (or color)
local orig_BlackMarketManager_view_weapon_with_cosmetics = BlackMarketManager.view_weapon_with_cosmetics
function BlackMarketManager:view_weapon_with_cosmetics(category, slot, cosmetics, open_node_cb, spawn_workbench, custom_data)
	--Call original function if option off or if state missing
	--3.0.1 Fix when opening color customization
	if not OSA._settings.osa_preview or not OSA._state or not OSA._state.options or not OSA._state.options.attach then
		orig_BlackMarketManager_view_weapon_with_cosmetics(self, category, slot, cosmetics, open_node_cb, spawn_workbench, custom_data)
		return
	end
	
	if not self._global.crafted_items[category] or not self._global.crafted_items[category][slot] then
		Application:error("[BlackMarketManager:view_weapon] Trying to view weapon that doesn't exist", category, slot)
		return
	end
	local weapon = self._global.crafted_items[category][slot]
	
	--Set preview blueprint
	local blueprint = self._preview_blueprint and self._preview_blueprint.blueprint or weapon.blueprint
	if OSA._state.options.attach == "keep" then
		--Nothing
	elseif OSA._state.options.attach == "replace" then
		--Unchanged
		if cosmetics and tweak_data.blackmarket.weapon_skins[cosmetics.id] then
			if tweak_data.blackmarket.weapon_skins[cosmetics.id].default_blueprint then
				blueprint = deep_clone(tweak_data.blackmarket.weapon_skins[cosmetics.id].default_blueprint)
			end
		end
	elseif OSA._state.options.attach == "remove" then
		blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(weapon.factory_id))
	end
	
	--Don't set _last_viewed_cosmetic_id, this way we can preview the same skin again but in a different quality.
	if cosmetics and tweak_data.blackmarket.weapon_skins[cosmetics.id] then
	--	self._last_viewed_cosmetic_id = cosmetics.id
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
