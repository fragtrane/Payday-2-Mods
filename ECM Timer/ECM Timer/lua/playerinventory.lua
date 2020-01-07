dofile(ModPath .. "lua/setup.lua")

Hooks:PostHook(PlayerInventory, "_start_jammer_effect", "fragECM_post_PlayerInventory__start_jammer_effect", function(self, end_time)
--	if managers.groupai:state():whisper_mode() then
		local new_end_time = end_time or TimerManager:game():time() + self:get_jammer_time()
		if not fragECM.end_time or fragECM.end_time < new_end_time then
			fragECM.end_time = new_end_time
		end
		fragECM:start_hud_update()
--	end
end)
