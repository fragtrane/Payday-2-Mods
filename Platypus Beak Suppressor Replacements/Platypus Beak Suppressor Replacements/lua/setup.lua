--Don't do setup twice
if _G.BeakSuppressorReplacements then
	return
end

--Set up variables
_G.BeakSuppressorReplacements = _G.BeakSuppressorReplacements or {}
BeakSuppressorReplacements._mod_path = ModPath
BeakSuppressorReplacements._save_path = SavePath
BeakSuppressorReplacements._save_name = "pbsr_settings.txt"
BeakSuppressorReplacements._settings = {
	pbsr_replacement = 1,
	pbsr_replace_normal = false,--Replace the barrel model even when not using Don Pastrami Barrel
	pbsr_override_aola = false--Override AOLA replacement
}

--JSON encode helper
function BeakSuppressorReplacements:json_encode(tab, path)
	local file = io.open(path, "w+")
	if file then
		file:write(json.encode(tab))
		file:close()
	end
end

--JSON decode helper
function BeakSuppressorReplacements:json_decode(tab, path)
	local file = io.open(path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			tab[k] = v
		end
		file:close()
	end
end

--Save settings function
function BeakSuppressorReplacements:save_settings()
	local path = self._save_path..self._save_name
	self:json_encode(self._settings, path)
end

--Load settings function
function BeakSuppressorReplacements:load_settings()
	local path = self._save_path..self._save_name
	self:json_decode(self._settings, path)
end

--Load settings
local save_exists = io.open(BeakSuppressorReplacements._save_path..BeakSuppressorReplacements._save_name, "r")
if save_exists ~= nil then
	save_exists:close()
	BeakSuppressorReplacements:load_settings()
else
	BeakSuppressorReplacements:save_settings()
end

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "pbsr_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(BeakSuppressorReplacements._mod_path.."localizations/english.txt")
end)

Hooks:Add("MenuManagerInitialize", "pbsr_hook_MenuManagerInitialize", function(menu_manager)
	MenuCallbackHandler.pbsr_callback_toggle = function(self, item)
		BeakSuppressorReplacements._settings[item:name()] = item:value() == "on"
	end
		
	MenuCallbackHandler.pbsr_callback_multi = function(self, item)
		BeakSuppressorReplacements._settings[item:name()] = item:value()
	end
	
	MenuCallbackHandler.pbsr_callback_save = function(self, item)
		BeakSuppressorReplacements:save_settings()
	end
	
	MenuHelper:LoadFromJsonFile(BeakSuppressorReplacements._mod_path.."menu/options.txt", BeakSuppressorReplacements, BeakSuppressorReplacements._settings)
end)

--Map indexes to names for multiple choice settings
function BeakSuppressorReplacements:get_multi_name(multi_id)
	if multi_id == "pbsr_replacement" then
		if self._settings[multi_id] == 1 then
			--Rattlesnake Sniper Suppressor
			return "units/pd2_dlc_gage_snp/weapons/wpn_fps_snp_msr_pts/wpn_fps_snp_msr_ns_suppressor"
		elseif self._settings[multi_id] == 2 then
			--Medium Suppressor
			return "units/payday2/weapons/wpn_fps_upg_ns_ass_smg_medium/wpn_fps_upg_ns_ass_smg_medium"
		elseif self._settings[multi_id] == 3 then
			--The Bigger the Better Suppressor
			return "units/payday2/weapons/wpn_fps_upg_ns_ass_smg_large/wpn_fps_upg_ns_ass_smg_large"
		elseif self._settings[multi_id] == 4 then
			--Clarion Suppressed Barrel
			return "units/pd2_dlc_gage_assault/weapons/wpn_fps_ass_famas_pts/wpn_fps_ass_famas_b_suppressed"
		elseif self._settings[multi_id] == 5 then
			--AK PBS Suppressor
			return "units/pd2_dlc_akm4_modpack/weapons/wpn_fps_upg_ns_ass_pbs1/wpn_fps_upg_ns_ass_pbs1"
		elseif self._settings[multi_id] == 6 then
			--The Silent Killer Suppressor
			return "units/payday2/weapons/wpn_fps_upg_ns_shot_thick/wpn_fps_upg_ns_shot_thick"
		elseif self._settings[multi_id] == 7 then
			--Jungle Ninja Suppressor
			return "units/pd2_dlc_butcher_mods/weapons/wpn_fps_upg_ns_pis_jungle/wpn_fps_upg_ns_pis_jungle"
		end
	end
end

--Get part_id of current replacement
function BeakSuppressorReplacements:get_part_id()
	if self._settings["pbsr_replacement"] == 1 then
		--Rattlesnake Sniper Suppressor
		return "wpn_fps_snp_msr_ns_suppressor"
	elseif self._settings["pbsr_replacement"] == 2 then
		--Medium Suppressor
		return "wpn_fps_upg_ns_ass_smg_medium"
	elseif self._settings["pbsr_replacement"] == 3 then
		--The Bigger the Better Suppressor
		return "wpn_fps_upg_ns_ass_smg_large"
	elseif self._settings["pbsr_replacement"] == 4 then
		--Clarion Suppressed Barrel
		return "wpn_fps_ass_famas_b_suppressed"
	elseif self._settings["pbsr_replacement"] == 5 then
		--AK PBS Suppressor
		return "wpn_fps_upg_ns_ass_pbs1"
	elseif self._settings["pbsr_replacement"] == 6 then
		--The Silent Killer Suppressor
		return "wpn_fps_upg_ns_shot_thick"
	elseif self._settings["pbsr_replacement"] == 7 then
		--Jungle Ninja Suppressor
		return "wpn_fps_upg_ns_pis_jungle"
	end
end
