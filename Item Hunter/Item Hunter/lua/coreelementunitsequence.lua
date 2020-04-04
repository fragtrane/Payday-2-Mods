dofile(ModPath .. "lua/setup.lua")

core:module("CoreElementUnitSequence")
core:import("CoreMissionScriptElement")
core:import("CoreCode")
core:import("CoreUnit")

ElementUnitSequence = ElementUnitSequence or class(CoreMissionScriptElement.MissionScriptElement)

--Use mission script to identify correct pumpkin for Spooky Pumpkin
local orig_ElementUnitSequence_on_executed = ElementUnitSequence.on_executed
function ElementUnitSequence:on_executed(...)
	local ItemHunter = _G.ItemHunter
	if self._values.enabled and Global.game_settings and not Network:is_client() then
		local level_id = Global.game_settings.level_id
		if level_id == "help" then
			if self._id == 102817 then
				ItemHunter._state.trophy_spooky.pumpkin_id = 102805
			elseif self._id == 102821 then
				ItemHunter._state.trophy_spooky.pumpkin_id = 102809
			elseif self._id == 102822 then
				ItemHunter._state.trophy_spooky.pumpkin_id = 102810
			elseif self._id == 102823 then
				ItemHunter._state.trophy_spooky.pumpkin_id = 102811
			elseif self._id == 102825 then
				ItemHunter._state.trophy_spooky.pumpkin_id = 102812
			elseif self._id == 102826 then
				ItemHunter._state.trophy_spooky.pumpkin_id = 102813
			elseif self._id == 102834 then
				ItemHunter._state.trophy_spooky.pumpkin_id = 102814
			elseif self._id == 102827 then
				ItemHunter._state.trophy_spooky.pumpkin_id = 102815
			elseif self._id == 102824 then
				ItemHunter._state.trophy_spooky.pumpkin_id = 102816
			end
		end
	end
	
	orig_ElementUnitSequence_on_executed(self, ...)
end
