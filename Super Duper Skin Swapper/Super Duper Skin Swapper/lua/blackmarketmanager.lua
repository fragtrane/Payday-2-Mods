dofile(ModPath .. "lua/setup.lua")

--Set visible skins after Steam inventory is loaded
Hooks:PreHook(BlackMarketManager, "tradable_update", "sdss_pre_BlackMarketManager_tradable_update", function(self, tradable_list, remove_missing)
	if Steam:logged_on() then
		self:set_visible_cosmetics(tradable_list)
	end
end)

--When offline, set visible skins after data is loaded
Hooks:PostHook(BlackMarketManager, "load", "sdss_post_BlackMarketManager_tradable_update", function(self, ...)
	if not Steam:logged_on() then
		self:set_visible_cosmetics()
	end
end)

--Check if online and if we received a tradable list
--If offline or no list, simulate a list based using items in saved inventory
--Simulated list only considers weapon skins; "amount" and "def_id" not set because they aren't needed
function BlackMarketManager:set_visible_cosmetics(tradable_list)
	if Steam:logged_on() and tradable_list then
		self:build_visible_cosmetics_list(tradable_list)
	else
		local simulated_tradable_list = {}
		for instance_id, data in pairs(self._global.inventory_tradable) do
			if data.category == "weapon_skins" then
				local instance = {
					category = data.category,
					entry = data.entry,
					quality = data.quality,
					bonus = data.bonus,
					instance_id = instance_id
				}
				table.insert(simulated_tradable_list, instance)
			end
		end
		self:build_visible_cosmetics_list(simulated_tradable_list)
	end
end

--Filter inventory for best skins, save instance_id in a list
--Only items from this list will be shown
function BlackMarketManager:build_visible_cosmetics_list(tradable_list)
	--Clean dupes is off, do nothing
	if SDSS:get_multi_name("sdss_clean_dupes") == "off" then
		SDSS.show = nil
		return
	end
	
	--Map quality to index, higher is better
	local function get_index(quality)
		local indexes = {
			mint = 5,
			fine = 4,
			good = 3,
			fair = 2,
			poor = 1
		}
		return indexes[quality]
	end
	
	--Map index to quality
	local function get_quality(index)
		local qualities = {
			[5] = "mint",
			[4] = "fine",
			[3] = "good",
			[2] = "fair",
			[1] = "poor"
		}
		return qualities[index]
	end
	
	--Compare instance IDs and choose smaller one
	local function choose_instance(id_1, id_2)
		if tonumber(id_1) < tonumber(id_2) then
			return id_1
		else
			return id_2
		end
	end
	
	--Given a weapon variant, pick the instance with the best wear
	--Returns instance_id and quality index
	--Flag checks if instance is visible before returning
	local function choose_best_wear(variant, check_visible)
		for i = 5,1,-1 do
			if variant[i] and (variant[i].visible or not check_visible) then
				return variant[i].instance_id, i
			end
		end
	end
	
	--Check if any instance (wear) of a given variant is visible
	local function any_visible(variant)
		return choose_best_wear(variant, true) and true or false
	end
	
	--Build list of all variants. If multiple of same variant, use lowest instance_id
	local instances = {}
	for _, item in pairs(tradable_list) do
		if item.category == "weapon_skins" then
			local entry = item.entry
			local quality = item.quality
			local quality_ind = get_index(quality)
			local variant = item.bonus and "stat" or "norm"
			local instance_id = item.instance_id
			--If skin doesn't exist or the variant doesn't exist or the wear doesn't exist, add it
			if not instances[entry] or not instances[entry][variant] or not instances[entry][variant][quality_ind] then
				instances[entry] = instances[item.entry] or {}
				instances[entry][variant] = instances[entry][variant] or {}
				instances[entry][variant][quality_ind] = {instance_id = instance_id}
			else
				instances[entry][variant][quality_ind].instance_id = choose_instance(instance_id, instances[entry][variant][quality_ind].instance_id)
			end
		end
	end
	
	--Choose which skins to show, also flag as visible
	--At least one copy of each skin should be visible
	SDSS.show = {}
	if SDSS:get_multi_name("sdss_clean_dupes") == "bonus" then
		--Prefer bonus
		for skin_id, skin_data in pairs(instances) do
			local variant = skin_data.stat and "stat" or "norm"
			local instance_id, quality_ind = choose_best_wear(skin_data[variant])
			table.insert(SDSS.show, instance_id)
			skin_data[variant][quality_ind].visible = true
		end
	elseif SDSS:get_multi_name("sdss_clean_dupes") == "quality" then
		--Prefer higher quality skin
		for skin_id, skin_data in pairs(instances) do
			--Default to stat values, or normal if stat is not available
			local variant = skin_data.stat and "stat" or "norm"
			local instance_id, quality_ind = choose_best_wear(skin_data[variant])
			--If both stat and normal, check if normal has higher quality
			if skin_data.stat and skin_data.norm then
				local instance_norm, index_norm = choose_best_wear(skin_data.norm)
				if index_norm > quality_ind then
					variant = "norm"
					instance_id = instance_norm
					quality_ind = index_norm
				end
			end
			table.insert(SDSS.show, instance_id)
			skin_data[variant][quality_ind].visible = true
		end
	elseif SDSS:get_multi_name("sdss_clean_dupes") == "both" then
		--Insert best of both variants
		for skin_id, skin_data in pairs(instances) do
			for variant, variant_data in pairs(skin_data) do
				local instance_id, quality_ind = choose_best_wear(variant_data)
				table.insert(SDSS.show, instance_id)
				skin_data[variant][quality_ind].visible = true
			end
		end
	elseif SDSS:get_multi_name("sdss_clean_dupes") == "allvars" then
		for skin_id, skin_data in pairs(instances) do
			for variant, variant_data in pairs(skin_data) do
				for quality_ind, instance_data in pairs(variant_data) do
					local instance_id = instance_data.instance_id
					table.insert(SDSS.show, instance_id)
					skin_data[variant][quality_ind].visible = true
				end
			end
		end
	end

	--Update all weapons in inventory to use visible skins
	local crafted_list = self._global.crafted_items or {}
	for category, category_data in pairs(crafted_list) do
		if category == "primaries" or category == "secondaries" then
			for slot, weapon_data in pairs(category_data) do
				--Check if weapon has skin first
				if weapon_data.cosmetics and weapon_data.cosmetics.id then
					local skin_id = weapon_data.cosmetics.id
					local cosmetic_tweak = weapon_data.cosmetics and tweak_data.blackmarket.weapon_skins[skin_id]
					--Check if it is a skin you own
					if instances[skin_id] then
						local quality = weapon_data.cosmetics.quality
						local quality_ind = get_index(quality)
						local variant = weapon_data.cosmetics.bonus and "stat" or "norm"
						if instances[skin_id][variant] and instances[skin_id][variant][quality_ind] and instances[skin_id][variant][quality_ind].visible then
							--If the variant + wear is available and visible, use it.
							--Only need to change instance_id, don't need to change bonus or wear
							weapon_data.cosmetics.instance_id = instances[skin_id][variant][quality_ind].instance_id
						elseif instances[skin_id][variant] and any_visible(instances[skin_id][variant]) then
							--If variant is available, use the best wear that is visible
							--Set instance + wear, don't need to set bonus
							local instance_new, index_new = choose_best_wear(instances[skin_id][variant], true)
							weapon_data.cosmetics.instance_id = instance_new
							weapon_data.cosmetics.quality = get_quality(index_new)
						else
							--Variant not available, but skin is available
							--Set instance + wear + bonus
							--At least one skin is available, so if it's not stat then it's norm
							local variant_new = any_visible(instances[skin_id].stat) and "stat" or "norm"
							local instance_new, index_new = choose_best_wear(instances[skin_id][variant_new], true)
							weapon_data.cosmetics.instance_id = instance_new
							weapon_data.cosmetics.quality = get_quality(index_new)
							weapon_data.cosmetics.bonus = (variant_new == "stat") and true or false
						end
					end
				end
			end
		end
	end
end

--Clean duplicates, only return best skins
function BlackMarketManager:get_cosmetics_instances_by_weapon_id(weapon_id)
	local cosmetic_tweak = tweak_data.blackmarket.weapon_skins
	local items = {}
	
	for instance_id, data in pairs(self._global.inventory_tradable) do
		if data.category == "weapon_skins" and cosmetic_tweak[data.entry] and self:weapon_cosmetics_type_check(weapon_id, data.entry) then
			if not SDSS.show or table.contains(SDSS.show, instance_id) then
				table.insert(items, instance_id)
			end
		end
	end
	
	return items
end

--Allow mods to be previewed on locked legendary skins
function BlackMarketManager:is_previewing_legendary_skin()
	return false
end

--Keep attachments when previewing weapons
function BlackMarketManager:view_weapon_with_cosmetics(category, slot, cosmetics, open_node_cb, spawn_workbench, custom_data)
	if not self._global.crafted_items[category] or not self._global.crafted_items[category][slot] then
		Application:error("[BlackMarketManager:view_weapon] Trying to view weapon that doesn't exist", category, slot)

		return
	end

	local weapon = self._global.crafted_items[category][slot]
	local blueprint = deep_clone(self._preview_blueprint.blueprint)--Keep attachments

	if cosmetics and tweak_data.blackmarket.weapon_skins[cosmetics.id] then
		self._last_viewed_cosmetic_id = cosmetics.id
	end

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

--When previewing skin from Steam inventory, show legacy attachments
function BlackMarketManager:view_weapon_platform_with_cosmetics(weapon_id, cosmetics, open_node_cb, spawn_workbench, custom_data)
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	local blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id))

	if cosmetics and tweak_data.blackmarket.weapon_skins[cosmetics.id] then
		--Changed two lines, use legacy_blueprint
		if tweak_data.blackmarket.weapon_skins[cosmetics.id].legacy_blueprint then
			blueprint = tweak_data.blackmarket.weapon_skins[cosmetics.id].legacy_blueprint
		end

		self._last_viewed_cosmetic_id = cosmetics.id
	end

	local texture_switches = nil

	self:preload_weapon_blueprint("preview", factory_id, blueprint, spawn_workbench)

	if spawn_workbench then
		table.insert(self._preloading_list, {
			done_cb = function ()
				managers.menu_scene:spawn_workbench_room()
			end
		})
	end

	table.insert(self._preloading_list, {
		done_cb = function ()
			managers.menu_scene:spawn_item_weapon(factory_id, blueprint, cosmetics, texture_switches, custom_data)
		end
	})
	table.insert(self._preloading_list, {
		done_cb = open_node_cb
	})
end

--Allow all skins on all weapons
--But filter out Immortal Python
function BlackMarketManager:weapon_cosmetics_type_check(weapon_id, weapon_skin_id)	
	local weapon_skin = tweak_data.blackmarket.weapon_skins[weapon_skin_id]
	local found_weapon = false
	
	--Allows everything except for Immortal Python (unlockable) and colors (blacklist)
	--Golden AK.762 has been removed from blacklist so it can actually use colors now
	if weapon_skin and not weapon_skin.is_a_unlockable and not weapon_skin.use_blacklist then
		return true
	end
	
	--Check extra ID (let skins without Immortal Python use another weapon's Immortal Python)
	if weapon_skin and weapon_skin.extra_weapon_ids and table.contains(weapon_skin.extra_weapon_ids, weapon_id) then
		return true
	end
	
	if weapon_skin then
		--Fix mistake in dump
		found_weapon = (weapon_skin.weapon_ids and table.contains(weapon_skin.weapon_ids, weapon_id)) or (weapon_skin.weapon_id and weapon_skin.weapon_id == weapon_id)
		
		if weapon_skin.use_blacklist then
			found_weapon = not found_weapon
		end
	end

	return found_weapon
end

--Prevents unowned skins from being loaded (depending on options).
--Loads Immortal Python. weapon_cosmetics_type_check only allows unlockable skins (i.e. Immortal Python) on correct weapon.
--extra_weapon_ids can be used to override
function BlackMarketManager:get_cosmetics_by_weapon_id(weapon_id)
	if tweak_data.weapon[weapon_id] then
		weapon_id = tweak_data.weapon[weapon_id].parent_weapon_id or weapon_id
	end
	
	--Don't allow skins for weapons in blacklist (no skins blacklisted right now)
	if table.contains(SDSS._blacklist, weapon_id) then
		return {}
	end
	
	--Put Immortal Python
	--Put unowned skins if they aren't being hidden
	local cosmetic_tweak = tweak_data.blackmarket.weapon_skins
	local cosmetics = {dummy = {is_a_color_skin = true}}--Fix for weapons which don't have any skins
	for id, data in pairs(cosmetic_tweak) do
		if self:weapon_cosmetics_type_check(weapon_id, id) and (data.is_a_unlockable or not SDSS._settings.sdss_hide_unowned) then
			cosmetics[id] = data
		end
	end
	
	return cosmetics
end

--Replace icons. Incompatible with BeardLib (gets overwritten)
--Can't use PostHook because there are multiple return values
--Solution in get_weapon_icon_path_fix.lua
--function BlackMarketManager:get_weapon_icon_path(weapon_id, cosmetics)

--Skip OMW
local orig_BlackMarketManager__on_modified_weapon = BlackMarketManager._on_modified_weapon
function BlackMarketManager:_on_modified_weapon(category, slot)
	if SDSS._skip_omw then
		return
	end
	orig_BlackMarketManager__on_modified_weapon(self, category, slot)
end

--Attachments have been removed from all weapons except for first generation legendaries
--When applying first generation legendary, ignore the blueprint
--When replacing a first generation legendary with a new skin, remove legendary attachments if they are no longer available.
function BlackMarketManager:_set_weapon_cosmetics(category, slot, cosmetics, update_weapon_unit)
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

	local old_cosmetic_id = crafted.cosmetics and crafted.cosmetics.id
	local old_cosmetic_data = old_cosmetic_id and tweak_data.blackmarket.weapon_skins[old_cosmetic_id]
	local old_cosmetic_default_blueprint = old_cosmetic_data and old_cosmetic_data.default_blueprint
	local blueprint = weapon_skin_data.default_blueprint or {}
	
	--Check if any legendary parts are not available on new skin
	local legends = false
	local parts_tweak_data = tweak_data.weapon.factory.parts
	for _, part_id in pairs(crafted.blueprint) do
		if parts_tweak_data[part_id] and parts_tweak_data[part_id].is_legendary_part and not table.contains(blueprint, part_id) then
			legends = true
			break
		end
	end
	
	if legends then
		SDSS._skip_omw = true--Skip OMW to prevent crash
		
		--Build list of mods that are not legendary / default
		local parts_to_apply = {}
		local weapon_default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id)
		for _, part_id in pairs(crafted.blueprint) do
			if not parts_tweak_data[part_id].is_legendary_part and not table.contains(weapon_default_blueprint, part_id) then
				table.insert(parts_to_apply, part_id)
			end
		end
		
		--Strip all mods
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
		crafted.blueprint = deep_clone(weapon_default_blueprint)
		
		--Apply mods, two-pass
		local defer = {}
		--Pass 1
		for _, part_id in pairs(parts_to_apply) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(defer, part_id)
			end
		end
		--Pass 2
		for _, part_id in pairs(defer) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			end
		end
		
		--Done
		SDSS._skip_omw = false
	end
	
	crafted.customize_locked = nil--Don't lock customization
	crafted.locked_name = nil--Don't lock name
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

--Attachments have been removed from all weapons except for first generation legendaries
--When removing a first generation legendary skin, remove legendary attachments
function BlackMarketManager:on_remove_weapon_cosmetics(category, slot, skip_update)
	local crafted = self._global.crafted_items[category][slot]

	if not crafted then
		return
	end

	local old_cosmetic_id = crafted.cosmetics and crafted.cosmetics.id
	local old_cosmetic_data = old_cosmetic_id and tweak_data.blackmarket.weapon_skins[old_cosmetic_id]
	local old_cosmetic_default_blueprint = old_cosmetic_data and old_cosmetic_data.default_blueprint
	
	--Check if any legendary parts
	local legends = false
	local parts_tweak_data = tweak_data.weapon.factory.parts
	for _, part_id in pairs(crafted.blueprint) do
		if parts_tweak_data[part_id] and parts_tweak_data[part_id].is_legendary_part then
			legends = true
			break
		end
	end
	
	if legends then
		SDSS._skip_omw = true--Skip OMW to prevent crash
		
		--Build list of mods that are not legendary / default
		local parts_to_apply = {}
		local weapon_default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id)
		for _, part_id in pairs(crafted.blueprint) do
			if not parts_tweak_data[part_id].is_legendary_part and not table.contains(weapon_default_blueprint, part_id) then
				table.insert(parts_to_apply, part_id)
			end
		end
		
		--Strip all mods
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
		crafted.blueprint = deep_clone(weapon_default_blueprint)
		
		--Apply mods, two-pass
		local defer = {}
		--Pass 1
		for _, part_id in pairs(parts_to_apply) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			else
				table.insert(defer, part_id)
			end
		end
		--Pass 2
		for _, part_id in pairs(defer) do
			if managers.weapon_factory:can_add_part(crafted.factory_id, part_id, crafted.blueprint) == nil then
				local no_consume = parts_tweak_data[part_id].is_a_unlockable or false
				self:buy_and_modify_weapon(category, slot, parts_tweak_data[part_id].dlc or "normal", part_id, true, no_consume)
			end
		end
		
		--Done
		SDSS._skip_omw = false
	end

	crafted.customize_locked = nil
	crafted.locked_name = nil--Bugfix
	crafted.cosmetics = nil

	--Bugfix: global value not removed?
	if old_cosmetic_id then
		local global_value = old_cosmetic_data.global_value or managers.dlc:dlc_to_global_value(old_cosmetic_data.dlc)
		
		self:alter_global_value_item(global_value, category, slot, old_cosmetic_id, CRAFT_REMOVE)
	end

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
