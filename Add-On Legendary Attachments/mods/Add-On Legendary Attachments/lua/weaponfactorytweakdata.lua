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
				if self.parts[part_id.."_addon"].perks then
					if table.contains(self.parts[part_id.."_addon"].perks, "gadget") then
						self.parts[part_id.."_addon"].sub_type = "laser"
					end
				end
				--Raven's barrel sub_type is "silencer" which is wrong, but that gets overwritten so it's fine
			end
		end
	end
	
	--SRAB localization
	if _G.SRAB then
		local part_id = "wpn_fps_sho_ksg_b_legendary"
		if self.parts[part_id.."_addon"] then
			self.parts[part_id.."_addon"].name_id = "bm_wp_wpn_fps_sho_ksg_b_legendary_addon_srab"
		end
	end
end)
