Hooks:PostHook(GenericDLCManager, "init_finalize", "srab_post_GenericDLCManager_init_finalize", function(self, ...)
	--If using AOLA, override based-on parts to reduce concealment sync issues
	if _G.AOLA then
		--Check that DLC is unlocked, because setting based-on for a DLC part you don't own will cause a cheater tag
		--In this case the weapon and attachment are from the same DLC so this is actually redundant, but hey better be safe
		if self:is_dlc_unlocked("gage_pack_shotgun") then
			local part_data = tweak_data.weapon.factory.parts.wpn_fps_sho_ksg_b_legendary_addon
			--Change based-on to Short Barrel
			--Note: this ONLY works if the new based-on attachment has the same type, otherwise it crashes other people's games
			if part_data then
				part_data.based_on = "wpn_fps_sho_ksg_b_short"
			end
		end
	end
end)
