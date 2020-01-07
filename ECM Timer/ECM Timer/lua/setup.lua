--Don't do setup twice
if _G.fragECM then
	return
end

_G.fragECM = _G.fragECM or {}
fragECM._hud_active = false

--Commented code makes timer stealth only
--Don't really see a need for it, but leaving it here for future reference
function fragECM:start_hud_update()
	if not fragECM._hud_active then
		fragECM._hud_active = true
		Hooks:PostHook(HUDManager, "update", "fragECM_post_HUDManager_update", function(self, ...)
--			if managers.groupai:state():whisper_mode() then
				local current_time = TimerManager:game():time()
				if fragECM.end_time > current_time then
					managers.hud:update_ecm(fragECM.end_time - current_time)
				else
					managers.hud:update_ecm(0)
					Hooks:RemovePostHook("fragECM_post_HUDManager_update")
					fragECM._hud_active = false
				end
--			else
--				managers.hud:update_ecm(0)
--				Hooks:RemovePostHook("fragECM_post_HUDManager_update")
--				fragECM._hud_active = false
--			end
		end)
	end
end
