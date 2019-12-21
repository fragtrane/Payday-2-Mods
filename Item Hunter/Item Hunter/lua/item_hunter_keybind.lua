--Wait until in-game to run.
if managers.platform:presence() ~= "Playing" then
	return
end

--Set up display states on first run
--Initial state is "off"
if not ItemHunter._state.display then
	ItemHunter:init_states()
end

--If not enabled, return
if not ItemHunter._enabled then
	managers.hud._hud_presenter:_present_information( { text = managers.localization:text("itmhnt_hint_unavailable"), title = managers.localization:text("itmhnt_hint_title"), time = 4 } )
	return
end

--Go to next state
ItemHunter:next_state()

--Feedback
managers.hud._hud_presenter:_present_information( { text = managers.localization:text("itmhnt_hint_"..ItemHunter:get_display_state()), title = managers.localization:text("itmhnt_hint_title"), time = 4 } )

--Update waypoints
if ItemHunter:get_display_state() ~= "off" then
	ItemHunter:clean_wp()
	ItemHunter:update_wp()
	ItemHunter:clean_wp()
else
	ItemHunter:remove_all_wp()
end
