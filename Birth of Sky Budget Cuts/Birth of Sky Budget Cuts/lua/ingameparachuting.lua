dofile(ModPath .. "lua/setup.lua")

Hooks:PostHook(IngameParachuting, "at_exit", "bosbc_post_IngameParachuting_at_exit", function(...)
	BOSBC._landed = true
end)
