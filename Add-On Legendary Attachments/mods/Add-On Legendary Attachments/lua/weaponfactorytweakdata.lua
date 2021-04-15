dofile(ModPath .. "lua/setup.lua")

--Priority: SRAB -> OSA/SDSS -> AOLA
--OSA/SDSS hook to _init_legendary() to modify legendary parts.
--AOLA hooks to init(), so _init_legendary() has already run. So the changes made by OSA/SDSS are cloned.
Hooks:PostHook(WeaponFactoryTweakData, "init", "AOLA_post_WeaponFactoryTweakData_init", function(self)
	--Hide parts if dependencies are missing
	if AOLA.missing_dependency then
		for skin_id, parts in pairs(AOLA._gen_1_mods) do
			for _, part_id in pairs(parts) do
				local addon = self.parts[part_id.."_addon"]
				if addon then
					addon.pcs = nil
				end
			end
		end
		return
	end
	
	--Copy data from legendary part to add-on part
	local ignore = {
		"type",--Set in BeardLib
		"name_id",--Automatically set in BeardLib
		"texture_bundle_folder",--Set in BeardLib
		"is_a_unlockable",--Set in BeardLib
		"dlc",--Will remove
		"unatainable",--Will remove
		"pcs",--Set by SDSS / OSA, will overwrite
		"is_legendary_part",--Set by SDSS / OSA, not copied
		"has_description",--Set by SDSS / OSA, will overwrite
		"desc_id"--Set by SDSS / OSA, will overwrite
	}
	for skin_id, parts in pairs(AOLA._gen_1_mods) do
		for _, part_id in pairs(parts) do
			local addon = self.parts[part_id.."_addon"]
			if addon then
				for k, v in pairs(self.parts[part_id]) do
					if not table.contains(ignore, k) then
						if tostring(type(v)) == "table" then
							self.parts[part_id.."_addon"][k] = deep_clone(v)
						else
							self.parts[part_id.."_addon"][k] = v
						end
					end
				end
				self.parts[part_id.."_addon"].has_description = true
				self.parts[part_id.."_addon"].desc_id = "bm_wp_req_"..skin_id.."_desc"
				self.parts[part_id.."_addon"].pcs = {}
				
				self.parts[part_id.."_addon"].dlc = nil--Just in case
				self.parts[part_id.."_addon"].unatainable = nil--Just in case
				
				--Remove stuff that was copied from "based_on" part but isn't in the legendary attachment
				--e.g. prevents Raven's front sight from being moved, might fix some other things
				local based_on = AOLA._based_on[part_id.."_addon"]
				for k, v in pairs(self.parts[part_id.."_addon"]) do
					--if not ignore, and based_on not nil, and real part nil, and addon has same value as based_on (i.e. was copied)
					--Last value check does not check tables and just assumes they are the same, if there issues in the future, add key to ignore list
					if not table.contains(ignore, k) and self.parts[based_on][k] ~= nil and self.parts[part_id][k] == nil and (v == self.parts[based_on][k] or tostring(type(v)) == "table") then
						self.parts[part_id.."_addon"][k] = nil
					end
				end
				
				--Set sub_type to "laser" so the color can be changed
				--SDSS/OSA sets this as well but we may not be using those mods
				--Raven's barrel sub_type is "silencer" which is wrong, but it has a gadget so that gets overwritten here
				if self.parts[part_id.."_addon"].perks then
					if table.contains(self.parts[part_id.."_addon"].perks, "gadget") then
						self.parts[part_id.."_addon"].sub_type = "laser"
					end
				end
			end
		end
	end
	
	--Set unit to our addon part
	--Don't need to do this anymore since we aren't making it a standalone mod
	--self.parts["wpn_fps_snp_model70_ns_suppressor_addon"].unit = "units/aola/weapons/wpn_fps_snp_model70_pts/wpn_fps_snp_model70_ns_suppressor_addon"
	
	--Default Platypus barrel forbids add-on silencer
	--Don't need to do this anymore since we aren't making it a standalone mod
	--self.parts.wpn_fps_snp_model70_b_standard.forbids = {"wpn_fps_snp_model70_ns_suppressor_addon"}
	
	--Original Beak Suppressor third unit
	local third_unit = self.parts.wpn_fps_snp_model70_ns_suppressor.third_unit
	--AOLA Beak Suppressor unit
	local unit = "units/aola/weapons/wpn_fps_snp_model70_pts/wpn_fps_snp_model70_ns_suppressor_addon"
	
	if self.parts.wpn_fps_snp_model70_ns_suppressor_addon then
		--Set replacements if not using PBSR, or if PBSR override is off
		if not _G.BeakSuppressorReplacements or (_G.BeakSuppressorReplacements and _G.BeakSuppressorReplacements._settings and not _G.BeakSuppressorReplacements._settings.pbsr_override_aola) then
			--Set overrides for Don Pastrami Barrel
			self.parts.wpn_fps_snp_model70_b_legend.override = self.parts.wpn_fps_snp_model70_b_legend.override or {}
			self.parts.wpn_fps_snp_model70_b_legend.override.wpn_fps_snp_model70_ns_suppressor = {
				third_unit = third_unit,
				unit = unit
			}
			--Set overrides for Add-On Don Pastrami Barrel
			self.parts.wpn_fps_snp_model70_b_legend_addon.override = self.parts.wpn_fps_snp_model70_b_legend_addon.override or {}
			self.parts.wpn_fps_snp_model70_b_legend_addon.override.wpn_fps_snp_model70_ns_suppressor = {
				third_unit = third_unit,
				unit = unit
			}
		end
	end
	
	--Localization for Suppressed Raven Admiral Barrel mod
	--Legacy support for _G.SRAB identifier used by v1.0
	if _G.SuppressedRavenAdmiralBarrel or _G.SRAB then
		--Change localization
		local part_id = "wpn_fps_sho_ksg_b_legendary"
		if self.parts[part_id.."_addon"] then
			self.parts[part_id.."_addon"].name_id = "bm_wp_" .. part_id .. "_addon_sup"
		end
		--Dragon's Breath rounds block suppressors
		table.insert(self.parts.wpn_fps_upg_a_dragons_breath.forbids, part_id.."_addon")
	end
	
	--Localization for Suppressed Judge Anarcho Barrel mod
	if _G.SuppressedJudgeAnarchoBarrel then
		--Change localization
		local part_id = "wpn_fps_pis_judge_b_legend"
		if self.parts[part_id.."_addon"] then
			self.parts[part_id.."_addon"].name_id = "bm_wp_" .. part_id .. "_addon_sup"
		end
		--Dragon's Breath rounds block suppressors
		table.insert(self.parts.wpn_fps_upg_a_dragons_breath.forbids, part_id.."_addon")
	end
	
	--Localization for Suppressed AMR-16 Astatoz Barrel mod
	if _G.SuppressedAMR16AstatozBarrel then
		--Change localization
		local part_id = "wpn_fps_ass_m16_b_legend"
		if self.parts[part_id.."_addon"] then
			self.parts[part_id.."_addon"].name_id = "bm_wp_" .. part_id .. "_addon_sup"
		end
	end
	
	--Localization for Suppressed Breaker 12G Apex Barrel mod
	if _G.SuppressedBreaker12GApexBarrel then
		--Change localization
		local part_id = "wpn_fps_sho_boot_b_legendary"
		if self.parts[part_id.."_addon"] then
			self.parts[part_id.."_addon"].name_id = "bm_wp_" .. part_id .. "_addon_sup"
		end
	end
	
	--Localization for Suppressed Deagle Midas Touch Barrel mod
	if _G.SuppressedDeagleMidasTouchBarrel then
		--Change localization
		local part_id = "wpn_fps_pis_deagle_b_legend"
		if self.parts[part_id.."_addon"] then
			self.parts[part_id.."_addon"].name_id = "bm_wp_" .. part_id .. "_addon_sup"
		end
	end
	
	--Localization for Suppressed Locomotive 12G Demon Barrel mod
	if _G.SuppressedLocomotive12GDemonBarrel then
		--Change localization
		local part_id = "wpn_fps_shot_shorty_b_legendary"
		if self.parts[part_id.."_addon"] then
			self.parts[part_id.."_addon"].name_id = "bm_wp_" .. part_id .. "_addon_sup"
		end
	end
end)
