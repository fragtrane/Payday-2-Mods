dofile(ModPath .. "lua/setup.lua")

--Chat ingame_waiting_for_players
--Only changed check
function MenuComponentManager:_create_chat_gui()
	if SystemInfo:platform() == Idstring("WIN32") and (MenuCallbackHandler:is_multiplayer() or IOF._settings.iof_chat) and managers.network:session() then
		self._preplanning_chat_gui_active = false
		self._lobby_chat_gui_active = false
		self._crimenet_chat_gui_active = false
		
		if self._game_chat_gui then
			self:show_game_chat_gui()
		else
			self:add_game_chat()
		end
		
		self._game_chat_gui:set_params(self._saved_game_chat_params or "default")
		
		self._saved_game_chat_params = nil
	end
end

--Fix other functions that use MenuCallbackHandler:is_multiplayer
--Chat in lobby (Crime Spree offline)
local orig_MenuComponentManager__create_lobby_chat_gui = MenuComponentManager._create_lobby_chat_gui
function MenuComponentManager:_create_lobby_chat_gui()
	if Global.game_settings.single_player and not IOF._settings.iof_chat then
		return
	end
	orig_MenuComponentManager__create_lobby_chat_gui(self)
end

--Fix other functions that use MenuCallbackHandler:is_multiplayer
--When opening Crime.net from lobby (currently not possible in single player but why not)
local orig_MenuComponentManager__create_crimenet_chats_gui = MenuComponentManager._create_crimenet_chats_gui
function MenuComponentManager:_create_crimenet_chats_gui()
	if Global.game_settings.single_player and not IOF._settings.iof_chat then
		return
	end
	orig_MenuComponentManager__create_crimenet_chats_gui(self)
end

--Chat during preplanning
--Only changed check
function MenuComponentManager:_create_preplanning_chats_gui()
	if SystemInfo:platform() == Idstring("WIN32") and (MenuCallbackHandler:is_multiplayer() or IOF._settings.iof_chat) and managers.network:session() then
		self._preplanning_chat_gui_active = true
		self._crimenet_chat_gui_active = false
		self._lobby_chat_gui_active = false
		
		if self._game_chat_gui then
			self:show_game_chat_gui()
		else
			self:add_game_chat()
		end
		
		self._game_chat_gui:set_params(self._saved_game_chat_params or "preplanning")
		
		self._saved_game_chat_params = nil
	end
end
