dofile(ModPath .. "lua/setup.lua")

--Make filter button visible in Crime.net Offline (filter items still need to be fixed)
local orig_GuiTweakData_init = GuiTweakData.init
function GuiTweakData:init()
	orig_GuiTweakData_init(self)
	if IOF._settings.iof_filters then
		self.crime_net.sidebar[2].visible_callback = nil
	end
end
