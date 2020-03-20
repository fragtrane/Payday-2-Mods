dofile(ModPath .. "lua/setup.lua")

--Only show difficulty settings and nothing else in offline filters
local orig_MenuCrimeNetFiltersInitiator_update_node = MenuCrimeNetFiltersInitiator.update_node
function MenuCrimeNetFiltersInitiator:update_node(node)
	--Set all visible first
	for _, item in ipairs(node:items() or {}) do
		item:set_visible(true)
	end
	--Original
	orig_MenuCrimeNetFiltersInitiator_update_node(self, node)
	--If single player, only show difficulty filter
	if Global.game_settings.single_player then
		for _, item in ipairs(node:items() or {}) do
			local allow = {
				"divider_lobby_filters",
				"divider_1",
				"difficulty_filter",
				"divider_end",
				"apply"
			}
			if table.contains(allow, item:parameters().name) then
				item:set_visible(true)
			else
				item:set_visible(false)
			end
		end
	end
end

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
	--Only override in menus
	if not game_state_machine or game_state_machine:current_state_name() == "menu_main" then
		return true
	end
	return not Global.game_settings.single_player
end

--Load filters settings when a single player game is started
local orig_MenuCallbackHandler_play_single_player = MenuCallbackHandler.play_single_player
function MenuCallbackHandler:play_single_player()
	if IOF._settings.iof_filters and managers.network.matchmake and managers.network.matchmake.load_user_filters then
		managers.network.matchmake:load_user_filters()
	end
	orig_MenuCallbackHandler_play_single_player(self)
end
