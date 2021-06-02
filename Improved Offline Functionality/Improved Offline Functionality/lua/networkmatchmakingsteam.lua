dofile(ModPath .. "lua/setup.lua")

--Fix for multiplayer lobbies appearing in Crime.net offline after changing filters
local orig_NetworkMatchMakingSTEAM_search_lobby = NetworkMatchMakingSTEAM.search_lobby
function NetworkMatchMakingSTEAM:search_lobby(...)
	if Global.game_settings.single_player then
		return
	end
	orig_NetworkMatchMakingSTEAM_search_lobby(self, ...)
end
