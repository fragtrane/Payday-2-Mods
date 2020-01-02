dofile(ModPath .. "lua/setup.lua")

--Rename legendary weapons 
Hooks:PostHook(BlackMarketManager, "on_equip_weapon_cosmetics", "dsa_post_BlackMarketManager_on_equip_weapon_cosmetics", function(self, category, slot, instance_id)
	local crafted = self._global.crafted_items[category][slot]
	if not crafted then
		return
	end
	crafted.locked_name = crafted.locked_name and not DSA._settings.dsa_rename_legendary
end)

--Bugfix: locked name is not reset when skin is removed in base game
Hooks:PostHook(BlackMarketManager, "on_remove_weapon_cosmetics", "dsa_post_BlackMarketManager_on_remove_weapon_cosmetics", function(self, category, slot, instance_id)
	local crafted = self._global.crafted_items[category][slot]
	if not crafted then
		return
	end
	crafted.locked_name = nil
end)
