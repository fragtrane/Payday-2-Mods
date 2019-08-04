dofile(ModPath .. "lua/setup.lua")

--Warning: removing default_blueprint can trigger false-positives in the anti-piracy code if not done properly.
--Remove attachments, unlock legendary skins, and remove unique name. Save legacy_blueprint before removing to use in the anti-piracy code.
Hooks:PostHook(BlackMarketTweakData, "_init_weapon_skins", "dsa_post_BlackMarketTweakData_init_weapon_skins", function(self)
	for _, weap in pairs(self.weapon_skins) do
		--Clone default_blueprint to legacy_blueprint so it can be used later
		if weap.default_blueprint then
			weap.legacy_blueprint = deep_clone(weap.default_blueprint)
		end
		if weap.rarity == "common" or weap.rarity == "uncommon" then
			--Fix common/uncommon skins that remove attachments for no reason
			if DSA._settings.dsa_fix_common_uncommon and weap.default_blueprint then
				weap.default_blueprint = nil
			end
		elseif weap.rarity == "rare" or weap.rarity == "epic" then
			--Remove attachments from rare/epic skins
			if DSA._settings.dsa_remove_attachments and weap.default_blueprint then
				weap.default_blueprint = nil
			end
		elseif weap.rarity == "legendary" then
			--Remove attachments from non-locked legendary skins
			if DSA._settings.dsa_remove_attachments and weap.default_blueprint and not weap.locked then
				weap.default_blueprint = nil
			end
			--Unlock legendary skins and remove attachments
			if DSA._settings.dsa_unlock_legendaries and weap.locked then
				weap.locked = false
				if DSA._settings.dsa_remove_unlocked_attachments and weap.default_blueprint then
					weap.default_blueprint = nil
				end
			end
			--Remove unique name so that legendary skins can be renamed
			if DSA._settings.dsa_rename_legendary then
				weap.unique_name_id = nil
			end
		end
	end
end)
