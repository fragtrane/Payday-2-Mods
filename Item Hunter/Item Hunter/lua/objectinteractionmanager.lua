dofile(ModPath .. "lua/setup.lua")

--Refresh waypoints when there is a new interactable object
Hooks:PostHook(ObjectInteractionManager, "add_unit", "ItemHunter_ObjectInteractionManager_add_unit", function(...)
	if managers.platform:presence() == "Playing" and ItemHunter._enabled and ItemHunter:get_display_state() ~= "off" then
		ItemHunter:clean_wp()
		ItemHunter:update_wp()
		ItemHunter:clean_wp()
	end
end)

--Refresh waypoints when an interactable object is removed
Hooks:PostHook(ObjectInteractionManager, "remove_unit", "ItemHunter_ObjectInteractionManager_remove_unit", function(...)
	if managers.platform:presence() == "Playing" and ItemHunter._enabled and ItemHunter:get_display_state() ~= "off" then
		ItemHunter:clean_wp()
		ItemHunter:update_wp()
		ItemHunter:clean_wp()
	end
end)
