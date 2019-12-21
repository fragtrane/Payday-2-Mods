dofile(ModPath .. "lua/setup.lua")

--Refresh waypoints when there is a new interactable object
local orig_ObjectInteractionManager_add_unit = ObjectInteractionManager.add_unit
function ObjectInteractionManager:add_unit(unit)
	orig_ObjectInteractionManager_add_unit(self, unit)
	
	if ItemHunter._enabled and ItemHunter:get_display_state() ~= "off" then
		ItemHunter:clean_wp()
		ItemHunter:update_wp()
		ItemHunter:clean_wp()
	end
end

--Refresh waypoints when an interactable object is removed
local orig_ObjectInteractionManager_remove_unit = ObjectInteractionManager.remove_unit
function ObjectInteractionManager:remove_unit(unit)
	orig_ObjectInteractionManager_remove_unit(self, unit)
	
	if ItemHunter._enabled and ItemHunter:get_display_state() ~= "off" then
		ItemHunter:clean_wp()
		ItemHunter:update_wp()
		ItemHunter:clean_wp()
	end
end
