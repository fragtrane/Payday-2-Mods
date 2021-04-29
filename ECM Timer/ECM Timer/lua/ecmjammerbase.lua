--When playing as host.
Hooks:PostHook(ECMJammerBase, "setup", "fragECM_post_ECMJammerBase_setup", function(self, ...)
--	log("ECM: setup")
	local new_end_time = TimerManager:game():time() + self:battery_life()
	if new_end_time > managers.hud._hud_ecm_counter._end_time then
		managers.hud._hud_ecm_counter._end_time = new_end_time
	end
end)

--When playing as a client.
Hooks:PostHook(ECMJammerBase, "sync_setup", "fragECM_post_ECMJammerBase_sync_setup", function(self, ...)
--	log("ECM: sync_setup")
	local new_end_time = TimerManager:game():time() + self:battery_life()
	if new_end_time > managers.hud._hud_ecm_counter._end_time then
		managers.hud._hud_ecm_counter._end_time = new_end_time
	end
end)

--This happens when you drop in and an ECM was already placed.
--The state data sent by the host does not include the battery life so there's nothing we can do.
--State data is set in function ECMJammerBase:save()
--[[
Hooks:PostHook(ECMJammerBase, "load", "fragECM_post_ECMJammerBase_load", function(self, data)
	log("ECM: load")
	local state = data.ECMJammerBase
end)
]]
