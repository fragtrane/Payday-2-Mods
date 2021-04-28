Hooks:PostHook(StoryMissionsGui, "_update_info", "rsl_post_StoryMissionsGui__update_info", function(self, mission)
	--Do checks
	mission = mission or managers.story:current_mission()
	if not mission then
		--log("No Mission")
		return
	end
	if mission.completed and mission.rewarded and mission.last_mission then
		--log("Last Mission")
		return
	end
	if mission.hide_progress then
		--log("Hide Progess")
		return
	end
	
	--Check if there are levels that we need to add buttons for
	local has_levels = false
	for i, objective_row in ipairs(mission.objectives) do
		for _, objective in ipairs(objective_row) do
			--Has levels and level completed
			if objective.levels and objective.completed then
				has_levels = true
				break
			end
			--If mission is completed but level is not, buttons still don't show up anymore so we also need to handle it
			if objective.levels and mission.completed then
				has_levels = true
				break
			end
			--Basics always need to be handled to fix the offline bug
			if objective.basic then
				has_levels = true
				break
			end
		end
		--Break outside loop
		if has_levels then
			break
		end
	end
	if not has_levels then
		--log("Nothing to do")
		return
	end
	
	--log("Doing stuff")
	
	--So the panel we need to loop over is self._info_scroll._panel:children()[1]:children()[1]:children()
	--Maybe do it like this to be safe? idk
	
	--Get first child
	local check_me
	if self._info_scroll._panel.children and #self._info_scroll._panel:children() > 0 then
		check_me = self._info_scroll._panel:children()[1]
	else
		check_me = nil
	end
	
	--Get second child
	if check_me and check_me.children and #check_me:children() > 0 then
		check_me = check_me:children()[1]
	else
		check_me = nil
	end
	
	--Add buttons
	if check_me and check_me.children then
		local canvas = self._info_scroll:canvas()
		local small_font = tweak_data.menu.pd2_small_font
		local small_font_size = tweak_data.menu.pd2_small_font_size
		
		--Loop over missions
		for _, objective_row in ipairs(mission.objectives) do
			for _, objective in ipairs(objective_row) do
				--Check levels
				if objective.levels then
					local mission_name = managers.localization:text(objective.name_id):lower()
					
					--Loop over children of second child
					for _, child in ipairs(check_me:children()) do
						if child.text and tostring(type(child.text)) == "function" then
							--Do tostring, otherwise it crashes. Convert to lower just to be safe.
							local i_could_be_a_mission = tostring(child:text()):lower()
							if i_could_be_a_mission == mission_name then
								--log("Found: " .. mission_name)
								
								--Check what needs to be added
								local add_button = false
								local add_ue = false
								local add_unavailable = false
								
								if not objective.basic then
									--Need to add buttons if mission or objective completed
									if mission.completed or objective.completed then
										--IF DLC locked and not single player, can't play
										--So normally this is also supposed to add a "no DLC" warning message below the missions "menu_sm_dlc_locked_help_text".
										--But after you completed the mission, it's not displayed anymore.
										--Even though RSL adds the Start Mission button back, it doesn't bring back the DLC warning.
										--But really who cares. Trying to bring it back is going to be a huge pain in the ass since theres all this stuff below that needs to be moved.
										if objective.dlc and not managers.dlc:is_dlc_unlocked(objective.dlc) and not Global.game_settings.single_player then
											add_ue = true
											add_unavailable = true
										else
											--Not DLC or single player, we good.
											add_button = true
										end
									end
								else
									--Handle basics fixes
									--In original function, basics don't work in Crime.net Offline because Network:is_server() returns true
									local can_play_basics = not Network:is_server() or Global.game_settings.single_player
									if can_play_basics then
										--Only need to add if mission completed, or objective completed, or single player fix
										if mission.completed or objective.completed or Global.game_settings.single_player then
											add_button = true
										end
									else
										--Can't play, add unavailable tag to basics.
										--Basics isn't DLC so normally it never gets tagged. Since it's not DLC, we can also skip the UE tag.
										add_unavailable = true
									end
								end
								
								--Add button
								if add_button then
									local btn = TextButton:new(canvas, {
										text_id = "menu_sm_start_level",
										font = small_font,
										font_size = small_font_size
									}, function ()
										managers.story:start_mission(mission, objective.progress_id)
									end)
									
									btn:set_left(child:right() + 10)
									btn:set_center_y(child:center_y())
									table.insert(self._level_btns, btn)
									self:_change_legend("start_mission", true)
									
									if not self._selected_level_btn then
										self._selected_level_btn = btn
										if not managers.menu:is_pc_controller() then
											btn:_hover_changed(true)
										end
									end
								else
									--Add UE / unavailable text
									local ue_text
									if add_ue then
										ue_text = canvas:fine_text({
											text = managers.localization:to_upper_text("menu_ultimate_edition_short"),
											font = small_font,
											font_size = small_font_size,
											color = tweak_data.screen_colors.dlc_color
										})
										ue_text:set_left(child:right() + 5)
										ue_text:set_center_y(child:center_y())
									end
									
									if add_unavailable then
										local dlc_text = canvas:fine_text({
											text_id = "menu_sm_dlc_locked",
											font = small_font,
											font_size = small_font_size,
											color = tweak_data.screen_colors.important_1
										})
										if ue_text then
											dlc_text:set_left(ue_text:right() + 5)
										else
											dlc_text:set_left(child:right() + 5)
										end
										dlc_text:set_center_y(child:center_y())
									end
									
								end
								
								--Stop searching children if we found the mission already
								break
							end
						end
					end
				end
			end
		end
	end
	--log("End Reached")
end)
