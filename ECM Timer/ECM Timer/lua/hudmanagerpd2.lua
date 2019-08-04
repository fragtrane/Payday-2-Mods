--LazyOzzy's ECM duration timer
--Modified icon and counter

HUDECMCounter = HUDECMCounter or class()

function HUDECMCounter:init(hud)
	self._hud_panel = hud.panel
	
	self._panel = self._hud_panel:panel({
		name = "ecm_counter_panel",
		visible = false,
		w = 200,
		h = 200,
		x = self._hud_panel:w() - 200,
		y = 50,
	})
	
	--Put icon on the right instead
	local ecm_icon = self._panel:bitmap({
		name = "ecm_icon",
		texture = "guis/textures/pd2/skilltree/icons_atlas",
		texture_rect = { 6 * 64, 3 * 64, 64, 64 },--ECM Overdrive icon
		valign = "center",
		align = "center",
		layer = 1,
		h = 38,--Adjust scaling
		w = 38,
	})
	ecm_icon:set_right(self._panel:w()+5)
	
	local box = HUDBGBox_create(self._panel, { w = 38, h = 38, },  {})
	box:set_right(ecm_icon:left()-5)
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
		font_size = tweak_data.hud_corner.numhostages_size * 0.9,
	})
end

function HUDECMCounter:update(t)
	self._panel:set_visible(t > 0)
	
	if t > 0 then
		self._text:set_text(string.format("%.1f", t))
		self._text:set_color(Color(1, 1, 1))
	end
end

local _setup_player_info_hud_pd2_original = HUDManager._setup_player_info_hud_pd2
function HUDManager:_setup_player_info_hud_pd2(...)
	_setup_player_info_hud_pd2_original(self, ...)
	self._hud_ecm_counter = HUDECMCounter:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
end

function HUDManager:update_ecm(t)
	self._hud_ecm_counter:update(t)
end
