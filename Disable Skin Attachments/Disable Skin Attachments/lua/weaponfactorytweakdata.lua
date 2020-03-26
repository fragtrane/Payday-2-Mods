dofile(ModPath .. "lua/setup.lua")

--Remove stats from legendary attachments, search for parts that are tagged with "unatainable"
--Two mods on the Plush Phoenix are not tagged as unatainable but since they don't have stats it doesn't matter
Hooks:PostHook(WeaponFactoryTweakData, "init", "dsa_post_WeaponFactoryTweakData_init", function(self)
	if DSA._settings.dsa_remove_legendary_stats then
		for _, part in pairs(self.parts) do
			if part.unatainable then
				local val = 0
				if part.stats then
					val = part.stats.value or val
				end
				part.stats = {value = val}
			end
		end
	end
end)
