dofile(ModPath .. "lua/setup.lua")

--Set some adds/forbids to prevent legendary attachment clipping.
--Do not add or delete legendary mods from uses_parts here, can cause sync issues/cheater tags.
Hooks:PostHook(WeaponFactoryTweakData, "init", "sdss_post_WeaponFactoryTweakData_init", function(self)
	if not SDSS._settings.sdss_allow_variants then
		--Change to dummy part to hide
		for i, part_id in ipairs(self.wpn_fps_smg_x_p90.uses_parts) do
			if part_id == "wpn_fps_smg_p90_b_legend" then
				self.wpn_fps_smg_x_p90.uses_parts[i] = "wpn_fps_smg_p90_b_legend_dummy"
			end
		end
		for i, part_id in ipairs(self.wpn_fps_pis_x_judge.uses_parts) do
			if part_id == "wpn_fps_pis_judge_b_legend" then
				self.wpn_fps_pis_x_judge.uses_parts[i] = "wpn_fps_pis_judge_b_legend_dummy"
			elseif part_id == "wpn_fps_pis_judge_g_legend" then
				self.wpn_fps_pis_x_judge.uses_parts[i] = "wpn_fps_pis_judge_g_legend_dummy"
			end
		end
	end
	
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

--Insert legendary parts AFTER bonuses. Otherwise, when peers send index of bonus in outfit string, we will think it is a legendary part.
--If someone also extends their uses_parts table with other attachments, we might think that they are using a legendary attachment -> handle in NetworkPeer, don't flag if legendary attachment is not on original gun.
Hooks:PostHook(WeaponFactoryTweakData, "create_bonuses", "sdss_post_WeaponFactoryTweakData_create_bonuses", function(self, ...)
	if SDSS._settings.sdss_allow_variants then
		--Midas Touch
		--Invisible in third person on akimbo for both vanilla and modded peers, as both client and host.
		table.insert(self.wpn_fps_x_deagle.uses_parts, "wpn_fps_pis_deagle_b_legend")
		
		--Santa's Slayers
		--Invisible in third person on single for both vanilla and modded peers, as both client and host.
		table.insert(self.wpn_fps_pis_1911.uses_parts, "wpn_fps_pis_1911_g_legendary")
		table.insert(self.wpn_fps_pis_1911.uses_parts, "wpn_fps_pis_1911_fl_legendary")
	end
end)

--Set up legendary parts
Hooks:PostHook(WeaponFactoryTweakData, "_init_legendary", "sdss_post_WeaponFactoryTweakData__init_legendary", function(self)
	--Set up dummy parts
	--Used when "allow variants" is off, this way we can hide the legendary parts from the akimbos in inventory.
	--Set unatainable to nil to prevent false cheater tags since dummy part isn't in default_blueprint.
	--Edge case: someone cheats legendary skin, puts it on akimbo variant, and you have disabled variants -> not detected.
	self.parts.wpn_fps_smg_p90_b_legend_dummy = deep_clone(self.parts.wpn_fps_smg_p90_b_legend)
	self.parts.wpn_fps_smg_p90_b_legend_dummy.unatainable = nil
	
	self.parts.wpn_fps_pis_judge_b_legend_dummy = deep_clone(self.parts.wpn_fps_pis_judge_b_legend)
	self.parts.wpn_fps_pis_judge_b_legend_dummy.unatainable = nil
	
	self.parts.wpn_fps_pis_judge_g_legend_dummy = deep_clone(self.parts.wpn_fps_pis_judge_g_legend)
	self.parts.wpn_fps_pis_judge_g_legend_dummy.unatainable = nil
	
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
			for k, v in pairs(new_values) do
				self.parts[part_id][k] = v
			end
			self.parts[part_id].name_id = "sdss_bm_"..part_id
			self.parts[part_id].desc_id = "sdss_bm_req_"..skin
		end
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
