dofile(ModPath .. "lua/setup.lua")

--Delete legendary mods from akimbo variants of Kobus 90 and Judge
--Akimbo Deagles / single Crosskill don't have this problem
local orig_WeaponFactoryTweakData_init = WeaponFactoryTweakData.init
function WeaponFactoryTweakData:init()
	orig_WeaponFactoryTweakData_init(self)
	
	--Alamo Dallas
	table.delete(self.wpn_fps_smg_x_p90.uses_parts, "wpn_fps_smg_p90_b_legend")

	--Anarcho
	table.delete(self.wpn_fps_pis_x_judge.uses_parts, "wpn_fps_pis_judge_b_legend")
	table.delete(self.wpn_fps_pis_x_judge.uses_parts, "wpn_fps_pis_judge_g_legend")
end

--Set up legendary parts
local orig_WeaponFactoryTweakData__init_legendary = WeaponFactoryTweakData._init_legendary
function WeaponFactoryTweakData:_init_legendary()
	orig_WeaponFactoryTweakData__init_legendary(self)
	
	local new_values = {
		pcs = {},--Without this, the part gets flagged as inaccessible
		is_a_unlockable = true,--Set unlockable so it can't be dropped/bought
		is_legendary_part = true,--OSA tracking
		has_description = true--So that we can set custom descriptions
	}
	
	--Set new values, remove stats, set name/description
	for skin, part_list in pairs(OSA._gen_1_mods) do
		for _, part_id in pairs(part_list) do
			for k, v in pairs(new_values) do
				self.parts[part_id][k] = v
			end
			if OSA._settings.osa_remove_stats then
				local val = 0
				if self.parts[part_id].stats then
					val = self.parts[part_id].stats.value or val
				end
				--Don't remove stats on SRAB
				if not _G.SRAB or part_id ~= "wpn_fps_sho_ksg_b_legendary" then
					self.parts[part_id].stats = {value = val}
				end
			end
			self.parts[part_id].name_id = "osa_bm_"..part_id
			self.parts[part_id].desc_id = "osa_bm_req_"..skin
		end
	end
	
	--Fix foregrip on Raven Admiral
	--Without this, the foregrip will disappear if you apply the Short Barrel then switch to the Admiral Barrel
	--Use insert so we don't overwrite SRAB's forbids
	self.parts.wpn_fps_sho_ksg_b_legendary.forbids = self.parts.wpn_fps_sho_ksg_b_legendary.forbids or {}
	table.insert(self.parts.wpn_fps_sho_ksg_b_legendary.forbids, "wpn_fps_sho_ksg_fg_short")
	self.parts.wpn_fps_sho_ksg_b_legendary.adds = self.parts.wpn_fps_sho_ksg_b_legendary.adds or {}
	table.insert(self.parts.wpn_fps_sho_ksg_b_legendary.adds, "wpn_fps_sho_ksg_fg_standard")
end
