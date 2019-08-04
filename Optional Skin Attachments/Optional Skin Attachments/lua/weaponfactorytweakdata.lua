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
	for weapon, parts in pairs(OSA._gen_1_mods) do
		for _, part_id in pairs(parts) do
			for k, v in pairs(new_values) do
				self.parts[part_id][k] = v
			end
			if OSA._settings.osa_remove_stats then
				local val = 0
				if self.parts[part_id].stats then
					val = self.parts[part_id].stats.value or val
				end
				self.parts[part_id].stats = {value = val}
			end
			self.parts[part_id].name_id = "osa_bm_"..part_id
			self.parts[part_id].desc_id = "osa_bm_req_"..weapon
		end
	end
	
end