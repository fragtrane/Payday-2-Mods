dofile(ModPath .. "lua/setup.lua")

--Make filter button visible in Crime.net Offline (filter items still need to be fixed)
Hooks:PostHook(GuiTweakData, "init", "IOF_post_GuiTweakData_init", function(self)
	if IOF._settings.iof_filters then
		self.crime_net.sidebar[2].visible_callback = nil
	end
end)
