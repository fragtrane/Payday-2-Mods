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

--Chat in lobby. Only applies to Crime Spree offline since you can't make lobbies offline. Why would you even want to do this.
--function MenuComponentManager:_create_lobby_chat_gui()

--Chat in Crime.net when opened from a lobby. Offline lobbies not possible so you can't do this anyways.
--function MenuComponentManager:_create_crimenet_chats_gui()

--Chat in inventory when opened from a lobby. Offline lobbies not possible so you can't do this anyways.
--function MenuComponentManager:_create_inventory_chats_gui(node)
