dofile(ModPath .. "lua/setup.lua")

--Check and save groups when online
Hooks:PostHook(NetworkAccountSTEAM, "init", "IOF_post_NetworkAccountSTEAM_init", function()
	if Steam:logged_on() then
		IOF._state.pd2_clan = Steam:is_user_in_source(Steam:userid(), "103582791433980119")
		IOF._state.dbd_clan = Steam:is_user_in_source(Steam:userid(), "103582791441335905")
		IOF._state.solus_clan = Steam:is_user_in_source(Steam:userid(), "103582791438562929")
		IOF._state.raidww2_clan = Steam:is_user_in_source(Steam:userid(), "103582791460014708")
		IOF:save_user_state()
	end
end)
