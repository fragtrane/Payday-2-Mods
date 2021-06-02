dofile(ModPath .. "lua/setup.lua")

--Fix offline filter options
--Only show difficulty settings, hide some some useless stuff
Hooks:PostHook(MenuCrimeNetFiltersInitiator, "update_node", "IOF_post_MenuCrimeNetFiltersInitiator_update_node", function(self, node)
	if Global.game_settings.single_player and IOF._settings.iof_filters then
		--Universal options that should be always shown in MP but not in SP
		local hide_sp = {
			"divider_gamemode",--Divider between the gamemode selector and the toggles
			"divider_2",--Divider between the toggles and the multiselectors
			"server_filter",--Distance filter
			"reset_filters",--Reset button
			"beardlib_custom_maps_only"--BeardLib custom maps only (not in vanilla)
		}
		for _, item in ipairs(node:items() or {}) do
			--log(item:name())
			
			--Show difficulty filter when searching for standard game modes or when in single player
			if item:name() == "difficulty_filter" then
				item.visible = function()
					return self:is_standard() or Global.game_settings.single_player
				end
			end
			
			--Enable gamemode filter (debugging only, useless in SP)
			--[[if item:name() == "gamemode_filter" then
				item.visible = function()
					return true
				end
			end]]
			
			--Hide stuff from universal list
			if table.contains(hide_sp, item:name()) then
				item.visible = function()
					return not Global.game_settings.single_player
				end
			end
			
			--Hide that extra divider that shows up underneath the Crime Spree/Holdout options
			if item:name() == "divider_crime_spree" then
				item.visible = function()
					return not self:is_standard() and not Global.game_settings.single_player
				end
			end
		end
	end
end)

--Load filters settings when a single player game is started
Hooks:PreHook(MenuCallbackHandler, "play_single_player", "IOF_pre_MenuCallbackHandler_play_single_player", function()
	if IOF._settings.iof_filters and managers.network.matchmake and managers.network.matchmake.load_user_filters then
		managers.network.matchmake:load_user_filters()
	end
end)

--Enable chat, based on Seven/Unknown Knight's Simulate Online mod
local orig_MenuManager_toggle_chatinput = MenuManager.toggle_chatinput
function MenuManager:toggle_chatinput()
	local result = orig_MenuManager_toggle_chatinput(self)
	
	--If chat was not enabled and single player and IOF enabled
	if not result and Global.game_settings.single_player and IOF._settings.iof_chat then
		--Same return checks
		if Application:editor() or SystemInfo:platform() ~= Idstring("WIN32") or self:active_menu() or not managers.network:session() then
			return
		end
		--Toggle chat
		if managers.hud then
			managers.hud:toggle_chatinput()
			return true
		end
	end
	
	return
end
