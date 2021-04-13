--For OSA / SDSS
_G.SuppressedJudgeAnarchoBarrel = {}

Hooks:PostHook(WeaponFactoryTweakData, "init", "sjab_post_WeaponFactoryTweakData_init", function(self)
	--Dragon's Breath rounds block suppressors
	table.insert(self.parts.wpn_fps_upg_a_dragons_breath.forbids, "wpn_fps_pis_judge_b_legend")
end)

--Anarcho Grip already has no stats so we don't need to do balance it
--PreHook last function in init, make sure that all attachments and whatnot have been set up.
Hooks:PreHook(WeaponFactoryTweakData, "_set_inaccessibles", "sjab_pre_WeaponFactoryTweakData__set_inaccessibles", function(self)
	--Copy stats of Silent Killer Suppressor
	self.parts.wpn_fps_pis_judge_b_legend.stats = deep_clone(self.parts.wpn_fps_upg_ns_shot_thick.stats)
	
	--Add "silencer" perk, "gadget" perk is not overwritten
	self.parts.wpn_fps_pis_judge_b_legend.perks = self.parts.wpn_fps_pis_judge_b_legend.perks or {}
	table.insert(self.parts.wpn_fps_pis_judge_b_legend.perks, "silencer")
	
	--Suppressed fire sound, clone Silent Killer Suppressor
	self.parts.wpn_fps_pis_judge_b_legend.sound_switch = deep_clone(self.parts.wpn_fps_upg_ns_shot_thick.sound_switch)
	
	--Block all barrel extensions
	self.parts.wpn_fps_pis_judge_b_legend.forbids = self.parts.wpn_fps_pis_judge_b_legend.forbids or {}
	for _, part_id in pairs(self.wpn_fps_pis_judge.uses_parts) do
		if part_id ~= "wpn_fps_pis_judge_b_legend" and self.parts[part_id] and self.parts[part_id].type == "barrel_ext" then
			table.insert(self.parts.wpn_fps_pis_judge_b_legend.forbids, part_id)
		end
	end
	
	--Block Dragon's Breath
	table.insert(self.parts.wpn_fps_pis_judge_b_legend.forbids, "wpn_fps_upg_a_dragons_breath")
end)
