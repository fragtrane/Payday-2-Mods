dofile(ModPath .. "lua/setup.lua")

--v3.0
--We let BlackMarketGui:_weapon_cosmetics_callback build the params for us
--The we hijack the confirm dialog and call our own
function MenuManager:show_confirm_weapon_cosmetics(params)
	OSA:weapon_cosmetics_handler(params)
end
