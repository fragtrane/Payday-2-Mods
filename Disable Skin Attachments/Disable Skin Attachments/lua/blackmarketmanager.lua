dofile(ModPath .. "lua/setup.lua")

--One line changed to allow legendary weapons to be renamed
function BlackMarketManager:on_equip_weapon_cosmetics(category, slot, instance_id)
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
--	local locked_name = weapon_skin.rarity == "legendary"
	local locked_name = not DSA._settings.dsa_rename_legendary and weapon_skin.rarity == "legendary"
	local bonus = item_data.bonus
	local quality = item_data.quality

	if blueprint then
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, crafted.cosmetics and crafted.cosmetics.id and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id] and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint)

		crafted.blueprint = deep_clone(blueprint)
	elseif crafted.cosmetics and crafted.cosmetics.id and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id] and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint then
		self:add_crafted_weapon_blueprint_to_inventory(category, slot, crafted.cosmetics and crafted.cosmetics.id and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id] and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint)

		crafted.blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id))
	end

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

	MenuCallbackHandler:_update_outfit_information()
end
