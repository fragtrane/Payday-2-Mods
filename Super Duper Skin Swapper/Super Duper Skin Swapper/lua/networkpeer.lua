dofile(ModPath .. "lua/setup.lua")

--One line changed to prevent false-positives in the anti-piracy detection.
--default_blueprint was removed so legacy_blueprint needs to be used instead.
function NetworkPeer:_verify_outfit_data()
	if not managers.network:session() or self._id == managers.network:session():local_peer():id() then
		return nil
	end

	local outfit = self:blackmarket_outfit()
	local mask_blueprint_lookup = {
		color = "colors",
		pattern = "textures",
		material = "materials"
	}

	for item_type, item in pairs(outfit) do
		if item_type == "mask" then
			if not self:_verify_content("masks", item.mask_id) then
				return self:_verify_cheated_outfit("masks", item.mask_id, 1)
			end

			for mask_type, mask_item in pairs(item.blueprint) do
				local mask_type_lookup = mask_blueprint_lookup[mask_type]
				local skip_default = false
				local mask_tweak = tweak_data.blackmarket.masks[item.mask_id]

				if mask_tweak and mask_tweak.default_blueprint and mask_tweak.default_blueprint[mask_type_lookup] == mask_item.id then
					skip_default = true
				end

				if not skip_default and not self:_verify_content(mask_type_lookup, mask_item.id) then
					return self:_verify_cheated_outfit(mask_type_lookup, mask_item.id, 1)
				end
			end
		elseif item_type == "primary" or item_type == "secondary" then
			if not self:_verify_content("weapon", managers.weapon_factory:get_weapon_id_by_factory_id(item.factory_id)) then
				return self:_verify_cheated_outfit("weapon", item.factory_id, 2)
			end

			local blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(item.factory_id)
--			local skin_blueprint = outfit[item_type].cosmetics and tweak_data.blackmarket.weapon_skins[outfit[item_type].cosmetics.id].default_blueprint or {}
			local skin_blueprint = outfit[item_type].cosmetics and tweak_data.blackmarket.weapon_skins[outfit[item_type].cosmetics.id].legacy_blueprint or {}

			for _, mod_item in pairs(item.blueprint) do
				if not table.contains(blueprint, mod_item) and not table.contains(skin_blueprint, mod_item) and not self:_verify_content("weapon_mods", mod_item) then
					return self:_verify_cheated_outfit("weapon_mods", mod_item, 2)
				end
			end
		elseif item_type == "melee_weapon" and not self:_verify_content("melee_weapons", item) then
			return self:_verify_cheated_outfit("melee_weapons", item, 2)
		end
	end

	return nil
end
