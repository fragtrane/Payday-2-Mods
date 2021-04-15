dofile(ModPath .. "lua/setup.lua")

--If always replacing, clone skin patterns for new part
Hooks:PostHook(BlackMarketTweakData, "_init_weapon_skins", "pbsr_post_BlackMarketTweakData__init_weapon_skins", function(self)
	if BeakSuppressorReplacements._settings.pbsr_replace_normal then
		--Current replacement part
		local part_id = BeakSuppressorReplacements:get_part_id()
		--Copy skin patterns
		for skin_id, skin in pairs(self.weapon_skins) do
			if skin.parts then
				if skin.parts[part_id] then
					skin.parts.wpn_fps_snp_model70_ns_suppressor = deep_clone(skin.parts[part_id])
				end
			end
		end
	end
end)
