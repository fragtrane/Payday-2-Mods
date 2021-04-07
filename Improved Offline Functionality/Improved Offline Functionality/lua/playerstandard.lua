dofile(ModPath .. "lua/setup.lua")

--Stops interactions from being interrupted by pause/chat in offline mode
local orig_PlayerStandard__create_on_controller_disabled_input = PlayerStandard._create_on_controller_disabled_input
function PlayerStandard:_create_on_controller_disabled_input()
	local result = orig_PlayerStandard__create_on_controller_disabled_input(self)
	
	--Only check when in single player
	if Global.game_settings.single_player then
		--If game wants to release button but we are still holding F and no interrupt is enabled
		if result.btn_interact_release and managers.menu:get_controller():get_input_bool("interact") and IOF._settings.iof_no_interrupt then
			result.btn_interact_release = false
		end		
	end
	
	return result
end
