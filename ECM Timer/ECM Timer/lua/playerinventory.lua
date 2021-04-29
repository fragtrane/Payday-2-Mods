--Pocket ECMs
Hooks:PostHook(PlayerInventory, "_start_jammer_effect", "fragECM_post_PlayerInventory__start_jammer_effect", function(self, end_time)
	local new_end_time = end_time or TimerManager:game():time() + self:get_jammer_time()
	if new_end_time > managers.hud._hud_ecm_counter._end_time then
		managers.hud._hud_ecm_counter._end_time = new_end_time
	end
end)
