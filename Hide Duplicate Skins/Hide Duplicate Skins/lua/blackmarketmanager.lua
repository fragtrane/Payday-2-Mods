dofile(ModPath .. "lua/setup.lua")

--Set visible skins after Steam inventory is loaded
Hooks:PreHook(BlackMarketManager, "tradable_update", "hds_pre_BlackMarketManager_tradable_update", function(self, tradable_list, remove_missing)
	if Steam:logged_on() then
		self:set_visible_cosmetics(tradable_list)
	end
end)

--When offline, set visible skins after data is loaded
Hooks:PostHook(BlackMarketManager, "load", "hds_post_BlackMarketManager_tradable_update", function(self, ...)
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
	if HideDupeSkins:get_multi_name("hds_clean_dupes") == "off" then
		HideDupeSkins.show = nil
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
	HideDupeSkins.show = {}
	if HideDupeSkins:get_multi_name("hds_clean_dupes") == "bonus" then
		--Prefer bonus
		for skin_id, skin_data in pairs(instances) do
			local variant = skin_data.stat and "stat" or "norm"
			local instance_id, quality_ind = choose_best_wear(skin_data[variant])
			table.insert(HideDupeSkins.show, instance_id)
			skin_data[variant][quality_ind].visible = true
		end
	elseif HideDupeSkins:get_multi_name("hds_clean_dupes") == "quality" then
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
			table.insert(HideDupeSkins.show, instance_id)
			skin_data[variant][quality_ind].visible = true
		end
	elseif HideDupeSkins:get_multi_name("hds_clean_dupes") == "both" then
		--Insert best of both variants
		for skin_id, skin_data in pairs(instances) do
			for variant, variant_data in pairs(skin_data) do
				local instance_id, quality_ind = choose_best_wear(variant_data)
				table.insert(HideDupeSkins.show, instance_id)
				skin_data[variant][quality_ind].visible = true
			end
		end
	elseif HideDupeSkins:get_multi_name("hds_clean_dupes") == "allvars" then
		for skin_id, skin_data in pairs(instances) do
			for variant, variant_data in pairs(skin_data) do
				for quality_ind, instance_data in pairs(variant_data) do
					local instance_id = instance_data.instance_id
					table.insert(HideDupeSkins.show, instance_id)
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
							local variant_new = instances[skin_id].stat and any_visible(instances[skin_id].stat) and "stat" or "norm"
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
			if not HideDupeSkins.show or table.contains(HideDupeSkins.show, instance_id) then
				table.insert(items, instance_id)
			end
		end
	end
	
	return items
end
