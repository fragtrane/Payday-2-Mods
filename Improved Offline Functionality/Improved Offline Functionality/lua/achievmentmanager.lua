dofile(ModPath .. "lua/setup.lua")

--Fix for functions that use this to verify achievements
local orig_AchievmentManager_get_info = AchievmentManager.get_info
function AchievmentManager:get_info(id)
	local result = orig_AchievmentManager_get_info(self, id)
	
	--Check not awarded, and IOF enabled, and achievement is in IOF state
	--In theory, the locked outfit bug should not happen since state only gets updated when fetch achievements is successful
	--If it still happens, use freeze achievements setting to prevent achievement removal in the AchievmentManager.fetch_achievments() post hook
	if result and not result.awarded and IOF._settings.iof_community and IOF._state[id] then
		result = result or {}
		result.awarded = true
	end
	
	return result
end

--Debug: force error_str to "failure"
--Achievements will not be loaded in this case
--[[local orig_AchievmentManager_fetch_achievments = AchievmentManager.fetch_achievments
function AchievmentManager.fetch_achievments(error_str)
	error_str = "failure"
	orig_AchievmentManager_fetch_achievments(error_str)
	
	managers.achievment.achievments.mex_9.awarded = true
end]]

--Debug log error_str
--[[Hooks:PreHook(AchievmentManager, "fetch_achievments", "IOF_pre_AchievmentManager_fetch_achievments", function(error_str)
	log("fetch_achievments status: " .. tostring(error_str))
end)]]

--Why do outfits become locked again?
--Either error_str fails
--Or managers.achievment.handler:has_achievement(ach.id) fails
--We can check error_str
Hooks:PostHook(AchievmentManager, "fetch_achievments", "IOF_post_AchievmentManager_fetch_achievments", function(error_str)
	--Use IOF._fetched flag so we only do this once
	if Steam:logged_on() and not IOF._fetched then
		if error_str == "success" then
			--log("IOF fetch success")
			--Note: id and ach.id are the same
			for id, ach in pairs(managers.achievment.achievments) do
				local loc_result = IOF._state[ach.id] and true or false
				local srv_result = ach.awarded and true or false
				--local srv_result = managers.achievment.handler:has_achievement(ach.id) and true or false
				
				--Debug, local achievement but not on Steam
				--if loc_result and not srv_result then
				--	log("IOF local achievement not present on server: " .. ach.id)
				--end
				
				--Ignore if we have the achievement but could not validate it on Steam and iof_freeze_achi is enabled
				if loc_result and not srv_result and IOF._settings.iof_freeze_achi then
					--Ignore
					log("IOF freeze enabled, achievement not removed: " .. tostring(ach.id))
				else
					--Otherwise update the achi
					IOF._state[ach.id] = srv_result
				end
			end
			
			IOF:save_user_state()
			--Set IOF._fetched flag
			IOF._fetched = true
		end
	end
end)
