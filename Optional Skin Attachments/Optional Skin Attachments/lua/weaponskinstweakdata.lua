dofile(ModPath .. "lua/setup.lua")

--Warning: removing default_blueprint can trigger false-positives in the anti-piracy code if not done properly.
--Remove attachments and remove unique name. The removed blueprints do not contain weapon mods so false-positives are not an issue.
Hooks:PostHook(BlackMarketTweakData, "_init_weapon_skins", "osa_post_BlackMarketTweakData_init_weapon_skins", function(self)
	for _, skin in pairs(self.weapon_skins) do
		--Fix common/uncommon skins that remove attachments for no reason
		if skin.rarity == "common" or skin.rarity == "uncommon" then
			skin.default_blueprint = nil
		end
		--Remove unique name so that legendary skins can be renamed
		if skin.rarity == "legendary" and OSA._settings.osa_rename_legendary then
			skin.unique_name_id = nil
		end
	end
	--Fix rare/epic skins that don't actually have attachments
	--Could automate this by comparing default weapon blueprint with skin blueprint
	--But since this rarely occurs we can also just do it explicitly
	local overrides = {
		"b682_skf",--Joceline O/U 12G Shotgun | Jocy
		"plainsrider_skullimov",--Plainsrider Bow | Hypno Scalp
		"r93_css"--R93 Sniper Rifle | Opposition
	}
	for _, skin in pairs(overrides) do
		self.weapon_skins[skin].default_blueprint = nil
	end
end)
