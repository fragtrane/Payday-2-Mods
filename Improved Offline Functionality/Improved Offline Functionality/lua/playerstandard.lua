dofile(ModPath .. "lua/setup.lua")

--Stops interactions from being interrupted by pause/chat in offline mode
function PlayerStandard:_create_on_controller_disabled_input()
	local release_interact = (not IOF._settings.iof_no_interrupt and Global.game_settings.single_player) or not managers.menu:get_controller():get_input_bool("interact")
	local input = {
		btn_melee_release = true,
		btn_steelsight_release = true,
		is_customized = true,
		btn_use_item_release = true,
		btn_interact_release = release_interact
	}

	return input
end
