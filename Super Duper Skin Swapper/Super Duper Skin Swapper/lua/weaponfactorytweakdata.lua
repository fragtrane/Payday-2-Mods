dofile(ModPath .. "lua/setup.lua")

--Set some adds/forbids to prevent legendary attachment clipping.
--Do not add or delete legendary mods from uses_parts, can cause sync issues/cheater tags.
Hooks:PostHook(WeaponFactoryTweakData, "init", "sdss_post_WeaponFactoryTweakData_init", function(self)
	--Big Kahuna / Demon
	--Default body adds default grip
	self.parts.wpn_fps_shot_r870_body_standard.adds = self.parts.wpn_fps_shot_r870_body_standard.adds or {}
	table.insert(self.parts.wpn_fps_shot_r870_body_standard.adds, "wpn_fps_upg_m4_g_standard")
	
	--Reinfeld and Locomotive grips forbid default grip
	for _, part_id in pairs(self.wpn_fps_shot_r870.uses_parts) do
		if self.parts[part_id] and self.parts[part_id].type == "grip" and part_id ~= "wpn_fps_upg_m4_g_standard" then
			self.parts[part_id].forbids = self.parts[part_id].forbids or {}
			if not table.contains(self.parts[part_id].forbids, "wpn_fps_upg_m4_g_standard") then
				table.insert(self.parts[part_id].forbids, "wpn_fps_upg_m4_g_standard")
			end
		end
	end
	for _, part_id in pairs(self.wpn_fps_shot_serbu.uses_parts) do
		if self.parts[part_id] and self.parts[part_id].type == "grip" and part_id ~= "wpn_fps_upg_m4_g_standard" then
			self.parts[part_id].forbids = self.parts[part_id].forbids or {}
			if not table.contains(self.parts[part_id].forbids, "wpn_fps_upg_m4_g_standard") then
				table.insert(self.parts[part_id].forbids, "wpn_fps_upg_m4_g_standard")
			end
		end
	end
	
	--Mars Ultor
	--Default lower receiver adds default barrel extension
	self.parts.wpn_fps_ass_tecci_lower_reciever.adds = self.parts.wpn_fps_ass_tecci_lower_reciever.adds or {}
	table.insert(self.parts.wpn_fps_ass_tecci_lower_reciever.adds, "wpn_fps_ass_tecci_ns_standard")
	
	--Bootleg barrel extensions forbid default barrel extension
	for _, part_id in pairs(self.wpn_fps_ass_tecci.uses_parts) do
		if self.parts[part_id] and self.parts[part_id].type == "barrel_ext" and part_id ~= "wpn_fps_ass_tecci_ns_standard" then
			self.parts[part_id].forbids = self.parts[part_id].forbids or {}
			if not table.contains(self.parts[part_id].forbids, "wpn_fps_ass_tecci_ns_standard") then
				table.insert(self.parts[part_id].forbids, "wpn_fps_ass_tecci_ns_standard")
			end
		end
	end	
end)

--Set up legendary parts
Hooks:PostHook(WeaponFactoryTweakData, "_init_legendary", "sdss_post_WeaponFactoryTweakData__init_legendary", function(self)
	--Set up legendary parts
	local new_values = {
		pcs = {},--Without this, the part gets flagged as inaccessible
		is_a_unlockable = true,--Set unlockable so it can't be dropped/bought
		is_legendary_part = true,--SDSS tracking
		has_description = true--So that we can set custom descriptions
	}
	
	--Set new values, remove stats, set name/description
	for skin, part_list in pairs(SDSS._gen_1_mods) do
		for _, part_id in pairs(part_list) do
			--Set new values
			for k, v in pairs(new_values) do
				self.parts[part_id][k] = v
			end
			
			--Remove stats
			if SDSS._settings.sdss_remove_stats then
				local val = 0
				if self.parts[part_id].stats then
					val = self.parts[part_id].stats.value or val
				end
				--Don't remove stats on SRAB
				--Note: SRAB 1.1 and future legendary stat mods will PreHook _set_inaccessibles so removing stats here won't be an issue anymore
				--SRAB 1.1 will use the identifier _G.SuppressedRavenAdmiralBarrel so we just keep this old check here for backwards compatiblity until everyone updates
				if not _G.SRAB or part_id ~= "wpn_fps_sho_ksg_b_legendary" then
					self.parts[part_id].stats = {value = val}
				end
			end
			
			--Set name and description
			self.parts[part_id].name_id = "sdss_bm_"..part_id
			self.parts[part_id].desc_id = "sdss_bm_req_"..skin
			
			--Set sub_type to "laser" so the color can be changed
			if self.parts[part_id].perks then
				if table.contains(self.parts[part_id].perks, "gadget") then
					self.parts[part_id].sub_type = "laser"
				end
			end
			--Raven's barrel sub_type is "silencer" which is wrong, but it has a gadget so that gets overwritten here
		end
	end
	
	--Localization for Suppressed Raven Admiral Barrel mod
	--Legacy support for _G.SRAB identifier used by v1.0
	if _G.SuppressedRavenAdmiralBarrel or _G.SRAB then
		self.parts.wpn_fps_sho_ksg_b_legendary.name_id = "sdss_bm_wpn_fps_sho_ksg_b_legendary_sup"
	end
	
	--Localization for Suppressed Judge Anarcho Barrel mod
	if _G.SuppressedJudgeAnarchoBarrel then
		self.parts.wpn_fps_pis_judge_b_legend.name_id = "sdss_bm_wpn_fps_pis_judge_b_legend_sup"
	end
	
	--Localization for Suppressed AMR-16 Astatoz Barrel mod
	if _G.SuppressedAMR16AstatozBarrel then
		self.parts.wpn_fps_ass_m16_b_legend.name_id = "sdss_bm_wpn_fps_ass_m16_b_legend_sup"
	end
	
	--Localization for Suppressed Breaker 12G Apex Barrel mod
	if _G.SuppressedBreaker12GApexBarrel then
		self.parts.wpn_fps_sho_boot_b_legendary.name_id = "sdss_bm_wpn_fps_sho_boot_b_legendary_sup"
	end
	
	--Localization for Suppressed Deagle Midas Touch Barrel mod
	if _G.SuppressedDeagleMidasTouchBarrel then
		self.parts.wpn_fps_pis_deagle_b_legend.name_id = "sdss_bm_wpn_fps_pis_deagle_b_legend_sup"
	end
	
	--Localization for Suppressed Locomotive 12G Demon Barrel mod
	if _G.SuppressedLocomotive12GDemonBarrel then
		self.parts.wpn_fps_shot_shorty_b_legendary.name_id = "sdss_bm_wpn_fps_shot_shorty_b_legendary_sup"
	end
	
	--Fix foregrip on Raven Admiral
	--Without this, the foregrip will disappear if you apply the Short Barrel then switch to the Admiral Barrel
	--Use insert so we don't overwrite SRAB's forbids
	self.parts.wpn_fps_sho_ksg_b_legendary.forbids = self.parts.wpn_fps_sho_ksg_b_legendary.forbids or {}
	table.insert(self.parts.wpn_fps_sho_ksg_b_legendary.forbids, "wpn_fps_sho_ksg_fg_short")
	self.parts.wpn_fps_sho_ksg_b_legendary.adds = self.parts.wpn_fps_sho_ksg_b_legendary.adds or {}
	table.insert(self.parts.wpn_fps_sho_ksg_b_legendary.adds, "wpn_fps_sho_ksg_fg_standard")
	
	--Big Kahuna
	--Legendary stock forbids default grip
	self.parts.wpn_fps_shot_r870_s_legendary.forbids = self.parts.wpn_fps_shot_r870_s_legendary.forbids or {}
	table.insert(self.parts.wpn_fps_shot_r870_s_legendary.forbids, "wpn_fps_upg_m4_g_standard")
	
	--Demon
	--Legendary stock forbids default grip
	self.parts.wpn_fps_shot_shorty_s_legendary.forbids = self.parts.wpn_fps_shot_shorty_s_legendary.forbids or {}
	table.insert(self.parts.wpn_fps_shot_shorty_s_legendary.forbids, "wpn_fps_upg_m4_g_standard")
	
	--Mars Ultor
	--Legendary barrel forbids default barrel extension
	self.parts.wpn_fps_ass_tecci_b_legend.forbids = self.parts.wpn_fps_ass_tecci_b_legend.forbids or {}
	table.insert(self.parts.wpn_fps_ass_tecci_b_legend.forbids, "wpn_fps_ass_tecci_ns_standard")
	
	--Astatoz
	--Legendary foregrip type changed to "foregrip" (instead of "gadget")
	self.parts.wpn_fps_ass_m16_fg_legend.type = "foregrip"
	
	--Vlad's Rodina
	--Legendary stock adds default grip
	--Legendary grip forbids default grip
	self.parts.wpn_upg_ak_s_legend.adds = self.parts.wpn_upg_ak_s_legend.adds or {}
	table.insert(self.parts.wpn_upg_ak_s_legend.adds, "wpn_upg_ak_g_standard")
	self.parts.wpn_upg_ak_g_legend.forbids = self.parts.wpn_upg_ak_g_legend.forbids or {}
	table.insert(self.parts.wpn_upg_ak_g_legend.forbids, "wpn_upg_ak_g_standard")
end)
