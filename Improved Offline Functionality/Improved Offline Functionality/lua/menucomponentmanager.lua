dofile(ModPath .. "lua/setup.lua")

--Fix other functions that use MenuCallbackHandler:is_multiplayer
local orig_MenuComponentManager__create_chat_gui = MenuComponentManager._create_chat_gui
function MenuComponentManager:_create_chat_gui()
	if Global.game_settings.single_player and not IOF._settings.iof_chat then
		return
	end
	orig_MenuComponentManager__create_chat_gui(self)
end

--Fix other functions that use MenuCallbackHandler:is_multiplayer
local orig_MenuComponentManager__create_lobby_chat_gui = MenuComponentManager._create_lobby_chat_gui
function MenuComponentManager:_create_lobby_chat_gui()
	if Global.game_settings.single_player and not IOF._settings.iof_chat then
		return
	end
	orig_MenuComponentManager__create_lobby_chat_gui(self)
end

--Fix other functions that use MenuCallbackHandler:is_multiplayer
local orig_MenuComponentManager__create_crimenet_chats_gui = MenuComponentManager._create_crimenet_chats_gui
function MenuComponentManager:_create_crimenet_chats_gui()
	if Global.game_settings.single_player and not IOF._settings.iof_chat then
		return
	end
	orig_MenuComponentManager__create_crimenet_chats_gui(self)
end

--Fix other functions that use MenuCallbackHandler:is_multiplayer
local orig_MenuComponentManager__create_preplanning_chats_gui = MenuComponentManager._create_preplanning_chats_gui
function MenuComponentManager:_create_preplanning_chats_gui()
	if Global.game_settings.single_player and not IOF._settings.iof_chat then
		return
	end
	orig_MenuComponentManager__create_preplanning_chats_gui(self)
end
