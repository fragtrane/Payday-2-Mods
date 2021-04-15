dofile(ModPath .. "lua/setup.lua")

--PostHook _set_inaccessibles so it runs before AOLA
--AOLA needs to respect the pbsr_override_aola setting
Hooks:PostHook(WeaponFactoryTweakData, "_set_inaccessibles", "pbsr_post_WeaponFactoryTweakData__set_inaccessibles", function(self)

	--Original Beak Suppressor third unit
	local third_unit = self.parts.wpn_fps_snp_model70_ns_suppressor.third_unit
	
	--PBSR unit
	local unit = BeakSuppressorReplacements:get_multi_name("pbsr_replacement")
	
	--If always on, just replace the model on the suppressor
	if BeakSuppressorReplacements._settings.pbsr_replace_normal then
		self.parts.wpn_fps_snp_model70_ns_suppressor.unit = unit
	else
		--Set overrides for Don Pastrami Barrel
		--If AOLA, this should get cloned to the legendary barrel too
		--If override AOLA, AOLA should respect this and not change it
		self.parts.wpn_fps_snp_model70_b_legend.override = self.parts.wpn_fps_snp_model70_b_legend.override or {}
		self.parts.wpn_fps_snp_model70_b_legend.override.wpn_fps_snp_model70_ns_suppressor = {
			third_unit = third_unit,
			unit = unit
		}
	end
end)
