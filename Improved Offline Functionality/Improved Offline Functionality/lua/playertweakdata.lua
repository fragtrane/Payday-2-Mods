dofile(ModPath .. "lua/setup.lua")

--Disable armor regeneration bonus, based on Unknown Knight's Simulate Online mod
local orig_PlayerTweakData__set_singleplayer = PlayerTweakData._set_singleplayer
function PlayerTweakData:_set_singleplayer()
	if IOF._settings.iof_armor then
		return
	end
	orig_PlayerTweakData__set_singleplayer(self)
end
