dofile(ModPath .. "lua/setup.lua")

--Costs for added skill sets
--Add skill sets until table length equals total_profiles, loop does nothing if table length >= total_profiles
--So if the number of skill sets in the base game is changed, the added skill sets will not be lost
Hooks:PostHook(MoneyTweakData, "init" , "fragProfiles_post_MoneyTweakData_init" , function(self, ...)
	local actual_skill_sets = #self.skill_switch_cost
	for i=actual_skill_sets+1,fragProfiles._settings.total_profiles do
		table.insert(self.skill_switch_cost, {spending = 0, offshore = 0})
	end
end)
