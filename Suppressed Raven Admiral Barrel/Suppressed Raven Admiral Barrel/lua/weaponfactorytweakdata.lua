--For OSA / SDSS
_G.SuppressedRavenAdmiralBarrel = {}

Hooks:PostHook(WeaponFactoryTweakData, "init", "srab_post_WeaponFactoryTweakData_init", function(self)
	--Dragon's Breath rounds block suppressors
	table.insert(self.parts.wpn_fps_upg_a_dragons_breath.forbids, "wpn_fps_sho_ksg_b_legendary")
end)

--PreHook last function in init, make sure that all attachments and whatnot have been set up.
Hooks:PreHook(WeaponFactoryTweakData, "_set_inaccessibles", "srab_pre_WeaponFactoryTweakData__set_inaccessibles", function(self)
	--Combined stats of Short Barrel and Silent Killer Suppressor
	--Works out perfectly because the Optical Illusions bug will give the same bonus that you get on a real suppressed Raven
	self.parts.wpn_fps_sho_ksg_b_legendary.stats = {
		value = 1,
		alert_size = 12,
		spread_moving = -2,
		damage = -3,
		suppression = 12,
		recoil = -1,
		concealment = 2,
		extra_ammo = -2,
		spread = -2
	}
	
	--Add "silencer" perk, "gadget" perk is not overwritten
	self.parts.wpn_fps_sho_ksg_b_legendary.perks = self.parts.wpn_fps_sho_ksg_b_legendary.perks or {}
	table.insert(self.parts.wpn_fps_sho_ksg_b_legendary.perks, "silencer")
	
	--Suppressed fire sound, clone Silent Killer Suppressor
	self.parts.wpn_fps_sho_ksg_b_legendary.sound_switch = deep_clone(self.parts.wpn_fps_upg_ns_shot_thick.sound_switch)
	
	--Block all barrel extensions
	self.parts.wpn_fps_sho_ksg_b_legendary.forbids = self.parts.wpn_fps_sho_ksg_b_legendary.forbids or {}
	for _, part_id in pairs(self.wpn_fps_sho_ksg.uses_parts) do
		if part_id ~= "wpn_fps_sho_ksg_b_legendary" and self.parts[part_id] and self.parts[part_id].type == "barrel_ext" then
			table.insert(self.parts.wpn_fps_sho_ksg_b_legendary.forbids, part_id)
		end
	end
	
	--Block Dragon's Breath
	table.insert(self.parts.wpn_fps_sho_ksg_b_legendary.forbids, "wpn_fps_upg_a_dragons_breath")
end)
