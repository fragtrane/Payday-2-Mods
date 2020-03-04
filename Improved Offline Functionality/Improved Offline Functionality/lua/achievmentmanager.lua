dofile(ModPath .. "lua/setup.lua")

--Fix for functions that use this to verify achievements
local orig_AchievmentManager_get_info = AchievmentManager.get_info
function AchievmentManager:get_info(id)
	local result = orig_AchievmentManager_get_info(self, id)
	
	--Always overwrite "awarded" using state to prevent locked outfit bug
	if IOF._settings.iof_community and IOF._state[id] then
		result = result or {}
		result.awarded = true
	end
	
	return result
end
