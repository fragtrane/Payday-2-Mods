dofile(ModPath .. "lua/setup.lua")

--Fix for functions that use this to verify achievements
local orig_AchievmentManager_get_info = AchievmentManager.get_info
function AchievmentManager:get_info(id)
	if not Steam:logged_on() and IOF._settings.iof_community then
		if IOF._state[id] then
			return {awarded = true}
		end
	end
	
	return orig_AchievmentManager_get_info(self, id) 
end
