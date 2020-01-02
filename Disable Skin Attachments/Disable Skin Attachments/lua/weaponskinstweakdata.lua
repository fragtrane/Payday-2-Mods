dofile(ModPath .. "lua/setup.lua")

--Warning: removing default_blueprint can trigger false-positives in the anti-piracy code if not done properly.
--Remove attachments, unlock legendary skins, and remove unique name. Save legacy_blueprint before removing to use in the anti-piracy code.
Hooks:PostHook(BlackMarketTweakData, "_init_weapon_skins", "dsa_post_BlackMarketTweakData__init_weapon_skins", function(self)
	for _, skin in pairs(self.weapon_skins) do
		--Clone default_blueprint to legacy_blueprint so it can be used later
		if skin.default_blueprint then
			skin.legacy_blueprint = deep_clone(skin.default_blueprint)
		end
		if skin.rarity == "common" or skin.rarity == "uncommon" then
			--Fix common/uncommon skins that remove attachments for no reason
			if DSA._settings.dsa_fix_common_uncommon and skin.default_blueprint then
				skin.default_blueprint = nil
			end
		elseif skin.rarity == "rare" or skin.rarity == "epic" then
			--Remove attachments from rare/epic skins
			if DSA._settings.dsa_remove_attachments and skin.default_blueprint then
				skin.default_blueprint = nil
			end
		elseif skin.rarity == "legendary" then
			--Remove attachments from non-locked legendary skins
			if DSA._settings.dsa_remove_attachments and skin.default_blueprint and not skin.locked then
				skin.default_blueprint = nil
			end
			--Unlock legendary skins and remove attachments
			if DSA._settings.dsa_unlock_legendaries and skin.locked then
				skin.locked = false
				if DSA._settings.dsa_remove_unlocked_attachments and skin.default_blueprint then
					skin.default_blueprint = nil
				end
			end
			--Remove unique name so that legendary skins can be renamed
			if DSA._settings.dsa_rename_legendary then
				skin.unique_name_id = nil
			end
		end
	end
end)
