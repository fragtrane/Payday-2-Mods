dofile(ModPath .. "lua/setup.lua")

--Stance mod fix for add-on Santa's Slayers Laser
local orig_NewRaycastWeaponBase_stance_mod = NewRaycastWeaponBase.stance_mod
function NewRaycastWeaponBase:stance_mod()
	if not AOLA._settings.aola_no_crosskill_fix then
		--Do same check as original
		if not self._blueprint or not self._factory_id then
			return nil
		end
		
		--If using single Crosskill with add-on Santa's Slayers Laser, set using_second_sight to true so the stance mod gets applied
		if self._factory_id == "wpn_fps_pis_1911" and table.contains(self._blueprint, "wpn_fps_pis_1911_fl_legendary_addon") then
			return managers.weapon_factory:get_stance_mod(self._factory_id, self._blueprint, true)
		end
	end
	
	--Original function
	return orig_NewRaycastWeaponBase_stance_mod(self)
end
