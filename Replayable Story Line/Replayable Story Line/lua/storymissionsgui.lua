require("lib/managers/menu/ExtendedUiElemets")

local padding = 10
local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local done_icon = "guis/textures/menu_singletick"
local reward_icon = "guis/textures/pd2/icon_reward"
local active_mission_icon = "guis/textures/scrollarrow"

--One line changed to allow story line missions to be replayed. Also fixed the Start Level button for The Basics in Crime.net Offline.
function StoryMissionsGui:_update_info(mission)
	self._info_scroll:clear()
	self:_change_legend("select", false)
	self:_change_legend("start_mission", false)

	self._select_btn = nil
	self._level_btns = {}
	self._selected_level_btn = nil

	if self._voice then
		managers.briefing:stop_event()
		self._voice.panel:remove_self()

		self._voice = nil
	end

	mission = mission or managers.story:current_mission()

	if not mission then
		return
	end

	local canvas = self._info_scroll:canvas()
	local placer = canvas:placer()
	local text_col = tweak_data.screen_colors.text

	if mission.completed and mission.rewarded and mission.last_mission then
		placer:add_row(canvas:fine_text({
			text_id = "menu_sm_all_done",
			font = medium_font,
			font_size = medium_font_size
		}))

		return
	end

	placer:add_row(canvas:fine_text({
		text = managers.localization:to_upper_text(mission.name_id),
		font = medium_font,
		font_size = medium_font_size,
		color = text_col
	}))
	placer:add_row(canvas:fine_text({
		wrap = true,
		word_wrap = true,
		text = managers.localization:text(mission.desc_id),
		font = small_font,
		font_size = small_font_size,
		color = text_col
	}))

	if mission.voice_line then
		self._voice = {}
		local h = small_font_size * 2 + 20
		local pad = 8
		self._voice.panel = ExtendedPanel:new(self, {
			w = 256,
			input = true,
			h = h
		})

		BoxGuiObject:new(self._voice.panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		self._voice.text = self._voice.panel:text({
			x = pad,
			y = pad,
			font = small_font,
			font_size = small_font_size,
			color = text_col,
			text = managers.localization:to_upper_text("menu_cn_message_playing")
		})
		self._voice.button = TextButton:new(self._voice.panel, {
			binding = "menu_toggle_voice_message",
			x = pad,
			font = small_font,
			font_size = small_font_size,
			text = managers.localization:to_upper_text("menu_stop_sound", {
				BTN_X = managers.localization:btn_macro("menu_toggle_voice_message")
			})
		}, callback(self, self, "toggle_voice_message", mission.voice_line))

		self._voice.button:set_bottom(self._voice.panel:h() - pad)
		self._voice.panel:set_world_right(self._info_scroll:world_right())
		self:toggle_voice_message(mission.voice_line)
	end

	placer:add_row(canvas:fine_text({
		text = managers.localization:to_upper_text("menu_challenge_objective_title"),
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.challenge_title
	}))
	placer:add_row(canvas:fine_text({
		wrap = true,
		word_wrap = true,
		text = managers.localization:text(mission.objective_id),
		font = small_font,
		font_size = small_font_size,
		color = text_col
	}), nil, 0)

	local locked = false

	if not mission.hide_progress then
		placer:add_row(canvas:fine_text({
			text = managers.localization:to_upper_text("menu_unlock_progress"),
			font = small_font,
			font_size = small_font_size,
			color = tweak_data.screen_colors.challenge_title
		}))

		local num_objective_groups = #mission.objectives
		local obj_padd_x = num_objective_groups > 1 and 15 or nil

		for i, objective_row in ipairs(mission.objectives) do
			for _, objective in ipairs(objective_row) do
				local text = placer:add_row(canvas:fine_text({
					wrap = true,
					word_wrap = true,
					text = managers.localization:text(objective.name_id),
					font = small_font,
					font_size = small_font_size,
					color = text_col
				}), obj_padd_x, 0)

--				if not mission.completed and not objective.completed and objective.levels and (not objective.basic or not Network:is_server()) and not Network:is_client() then
				if objective.levels and (not objective.basic or not Network:is_server() or Global.game_settings.single_player) and not Network:is_client() then
					if objective.dlc and not managers.dlc:is_dlc_unlocked(objective.dlc) and not Global.game_settings.single_player then
						placer:add_right(canvas:fine_text({
							text = managers.localization:to_upper_text("menu_ultimate_edition_short"),
							font = small_font,
							font_size = small_font_size,
							color = tweak_data.screen_colors.dlc_color
						}), 5)
						placer:add_right(canvas:fine_text({
							text_id = "menu_sm_dlc_locked",
							font = small_font,
							font_size = small_font_size,
							color = tweak_data.screen_colors.important_1
						}), 5)

						locked = true
					else
						local btn = TextButton:new(canvas, {
							text_id = "menu_sm_start_level",
							font = small_font,
							font_size = small_font_size
						}, function ()
							managers.story:start_mission(mission, objective.progress_id)
						end)

						placer:add_right(btn, 10)
						table.insert(self._level_btns, btn)
						self:_change_legend("start_mission", true)

						if not self._selected_level_btn then
							self._selected_level_btn = btn

							if not managers.menu:is_pc_controller() then
								btn:_hover_changed(true)
							end
						end
					end
				end

				if objective.max_progress > 1 then
					local progress = placer:add_row(TextProgressBar:new(canvas, {
						h = small_font_size + 2,
						max = objective.max_progress,
						back_color = Color(0, 0, 0, 0),
						progress_color = tweak_data.screen_colors.challenge_completed_color:with_alpha(0.4)
					}, {
						font = small_font,
						font_size = small_font_size,
						color = text_col
					}, objective.progress), nil, 0)
					slot20 = BoxGuiObject:new(progress, {
						sides = {
							1,
							1,
							1,
							1
						}
					})
				else
					local texture = "guis/textures/menu_tickbox"
					local texture_rect = {
						objective.completed and 24 or 0,
						0,
						24,
						24
					}
					local checkbox = canvas:bitmap({
						texture = texture,
						texture_rect = texture_rect
					})

					checkbox:set_right(canvas:w())
					checkbox:set_top(text:top())
				end
			end

			if i < num_objective_groups then
				placer:add_row(canvas:fine_text({
					text_id = "menu_sm_objectives_or",
					font = small_font,
					font_size = small_font_size,
					color = tweak_data.screen_colors.challenge_title
				}), nil, 0)
			end
		end
	end

	if locked then
		placer:add_row(canvas:fine_text({
			wrap = true,
			text_id = "menu_sm_dlc_locked_help_text",
			word_wrap = true,
			font = small_font,
			font_size = small_font_size,
			color = text_col
		}), nil, nil)
	end

	if mission.reward_id then
		local title = placer:add_row(canvas:fine_text({
			text = managers.localization:to_upper_text("menu_reward"),
			font = small_font,
			font_size = small_font_size,
			color = tweak_data.screen_colors.challenge_title
		}))
		local r_panel = GrowPanel:new(canvas, {
			input = true
		})
		local r_placer = r_panel:placer()

		for i, reward in ipairs(mission.rewards) do
			local item = StoryMissionGuiRewardItem:new(r_panel, reward)

			if r_placer:current_right() + item:w() < canvas:w() * 0.5 then
				r_placer:add_right(item)
			else
				r_placer:add_row(item)
			end
		end

		BoxGuiObject:new(r_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		placer:add_row(r_panel, nil, 0)
		r_panel:set_right(canvas:w())

		local reward_text = canvas:fine_text({
			wrap = true,
			word_wrap = true,
			text_id = mission.reward_id,
			font = small_font,
			font_size = small_font_size,
			keep_w = r_panel:left() - title:left()
		})

		reward_text:set_lefttop(title:left(), r_panel:top())
		placer:set_at_from(reward_text)
	end

	if mission.completed and not mission.rewarded then
		local item = placer:add_row(TextButton:new(canvas, {
			text_id = mission.last_mission and "menu_sm_claim_rewards" or "menu_sm_claim_rewards_goto_next",
			font = medium_font,
			font_size = medium_font_size
		}, function ()
			managers.story:claim_rewards(mission)
			managers.menu_component:post_event("menu_skill_investment")

			local dialog_data = {
				title = managers.localization:text("menu_sm_claim_rewards"),
				text = managers.localization:text(mission.reward_id)
			}
			local ok_button = {
				text = managers.localization:text("dialog_ok"),
				callback_func = function ()
					self:_update()
				end
			}
			dialog_data.button_list = {
				ok_button
			}

			managers.system_menu:show(dialog_data)
		end))

		item:set_right(canvas:w())

		self._select_btn = item

		self:_change_legend("select", true)
	end
end
