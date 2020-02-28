dofile(ModPath .. "lua/setup.lua")

--Check and save groups when online
local orig_NetworkAccountSTEAM_init = NetworkAccountSTEAM.init
function NetworkAccountSTEAM:init()
	orig_NetworkAccountSTEAM_init(self)

	if Steam:logged_on() then
		IOF._state.pd2_clan = Steam:is_user_in_source(Steam:userid(), "103582791433980119")
		IOF._state.dbd_clan = Steam:is_user_in_source(Steam:userid(), "103582791441335905")
		IOF._state.solus_clan = Steam:is_user_in_source(Steam:userid(), "103582791438562929")
		IOF._state.raidww2_clan = Steam:is_user_in_source(Steam:userid(), "103582791460014708")
		IOF:save_user_state()
	end
end

--Check and save achievements when online
local orig_NetworkAccountSTEAM_achievements_fetched = NetworkAccountSTEAM.achievements_fetched
function NetworkAccountSTEAM:achievements_fetched()
	orig_NetworkAccountSTEAM_achievements_fetched(self)

	if Steam:logged_on() then
		for id, _ in pairs(IOF._state) do
			if managers.achievment:get_info(id) and managers.achievment:get_info(id).awarded then
				IOF._state[id] = true
			end
		end
		IOF:save_user_state()
	end
end
