dofile(ModPath .. "lua/setup.lua")

--Warning: removing default_blueprint can trigger false-positives in the anti-piracy code if not done properly.
--We don't remove blueprints so this isn't an issue
Hooks:PostHook(BlackMarketTweakData, "_init_weapon_skins", "sdss_post_BlackMarketTweakData__init_weapon_skins", function(self)
	--Allow legendaries to be customized and renamed, remove weapons from color blacklist
	for skin_id, skin in pairs(self.weapon_skins) do
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
end)

--New in v2.0
--Set default pattern scale
--Don't set default color here, do it in achievmentmanager.lua so we can check if Immortal Python is unlocked first
--So this actually changes the pattern scale on some skins as well (e.g. CAR-4 Stripe On, 5/7 AP Possessed)
--Maybe look into making this an actual option in the future
--[[Hooks:PostHook(BlackMarketTweakData, "_setup_weapon_color_skins", "sdss_post_BlackMarketTweakData__setup_weapon_color_skins", function(self)
	--Set pattern scale, shift index by 1 because first option is "off"
	if SDSS._settings.sdss_pattern_scale > 1 then
		self.weapon_color_pattern_scale_default = SDSS._settings.sdss_pattern_scale - 1
	end
	
	--Hook this to DLC Manager instead so we can check if Immortal Python is unlocked
	--self.weapon_color_default = "color_immortal_python"
end)]]
