dofile(ModPath .. "lua/setup.lua")

--Warning: removing default_blueprint can trigger false-positives in the anti-piracy code if not done properly.
--Remove attachments and remove unique name. The removed blueprints do not contain weapon mods so false-positives are not an issue.
Hooks:PostHook(BlackMarketTweakData, "_init_weapon_skins", "sdss_post_BlackMarketTweakData__init_weapon_skins", function(self)
	for skin_id, skin in pairs(self.weapon_skins) do
		--Save legacy blueprint for anti-piracy check
		if skin.default_blueprint then
			skin.legacy_blueprint = deep_clone(skin.default_blueprint)
		end
		
		--Remove blueprint
		if not SDSS._gen_1_mods[skin_id] then			
			skin.default_blueprint = nil
		else
			--First generation legendary, only put legendary attachments in blueprint
			skin.default_blueprint = deep_clone(SDSS._gen_1_mods[skin_id])
		end
		
		--Remove unique name and unlock (for legendaries)
		skin.unique_name_id = nil
		skin.locked = nil
		
		--Remove descriptions from non-legendaries
		if skin.rarity ~= "legendary" then
			skin.desc_id = nil
		end
		
		--Don't blacklist Golden AK.762 from weapon colors
		--Better not delete delete the whole blacklist since who knows what happens in the future
		if skin.use_blacklist and skin.weapon_ids and table.contains(skin.weapon_ids, "akm_gold") then
			table.delete(skin.weapon_ids, "akm_gold")
		end
	end
	
	--Extra Weapon IDs (for Immortal Python)
	for skin_id, weapons in pairs(SDSS._extra_weapon_ids) do
		self.weapon_skins[skin_id].extra_weapon_ids = self.weapon_skins[skin_id].extra_weapon_ids or {}
		for _, weapon_id in pairs(weapons) do
			table.insert(self.weapon_skins[skin_id].extra_weapon_ids, weapon_id)
		end
	end
end)
