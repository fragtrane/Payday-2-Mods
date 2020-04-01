dofile(ModPath .. "lua/setup.lua")

--Delete chute after interaction to prevent respawning
Hooks:PostHook(ObjectInteractionManager, "remove_unit", "bosbc_ObjectInteractionManager_remove_unit", function(self, unit)
	local level_id = Global.game_settings.level_id
	if level_id == "pbr2" and not Network:is_client() and BOSBC:check() then
		if unit and tostring(unit:name()) == tostring(Idstring("units/pd2_dlc_jerry/pickups/gen_pku_parachute/gen_pku_parachute")) then
			local pos_string = tostring(unit:position())
			table.insert(BOSBC._picked_up, pos_string)
			DelayedCalls:Add("bosbc_delayed_delete_"..pos_string, 1, function()
				BOSBC:remove_picked_up()
			end)
		end
	end
end)
