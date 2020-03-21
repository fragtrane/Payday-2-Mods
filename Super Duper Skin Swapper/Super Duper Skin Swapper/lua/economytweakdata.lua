dofile(ModPath .. "lua/setup.lua")

--Override skin wear
Hooks:PostHook(EconomyTweakData, "init", "sdss_post_EconomyTweakData_init", function(self)
	local wears = {
		poor = 0.3,
		fair = 0.45,
		good = 0.6,
		fine = 0.8,
		mint = 1
	}
	local wear = wears[SDSS:get_multi_name("sdss_quality_override")]
	if wear then
		for quality, data in pairs(self.qualities) do
			if data.wear_tear_value then
				data.wear_tear_value = wear
			end
		end
	end
end)
