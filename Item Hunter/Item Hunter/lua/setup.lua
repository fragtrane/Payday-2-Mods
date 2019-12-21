--Don't do setup twice
if _G.ItemHunter then
	return
end

_G.ItemHunter = _G.ItemHunter or {}
ItemHunter._mod_path = ModPath
ItemHunter._prefix = "itmhnt_"--Prefix for identifying custom waypoints
ItemHunter._enabled = false

--State information for managing waypoints
ItemHunter._state = {}
--Spooky Pumpkin (trophy_spooky)
ItemHunter._state.trophy_spooky = {}
ItemHunter._state.trophy_spooky.pumpkin_id = 0
--Heavy Metal (sah_11)
ItemHunter._state.sah_11 = {}
ItemHunter._state.sah_11.civ_tied = false
ItemHunter._state.sah_11.civ_dead = false
ItemHunter._state.sah_11.wrench_dropped = false

--Load item data
dofile(ItemHunter._mod_path.."lua/item_data.lua")

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "ItemHunter_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(ItemHunter._mod_path.."localizations/english.txt")
end)

--Set up display states
--self._state.display is table of states indexed starting from 0
--self._state.display_state is an integer corresponding to the index of the current state
function ItemHunter:init_states()
	local level_id = Global.game_settings.level_id
	local dif = Global.game_settings.difficulty
	local host = Global.game_settings.single_player or Network:is_server()
	--Look for how many achievements there are to hunt
	local achis = {}
	for achi, data in pairs(self.item_data) do
		local check_ok = true
		--Check level
		if data.level ~= level_id and not (data.level == "multiple" and table.contains(data.levels, level_id)) and not (data.level == "any" and (not data.exclude or not table.contains(data.exclude, level_id))) then
			check_ok = false
		end
		--Check difficulty
		if data.difficulty and not table.contains(data.difficulty, dif) then
			check_ok = false
		end
		--Check host only
		if data.host_only and not host then
			check_ok = false
		end
		--Add to list if everything is ok
		if check_ok then
			table.insert(achis, achi)
		end
	end
	--Sort list
	table.sort(achis)
	--Set up states
	self._state.display = {}
	--Note: index starts from 0, irregular
	self._state.display[0] = "off"
	self._state.display_state = 0
	if #achis == 0 then
		--No items to hunt
	elseif #achis == 1 then
		--One item to hunt
		self._state.display[1] = achis[1]
		self._enabled = true
	else
		--More than one item to hunt
		self._state.display[1] = "all"
		local counter = 1
		for _, achi in ipairs(achis) do
			counter = counter + 1
			self._state.display[counter] = achi
		end
		self._enabled = true
	end
end

--Go to next state
function ItemHunter:next_state()
	--Lua indexing starts at 1, index 0 was not included in length, add 1 to length of self._state.display
	self._state.display_state = (self._state.display_state + 1)%(#self._state.display + 1)
end

--Get display state of waypoints i.e. which item is currently being hunted
--Used to determine which waypoints should be shown
function ItemHunter:get_display_state()
	if self._state.display then
		return self._state.display[self._state.display_state]
	else
		return "off"
	end
end

--Add single waypoint, used by ItemHunter:update_wp()
--Does not allow existing waypoints to be overwritten to prevent unnecessary updating, clean before calling
--1. clean_wp() removes stale waypoints
--2. update_wp() adds new waypoints but skips ones already exist because of check in add_waypoint()
--3. clean_wp() removes any extra/incorrect/disabled waypoints added by update_wp()
function ItemHunter:add_waypoint(name, position, color)
	--Don't allow waypoints to be overwritten
	if managers.hud._hud.waypoints[name] ~= nil then
		return
	end
	managers.hud:add_waypoint(
		name, {
			icon = "wp_standard",
			distance = true,
			position = position,
			no_sync = true,
			present_timer = 0,
			state = "present",
			radius = 160,
			color = color,
			blend_mode = "add"
		}
	)
	wp = managers.hud._hud.waypoints[name]
	wp.bitmap:set_color(color)
	wp.arrow:set_color(color)
end

--Adds waypoints for the given heist by reading item_data
--Need to call clean_wp() after to handle removing extra/incorrect/disabled waypoints
--Will crash if waypoints are added before game starts, check before calling
function ItemHunter:update_wp()
	if not self._enabled or self:get_display_state() == "off" then
		return
	end
	local level_id = Global.game_settings.level_id
	local dif = Global.game_settings.difficulty
	local host = Global.game_settings.single_player or Network:is_server()
	for achi, data in pairs(self.item_data) do
		--Check achievement
		if self:get_display_state() == achi or self:get_display_state() == "all" then
			--Check host only
			if not data.host_only or host then
				--Check if valid level
				if data.level == level_id or (data.level == "multiple" and table.contains(data.levels, level_id)) or (data.level == "any" and (not data.exclude or not table.contains(data.exclude, level_id))) then
					--Check if valid difficulty
					if not data.difficulty or table.contains(data.difficulty, dif) then
						for obj_type, obj_data in pairs(data.objectives) do
							--Handle units
							if obj_type == "units" then
								for _, objective in pairs(obj_data) do
									local offset = Vector3(0, 0, 0)
									if objective.offset then
										offset = objective.offset
									end
									for _, unit in pairs(World:find_units_quick("all")) do
										local id = unit:name()
										if tostring(id) == tostring(objective.id) then
											local wp_name = self._prefix..tostring(unit:name())..tostring(unit:position())
											local position = unit:position() + offset
											local color = Color(0, 1, 0)
											if unit:movement() and unit:movement():m_head_pos() then
												position = unit:movement():m_head_pos()
											end
											self:add_waypoint(wp_name, position, color)
										end
									end
								end
							end
							--Handle interactions
							if obj_type == "interactions" then
								for _, objective in pairs(obj_data) do
									local offset = Vector3(0, 0, 0)
									if objective.offset then
										offset = objective.offset
									end
									for _, unit in pairs(managers.interaction._interactive_units) do
										local id = unit:name()
										local name = unit:interaction().tweak_data
										if tostring(id) == tostring(objective.id) and tostring(name) == objective.name then
											local wp_name = self._prefix..tostring(unit:name())..tostring(unit:position())
											local position = unit:position() + offset
											local color = Color(0, 1, 0)
											self:add_waypoint(wp_name, position, color)
										end
									end
								end
							end
							--Handle civilians
							if obj_type == "civilians" then
								for _, objective in pairs(obj_data) do
									for _, civ in pairs(managers.enemy:all_civilians()) do
										local id = civ.unit:name()
										if tostring(id) == tostring(objective.id) then
											local wp_name = self._prefix..tostring(civ.unit:unit_data().unit_id)
											local position = civ.unit:movement():m_head_pos()--Don't add offset otherwise it becomes static
											local color = Color(0, 1, 0)
											self:add_waypoint(wp_name, position, color)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

--Clean waypoints: remove extra/incorrect/disabled waypoints
--Logic for which waypoints to keep is handled by ItemHunter:check_keep_wps()
function ItemHunter:clean_wp()
	if not self._enabled or self:get_display_state() == "off" then
		return
	end
	--Get all Item Hunter waypoints
	local prefix = self._prefix
	local remove_wps = {}
	for k, _ in pairs(clone(managers.hud._hud.waypoints)) do
		if string.sub(tostring(k), 1, string.len(prefix)) == prefix then
			table.insert(remove_wps, k)
		end
	end
	--Loop over objectives to see which waypoints to keep
	local level_id = Global.game_settings.level_id
	local dif = Global.game_settings.difficulty
	local host = Global.game_settings.single_player or Network:is_server()
	for achi, data in pairs(self.item_data) do
		--Check achievement
		if self:get_display_state() == achi or self:get_display_state() == "all" then
			--Check host only
			if not data.host_only or host then
				--Check if valid level
				if data.level == level_id or (data.level == "multiple" and table.contains(data.levels, level_id)) or (data.level == "any" and (not data.exclude or not table.contains(data.exclude, level_id))) then
					--Check if valid difficulty
					if not data.difficulty or table.contains(data.difficulty, dif) then
						for obj_type, obj_data in pairs(data.objectives) do
							for _, objective in pairs(obj_data) do
								local keep_wps = self:check_keep_wps(level_id, obj_type, objective)
								for _, wp in pairs(keep_wps) do
									if table.contains(remove_wps, wp) then
										table.delete(remove_wps, wp)
									end
								end
							end
						end
					end
				end
			end
		end
	end
	--Remove remaining waypoints
	for _, wp in pairs(remove_wps) do
		managers.hud:remove_waypoint(wp)
	end
end

--Check an objective to decide whether or not to keep its associated waypoints
function ItemHunter:check_keep_wps(level_id, obj_type, objective)
	local keep_wps = {}
	if obj_type == "units" then
		for _, unit in pairs(World:find_units_quick("all")) do
			local id = unit:name()
			if tostring(id) == tostring(objective.id) then
				local wp_name = self._prefix..tostring(unit:name())..tostring(unit:position())
				--Check if waypoint should be removed
				local keep = true
				if level_id == "help" then
					if tostring(id) == "Idstring(@ID513a873fc49c5944@)" then
						if unit:unit_data().unit_id ~= self._state.trophy_spooky.pumpkin_id then
							--Remove wrong pumpkins on Prison Nightmare
							keep = false
						end
					end
				elseif level_id == "wwh" then
					if tostring(id) == tostring(Idstring("units/payday2/characters/ene_cop_2/ene_cop_2")) then
						if unit:character_damage():dead() then
							--Remove Leo if dead
							keep = false
						end
					end
				elseif level_id == "sah" then
					--Shacklethorne metal detectors
					if tostring(id) == tostring(Idstring("units/world/props/gym/gym_cover_metaldetector/stn_cover_metaldetector")) then
						--Disable when loud
						if not managers.groupai:state():whisper_mode() then
							keep = false
						end
						--Disable if civ not tied yet (need state)
						if not self._state.sah_11.civ_tied then
							keep = false
						end
						--Disable if civ dead (need state)
						if self._state.sah_11.civ_dead then
							keep = false
						end
						--Disable when wrench dropped (need state)
						if self._state.sah_11.wrench_dropped then
							keep = false
						end
					end
				end
				if keep then
					table.insert(keep_wps, wp_name)
				end
			end
		end
	end
	if obj_type == "interactions" then
		for _, unit in pairs(clone(managers.interaction._interactive_units)) do
			local id = unit:name()
			local name = unit:interaction().tweak_data
			if tostring(id) == tostring(objective.id) and tostring(name) == objective.name then
				local wp_name = self._prefix..tostring(unit:name())..tostring(unit:position())
				--Check if waypoint should be removed
				local keep = true
				if level_id == "sah" then
					--Save state (wrench dropped)
					if tostring(id) == "Idstring(@IDb88b91bf3b4898aa@)" and tostring(name) == "hold_take_wrench" then
						self._state.sah_11.wrench_dropped = true
					end
				end
				if keep then
					table.insert(keep_wps, wp_name)
				end
			end
		end
	end
	if obj_type == "civilians" then
		for _, civ in pairs(managers.enemy:all_civilians()) do
			local id = civ.unit:name()
			if tostring(id) == tostring(objective.id) then
				local wp_name = self._prefix..tostring(civ.unit:unit_data().unit_id)
				--Check if waypoint should be removed
				local keep = true
				if level_id == "jolly" then
					if tostring(id) == tostring(Idstring("units/pd2_dlc_holly/characters/civ_male_hobo_1/civ_male_hobo_1")) then
						--Disable when civilian dead/tied
						if civ.unit:character_damage():dead() or (civ.unit.anim_data and civ.unit:anim_data().tied) then
							keep = false
						end
					end
				elseif level_id == "sah" then
					if tostring(id) == "Idstring(@ID6e6969100b52ea22@)" then
						--Save state (civ tied)
						if civ.unit.anim_data and civ.unit:anim_data().tied then
							self._state.sah_11.civ_tied = true
						end
						--Disable when loud
						if not managers.groupai:state():whisper_mode() then
							keep = false
						end
						--Disable when wrench dropped (need state)
						if self._state.sah_11.wrench_dropped then
							keep = false
						end
						--Disable when dead
						--Save state (civ dead)
						--Aftershock method doesn't work, civ is removed from list after dying
						--Handle later instead
					end
				end
				if keep then
					table.insert(keep_wps, wp_name)
				end
			end
		end
		--Fix for Shacklethrone civ on kill
		--civ is no longer in list after being killed
		if level_id == "sah" and not self._state.sah_11.civ_dead then
			if tostring(objective.id) == "Idstring(@ID6e6969100b52ea22@)" then
				local dead = true
				for _, civ in pairs(managers.enemy:all_civilians()) do
					local id = civ.unit:name()
					if tostring(id) == tostring(objective.id) then
						dead = false
						break
					end
				end
				self._state.sah_11.civ_dead = dead
			end
		end
	end
	--Return
	return keep_wps
end

--Remove all waypoints
function ItemHunter:remove_all_wp()
	for k, _ in pairs(clone(managers.hud._hud.waypoints)) do
		if string.sub(tostring(k), 1, string.len(self._prefix)) == self._prefix then
			managers.hud:remove_waypoint(k)
		end
	end
end
