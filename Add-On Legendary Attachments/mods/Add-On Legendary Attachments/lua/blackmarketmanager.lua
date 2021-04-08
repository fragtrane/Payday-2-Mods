dofile(ModPath .. "lua/setup.lua")

--Set available mods after Steam inventory is loaded
Hooks:PostHook(BlackMarketManager, "tradable_update", "AOLA_post_BlackMarketManager_tradable_update", function(self, ...)
	if Steam:logged_on() then
		self:set_available_legendary_addon_parts(AOLA.missing_dependency)
		self:clean_legendary_addon_parts(AOLA.missing_dependency)
	end
end)

--Set available mods after data is loaded
Hooks:PostHook(BlackMarketManager, "load", "AOLA_post_BlackMarketManager_tradable_update", function(self, ...)
	self:set_available_legendary_addon_parts(AOLA.missing_dependency)
	self:clean_legendary_addon_parts(AOLA.missing_dependency)
end)

--Checks which skins are owned and sets available legendary parts accordingly
function BlackMarketManager:set_available_legendary_addon_parts(remove_all)
	--Delete all if assets missing
	if remove_all then
		for skin_id, parts in pairs(AOLA._gen_1_mods) do
			for _, part_id in pairs(parts) do
				local global_value = "normal"
				local category = "weapon_mods"
				self._global.inventory[global_value] = self._global.inventory[global_value] or {}
				self._global.inventory[global_value][category] = self._global.inventory[global_value][category] or {}
				self._global.inventory[global_value][category][part_id.."_addon"] = nil
			end
		end
		return
	end
	
	--Set available parts for owned skins
	for skin_id, parts in pairs(AOLA._gen_1_mods) do
		local has_skin = self:have_inventory_tradable_item("weapon_skins", skin_id) or AOLA._settings.aola_debug
		for _, part_id in pairs(parts) do
			local addon = tweak_data.weapon.factory.parts[part_id.."_addon"]
			local global_value = "normal"
			local category = "weapon_mods"
			if addon then
				self._global.inventory[global_value] = self._global.inventory[global_value] or {}
				self._global.inventory[global_value][category] = self._global.inventory[global_value][category] or {}
				self._global.inventory[global_value][category][part_id.."_addon"] = has_skin and 1 or 0
			end
		end
	end
end

--Clean add-on attachments belonging to unowned legendary skins
function BlackMarketManager:clean_legendary_addon_parts(remove_all)
	--Loop over weapons
	local crafted_list = self._global.crafted_items or {}
	for category, category_data in pairs(crafted_list) do
		if category == "primaries" or category == "secondaries" then
			for slot, crafted in pairs(category_data) do
				--Loop over legendary skins
				for skin_id, parts in pairs(AOLA._gen_1_mods) do
					local has_skin = self:have_inventory_tradable_item("weapon_skins", skin_id) or AOLA._settings.aola_debug
					has_skin = has_skin and not remove_all
					--Only need to check skins that are not owned
					if not has_skin then
						--Check if we have to remove anything
						local pass = true
						for _, part_id in pairs(parts) do
							if table.contains(crafted.blueprint, part_id.."_addon") then
								pass = false
								break
							end
						end
						--Remove unowned legendary add-ons
						--Still don't know how to remove properly, just based off of the SDSS method
						if not pass then
							--Not really old since skins aren't being removed, just taking this from SDSS
							local old_cosmetic_id = crafted.cosmetics and crafted.cosmetics.id
							local old_cosmetic_data = old_cosmetic_id and tweak_data.blackmarket.weapon_skins[old_cosmetic_id]
							local old_cosmetic_default_blueprint = old_cosmetic_data and old_cosmetic_data.default_blueprint
							--Build list of mods that are not addons / default
							local parts_to_apply = {}
							local weapon_default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(crafted.factory_id)
							for _, part_id in pairs(crafted.blueprint) do
								if not table.contains(parts, part_id:sub(1, #part_id-6)) and not table.contains(weapon_default_blueprint, part_id) then
									table.insert(parts_to_apply, part_id)
								end
							end
							--Strip all mods
							self:add_crafted_weapon_blueprint_to_inventory(category, slot, old_cosmetic_default_blueprint)
							crafted.blueprint = deep_clone(weapon_default_blueprint)
							--Apply mods, two-pass
							local defer = {}
							local parts_tweak_data = tweak_data.weapon.factory.parts
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
						end
					end
				end
			end
		end
	end
end

--Used by quickplay to check if you own a suppressed weapon, fix for SRAB
--Only need to fix addon. If user only has SRAB, sub_type of base is still "silencer".
--SDSS/OSA change sub_type of base but they also update this check so it doesn't need to be done again.
--This is never going to happen and who uses quickplay anyways
--[[local orig_BlackMarketManager_player_owns_silenced_weapon = BlackMarketManager.player_owns_silenced_weapon
function BlackMarketManager:player_owns_silenced_weapon()
	local result = orig_BlackMarketManager_player_owns_silenced_weapon(self)

	if not AOLA.missing_dependency then
		--Check for Suppressed Raven Admiral Barrel mod
		--Legacy support for _G.SRAB identifier used by v1.0
		if not result and (_G.SuppressedRavenAdmiralBarrel or _G.SRAB) then
			local categories = {
				"primaries",
				"secondaries"
			}
			for _, category in ipairs(categories) do
				for _, crafted_item in pairs(self._global.crafted_items[category]) do
					for _, part_id in ipairs(crafted_item.blueprint) do
						if part_id == "wpn_fps_sho_ksg_b_legendary_addon" then
							return true
						end
					end
				end
			end
		end
	end
	
	return result
end]]
