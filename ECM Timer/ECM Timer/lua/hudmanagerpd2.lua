--Adapted from LazyOzzy's ECM duration timer
--Timer position is tied to hostage panel.
--Hostage panel shifts down when the assault banner is active, and the ECM timer will shift with it.
--Hostage panel is hidden in casing/civilian mode, but its position is not changed so the ECM timer displays correctly under the casing/civilian mode banner.
--Hostage panel gets hidden when Point of No Return timer comes up, but its position gets reverted so the ECM timer displays correctly under the PONR banner.

HUDECMCounter = HUDECMCounter or class()
function HUDECMCounter:init(hud)
	--Use this to update the time
	self._end_time = 0
	
	self._hud_panel = hud.panel
	--Don't worry about exact position of ECM panel, will align using the hostages panel during update
	self._panel = self._hud_panel:panel({
		name = "ecm_counter_panel",
		visible = false,
		w = 200,
		h = 200,
		x = self._hud_panel:w() - 200,
		y = 50
	})
	
	--Put icon on the right instead
	local ecm_icon = self._panel:bitmap({
		name = "ecm_icon",
		texture = "guis/textures/pd2/skilltree/icons_atlas",
		texture_rect = {6*64, 3*64, 64, 64},--ECM Overdrive icon
		valign = "center",
		align = "center",
		layer = 1,
		h = 38,--Adjust scaling
		w = 38
	})
	ecm_icon:set_right(self._panel:w() + 5)
	
	local box = HUDBGBox_create(self._panel, {w = 38, h = 38},  {})
	box:set_right(ecm_icon:left() - 5)
	box:set_center_y(ecm_icon:h() / 2)
	
	self._text = box:text({
		name = "text",
		text = "0",
		valign = "center",
		align = "center",
		vertical = "center",
		w = box:w(),
		h = box:h(),
		layer = 1,
		color = Color.white,
		font = tweak_data.hud_corner.assault_font,
		font_size = tweak_data.hud_corner.numhostages_size * 0.9
	})
end

function HUDECMCounter:update()
	--Update time/visibility
	local current_time = TimerManager:game():time()
	local t = self._end_time - current_time
	
	if t > 0 then
		self._panel:set_visible(true)
		self._text:set_text(string.format("%.1f", t))
	else
		self._panel:set_visible(false)
		self._text:set_text(string.format("%.1f", 0))
	end
	
	--Set position on update
	local hostages_panel = self._hud_panel:child("hostages_panel")
	if hostages_panel then
		self._panel:set_top(hostages_panel:bottom() + 5)
		self._panel:set_right(hostages_panel:right())
	end
end

--Init
Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "fragECM_post_HUDManager__setup_player_info_hud_pd2", function(self)
	self._hud_ecm_counter = HUDECMCounter:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
end)

--Update ECM timer
Hooks:PostHook(HUDManager, "update", "fragECM_post_HUDManager_update", function(self)
	self._hud_ecm_counter:update()
end)
