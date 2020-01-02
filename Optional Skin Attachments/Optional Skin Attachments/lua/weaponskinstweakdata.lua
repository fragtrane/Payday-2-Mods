dofile(ModPath .. "lua/setup.lua")

--Warning: removing default_blueprint can trigger false-positives in the anti-piracy code if not done properly.
--Remove attachments and remove unique name. The removed blueprints do not contain weapon mods so false-positives are not an issue.
Hooks:PostHook(BlackMarketTweakData, "_init_weapon_skins", "osa_post_BlackMarketTweakData__init_weapon_skins", function(self)
	for _, skin in pairs(self.weapon_skins) do
		--Fix common/uncommon skins that remove attachments for no reason
		if skin.rarity == "common" or skin.rarity == "uncommon" then
			skin.default_blueprint = nil
		end
		--Remove unique name so that legendary skins can be renamed
		if skin.rarity == "legendary" and OSA._settings.osa_rename_legendary then
			skin.unique_name_id = nil
		end
		--Fix rare/epic skins that don't actually have attachments
		if skin.default_blueprint then
			--Get factory_id, based on WeaponFactoryManager:get_factory_id_by_weapon_id
			local weapon_id = skin.weapon_id
			local factory_id
			for id, data in pairs(OSA._td.upgrades.definitions) do
				if data.category == "weapon" and data.weapon_id == weapon_id then
					factory_id = data.factory_id
				end
			end
			--Check if there are any non-default mods
			local default_mods = OSA._td.weapon.factory[factory_id].default_blueprint
			local no_attachments = true
			for _, mod in pairs(skin.default_blueprint) do
				if not table.contains(default_mods, mod) then
					no_attachments = false
					break
				end
			end
			if no_attachments then
				skin.default_blueprint = nil
			end
		end
	end
end)
