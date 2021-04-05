dofile(ModPath .. "lua/setup.lua")

--New in v2.0
--Set default weapon color to Immortal Python (if it is unlocked)
Hooks:PostHook(AchievmentManager, "load", "sdss_post_AchievmentManager_load", function(self)
	if SDSS._settings.sdss_immortal_python then
		local data = self:get_milestone("ami_13")
		if data and data.awarded then
			tweak_data.blackmarket.weapon_color_default = "color_immortal_python"
		end
	end
end)
