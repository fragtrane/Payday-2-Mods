--For OSA / SDSS
_G.SRAB = {}

Hooks:PostHook(WeaponFactoryTweakData, "init", "srab_post_WeaponFactoryTweakData_init", function(self)
	--Dragon's Breath rounds block suppressors
	table.insert(self.parts.wpn_fps_upg_a_dragons_breath.forbids, "wpn_fps_sho_ksg_b_legendary")
end)

Hooks:PostHook(WeaponFactoryTweakData, "_init_legendary", "srab_post_WeaponFactoryTweakData__init_legendary", function(self)
	--Combined stats of Short Barrel and Silent Killer Suppressor
	--Works out perfectly because the Optical Illusions bug will cause give the same bonus that you get on a real suppressed Raven
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
	table.insert(self.parts.wpn_fps_sho_ksg_b_legendary.perks, "silencer")
	
	--Suppressed fire sound
	self.parts.wpn_fps_sho_ksg_b_legendary.sound_switch = {
		suppressed = "suppressed_a"
	}
	
	--Block barrel extensions
	self.parts.wpn_fps_sho_ksg_b_legendary.forbids = {
		"wpn_fps_upg_shot_ns_king",
		"wpn_fps_upg_ns_shot_thick",
		"wpn_fps_upg_ns_shot_shark",
		"wpn_fps_upg_ns_sho_salvo_large",
		"wpn_fps_upg_a_dragons_breath",
		"wpn_fps_upg_ns_duck"
	}
end)
