dofile(ModPath .. "lua/setup.lua")

--Enable Captain Winters, based on Unknown Knight's Simulate Online mod
local orig_GroupAIStateBesiege__check_spawn_phalanx = GroupAIStateBesiege._check_spawn_phalanx
function GroupAIStateBesiege:_check_spawn_phalanx(...)
	--Remove single player flag before performing Winters check
	--Probably safe
	local revert_sp = false
	if Global.game_settings.single_player and IOF._settings.iof_winters then
		Global.game_settings.single_player = nil
		revert_sp = true
	end
	
	--Winters check
	orig_GroupAIStateBesiege__check_spawn_phalanx(self, ...)
	
	--Revert single player flag
	if revert_sp then
		Global.game_settings.single_player = true
	end
end
