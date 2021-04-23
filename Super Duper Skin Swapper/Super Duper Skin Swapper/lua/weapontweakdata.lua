dofile(ModPath .. "lua/setup.lua")

--Do Akimbo mapping
Hooks:PostHook(WeaponTweakData, "init", "sdss_post_WeaponTweakData_init", function(self, tweak_data)
	for _, map in ipairs(SDSS._akimbo_map) do
		for _, weapon_id in ipairs(map) do
			if self[weapon_id] then
				self[weapon_id].sdss_has_variant = true
			end
		end
	end
end)
