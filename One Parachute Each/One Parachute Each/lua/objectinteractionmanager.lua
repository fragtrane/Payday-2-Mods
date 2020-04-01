--Delete chute after interaction to prevent respawning
Hooks:PostHook(ObjectInteractionManager, "remove_unit", "OneChuteEach_ObjectInteractionManager_remove_unit", function(self, unit)
	local level_id = Global.game_settings.level_id
	--If Birth of Sky, not client, and not BOSBC or BOSBC not active
	if level_id == "pbr2" and not Network:is_client() and (not _G.BOSBC or not BOSBC:check()) then
		if unit and tostring(unit:name()) == tostring(Idstring("units/pd2_dlc_jerry/pickups/gen_pku_parachute/gen_pku_parachute")) then
			_G.OneChuteEach = _G.OneChuteEach or {}
			local pos_string = tostring(unit:position())
			table.insert(_G.OneChuteEach, pos_string)
			DelayedCalls:Add("OneChuteEach_delayed_delete_"..pos_string, 1, function()
				local unit_list = World:find_units_quick("all")
				for _, unit in ipairs(unit_list) do
					if tostring(unit:name()) == tostring(Idstring("units/pd2_dlc_jerry/pickups/gen_pku_parachute/gen_pku_parachute")) then
						if table.contains(_G.OneChuteEach or {}, tostring(unit:position())) then
							World:delete_unit(unit)
						end
					end
				end
			end)
		end
	end
end)
