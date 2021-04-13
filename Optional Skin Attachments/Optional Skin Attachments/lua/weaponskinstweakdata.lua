dofile(ModPath .. "lua/setup.lua")

--Warning: removing default_blueprint can trigger false-positives in the anti-piracy code if not done properly.
--v3.0: do not touch default blueprint at all, instead set a flag "osa_no_attachments" to mark fake attachment skins
Hooks:PostHook(BlackMarketTweakData, "_init_weapon_skins", "osa_post_BlackMarketTweakData__init_weapon_skins", function(self, tweak_data)
	for _, skin in pairs(self.weapon_skins) do
		--Remove unique name so that legendary skins can be renamed
		if skin.rarity == "legendary" and OSA._settings.osa_rename_legendary then
			skin.unique_name_id = nil
		end
		
		--Fix skins that don't actually have attachments
		if skin.default_blueprint and not skin.locked then
			--Get factory_id, based on WeaponFactoryManager:get_factory_id_by_weapon_id
			local weapon_id = skin.weapon_id
			local factory_id
			for id, data in pairs(tweak_data.upgrades.definitions) do
				if data.category == "weapon" and data.weapon_id == weapon_id then
					factory_id = data.factory_id
					--Stop searching lmao
					break
				end
			end
			--Check if there are any non-default mods
			if factory_id then
				if tweak_data.weapon.factory[factory_id] then
					local default_mods = tweak_data.weapon.factory[factory_id].default_blueprint
					local no_attachments = true
					for _, mod in pairs(skin.default_blueprint) do
						if not table.contains(default_mods, mod) then
							no_attachments = false
							break
						end
					end
					--In principle, since there are no default mods, we can safely delete the blueprint.
					--But to be extra safe, we don't remove the blueprint anymore, we just set a flag instead.
					--Note: because we don't remove the attachments, selecting the skin will still show stats menu. Minor issue, just ignore it.
					--e.g. Gruber Kurz 00G, Gruber Kurz Under the Radar, CAR-4 Special Force
					if no_attachments then
						--skin.default_blueprint = nil
						skin.osa_no_attachments = true
					end
				end
			end
		end
	end
end)
