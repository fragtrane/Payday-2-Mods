dofile(ModPath .. "lua/setup.lua")

--Enable chat, based on Seven/Unknown Knight's Simulate Online mod
function MenuManager:toggle_chatinput()
	if (not IOF._settings.iof_chat and Global.game_settings.single_player) or Application:editor() then
		return
	end

	if SystemInfo:platform() ~= Idstring("WIN32") then
		return
	end

	if self:active_menu() then
		return
	end

	if not managers.network:session() then
		return
	end

	if managers.hud then
		managers.hud:toggle_chatinput()

		return true
	end
end

--Multiplayer check used to set filter item visibility, return true so that the filters are visible.
--This check is also used in some other places as well as in MenuComponentManager which need to be fixed.
--If someone finds a better solution for making filters visible, feel free to let me know.
function MenuCallbackHandler:is_multiplayer()
	return true
end

--Load filters settings when a single player game is started
local orig_MenuCallbackHandler_play_single_player = MenuCallbackHandler.play_single_player
function MenuCallbackHandler:play_single_player()
	if IOF._settings.iof_filters and managers.network.matchmake and managers.network.matchmake.load_user_filters then
		managers.network.matchmake:load_user_filters()
	end
	orig_MenuCallbackHandler_play_single_player(self)
end

--Fix other functions that use MenuCallbackHandler:is_multiplayer
local orig_MenuCallbackHandler_kick_player_visible = MenuCallbackHandler.kick_player_visible
function MenuCallbackHandler:kick_player_visible()
	if Global.game_settings.single_player then
		return false
	end
	return orig_MenuCallbackHandler_kick_player_visible(self)
end

--Fix other functions that use MenuCallbackHandler:is_multiplayer
local orig_MenuCallbackHandler_kick_vote_visible = MenuCallbackHandler.kick_vote_visible
function MenuCallbackHandler:kick_vote_visible()
	if Global.game_settings.single_player then
		return false
	end
	return orig_MenuCallbackHandler_kick_vote_visible(self)
end

--Fix other functions that use MenuCallbackHandler:is_multiplayer
local orig_MenuCallbackHandler__restart_level_visible = MenuCallbackHandler._restart_level_visible
function MenuCallbackHandler:_restart_level_visible()
	if Global.game_settings.single_player then
		return false
	end
	return orig_MenuCallbackHandler__restart_level_visible(self)
end

--Fix other functions that use MenuCallbackHandler:is_multiplayer
local orig_MenuCallbackHandler_abort_mission_visible = MenuCallbackHandler.abort_mission_visible
function MenuCallbackHandler:abort_mission_visible()
	if Global.game_settings.single_player then
		return false
	end
	return orig_MenuCallbackHandler_abort_mission_visible(self)
end
