dofile(ModPath .. "lua/setup.lua")

Hooks:PostHook(ECMJammerBase, "setup", "fragECM_post_ECMJammerBase_setup", function(self, ...)
--	if managers.groupai:state():whisper_mode() then
		local new_end_time = TimerManager:game():time() + self:battery_life()
		if not fragECM.end_time or fragECM.end_time < new_end_time then
			fragECM.end_time = new_end_time
		end
		fragECM:start_hud_update()
--	end
end)

Hooks:PostHook(ECMJammerBase, "sync_setup", "fragECM_post_ECMJammerBase_sync_setup", function(self, ...)
--	if managers.groupai:state():whisper_mode() then
		local new_end_time = TimerManager:game():time() + self:battery_life()
		if not fragECM.end_time or fragECM.end_time < new_end_time then
			fragECM.end_time = new_end_time
		end
		fragECM:start_hud_update()
--	end
end)

Hooks:PostHook(ECMJammerBase, "load", "fragECM_post_ECMJammerBase_load", function(self, ...)
--	if managers.groupai:state():whisper_mode() then
		local new_end_time = TimerManager:game():time() + self:battery_life()
		if not fragECM.end_time or fragECM.end_time < new_end_time then
			fragECM.end_time = new_end_time
		end
		fragECM:start_hud_update()
--	end
end)
