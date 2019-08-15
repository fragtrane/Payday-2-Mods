dofile(ModPath .. "lua/setup.lua")

--Community content
local orig_WINDLCManager__check_dlc_data = WINDLCManager._check_dlc_data
function WINDLCManager:_check_dlc_data(dlc_data)
	if not Steam:logged_on() and IOF._settings.iof_community then
		if dlc_data.source_id then
			if dlc_data.source_id == "103582791433980119" then
				return IOF._state.iof_has_pd2_clan
			elseif dlc_data.source_id == "103582791441335905" then
				return IOF._state.iof_has_dbd_clan
			elseif dlc_data.source_id == "103582791438562929" then
				return IOF._state.iof_has_solus_clan
			elseif dlc_data.source_id == "103582791460014708" then
				return IOF._state.iof_has_raidww2_clan
			end
		end
	end
	
	return orig_WINDLCManager__check_dlc_data(self, dlc_data)
end

--Why Don't We Just Use a Spoon? achievement (Hoxton, Nova's Shank)
local orig_GenericDLCManager_has_freed_old_hoxton = GenericDLCManager.has_freed_old_hoxton
function GenericDLCManager:has_freed_old_hoxton(data)
	if not Steam:logged_on() and IOF._settings.iof_community then
		return IOF._state.iof_has_pd2_clan and IOF._state.iof_has_bulldog_1
	end
	
	return orig_GenericDLCManager_has_freed_old_hoxton(self, data)
end
