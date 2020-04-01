dofile(ModPath .. "lua/setup.lua")

Hooks:PostHook(IngameFreefall, "at_exit", "bosbc_post_IngameFreefall_at_exit", function(...)
	BOSBC._landed = true
end)
