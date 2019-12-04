dofile(ModPath .. "lua/setup.lua")

--Check and save groups when online
local orig_NetworkAccountSTEAM_init = NetworkAccountSTEAM.init
function NetworkAccountSTEAM:init()
	orig_NetworkAccountSTEAM_init(self)

	if Steam:logged_on() then
		IOF._state.iof_has_pd2_clan = Steam:is_user_in_source(Steam:userid(), "103582791433980119")
		IOF._state.iof_has_dbd_clan = Steam:is_user_in_source(Steam:userid(), "103582791441335905")
		IOF._state.iof_has_solus_clan = Steam:is_user_in_source(Steam:userid(), "103582791438562929")
		IOF._state.iof_has_raidww2_clan = Steam:is_user_in_source(Steam:userid(), "103582791460014708")
		IOF:save_user_state()
	end
end

--Check and save achievements when online
local orig_NetworkAccountSTEAM_achievements_fetched = NetworkAccountSTEAM.achievements_fetched
function NetworkAccountSTEAM:achievements_fetched()
	orig_NetworkAccountSTEAM_achievements_fetched(self)

	if Steam:logged_on() then
		IOF._state.iof_has_bulldog_1 = managers.achievment:get_info("bulldog_1").awarded
		IOF._state.iof_has_sah_11 = managers.achievment:get_info("sah_11").awarded
		IOF._state.iof_has_dah_1 = managers.achievment:get_info("dah_1").awarded
		IOF._state.iof_has_nmh_1 = managers.achievment:get_info("nmh_1").awarded
		IOF._state.iof_has_glace_1 = managers.achievment:get_info("glace_1").awarded
		IOF._state.iof_has_mex_9 = managers.achievment:get_info("mex_9").awarded
		IOF._state.iof_has_sah_1 = managers.achievment:get_info("sah_1").awarded
		IOF._state.iof_has_wwh_1 = managers.achievment:get_info("wwh_1").awarded
		IOF:save_user_state()
	end
end
