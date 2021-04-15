if _G.AOLA then
	return
end

_G.AOLA = {}
AOLA._mod_path = ModPath
AOLA._save_path = SavePath--Currently unused
AOLA._save_name = "aola_settings.txt"--Currently unused
AOLA._settings = {
	aola_debug = false
}
AOLA._overrides_folder = "./assets/mod_overrides"
AOLA._legacy_overrides_path = AOLA._overrides_folder .. "/Add-On Legendary Attachments Assets"
AOLA._overrides_path = AOLA._overrides_folder .. "/AOLA Assets"
AOLA._overrides_path_check = AOLA._overrides_path .."/assets"--Used to check if assets have installed

--Settings? Button to clean mods?

--Menu hooks
Hooks:Add("LocalizationManagerPostInit", "AOLA_hook_LocalizationManagerPostInit", function(loc)
	loc:load_localization_file(AOLA._mod_path.."localizations/english.txt")
end)

--Create mod_overrides folder if it does not exist
if file and not file.DirectoryExists(AOLA._overrides_folder) then
	file.CreateDirectory(AOLA._overrides_folder)
end

--Create AOLA Assets folder if it does not exist so that updates can be checked
--Check if legacy assets folder exists first, because in that case we need to migrate and we shouldn't create the new folder otherwise the migration will fail
if file and not file.DirectoryExists(AOLA._legacy_overrides_path) then
	--Create new AOLA Assets folder
	if file and not file.DirectoryExists(AOLA._overrides_path) then
		file.CreateDirectory(AOLA._overrides_path)
	end
end

--SuperBLT check
function AOLA:check_superblt()
	return _G.XAudio and true or false
end

--BeardLib check
function AOLA:check_beardlib()
	return _G.BeardLib and true or false
end

--Migrate Legacy Assets
function AOLA:migrate_legacy_assets()
	--https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua
	if file.DirectoryExists(self._legacy_overrides_path) then
		file.MoveDirectory(self._legacy_overrides_path, AOLA._overrides_path)
		
		local menu_title = managers.localization:text("aola_dialog_title")
		local menu_message = managers.localization:text("aola_dialog_config_change_restart")
		local cb = callback(MenuCallbackHandler, MenuCallbackHandler, "_dialog_save_progress_backup_no")
		local menu_options = {
			[1] = {
				text = managers.localization:text("menu_quit"),
				callback = cb
			}
		}
		
		local menu = QuickMenu:new(menu_title, menu_message, menu_options)
		menu:Show()
		
		return true
		
	else
		return false
	end
end

--Clean duplicated assets
--Can happen if someone updated AOLA Assets before updating AOLA BLT
function AOLA:clean_duplicated_assets()
	--https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua
	if file.DirectoryExists(self._overrides_path) and file.DirectoryExists(self._legacy_overrides_path) then
		--Need to remove files before we can remove directory
		--Stole this from SuperBLT base
		--io.remove_directory_and_files(self._legacy_overrides_path .. "/", true)
		self:actually_delete_the_fucking_directory_please(self._legacy_overrides_path)
		
		local menu_title = managers.localization:text("aola_dialog_title")
		local menu_message = managers.localization:text("aola_dialog_config_change_restart")
		local cb = callback(MenuCallbackHandler, MenuCallbackHandler, "_dialog_save_progress_backup_no")
		local menu_options = {
			[1] = {
				text = managers.localization:text("menu_quit"),
				callback = cb
			}
		}
		
		local menu = QuickMenu:new(menu_title, menu_message, menu_options)
		menu:Show()
		
		return true
		
	else
		return false
	end
end

--Recursively delete path because RemoveDirectory only works on empty folders
function AOLA:actually_delete_the_fucking_directory_please(path)
	--1. Recursion to clean any subfolders
	local dirs = file.GetDirectories(path) or {}
	for _, dir in pairs(dirs) do
		self:actually_delete_the_fucking_directory_please(path .. "/" .. dir)
	end
	--2. Remove files from path
	local files = file.GetFiles(path) or {}
	for _, v in pairs(files) do
		local file_path = path .. "/" .. v
		os.remove( file_path )
	end
	--3. Remove path
	file.RemoveDirectory(path)
end

--Assets check
function AOLA:check_assets()
	--https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua
	return file and file.DirectoryExists(self._overrides_path_check) and true or false
end

--Check dependencies
function AOLA:check_dependencies()
	local all_installed = self:check_superblt() and self:check_beardlib() and self:check_assets()
	self.missing_dependency = not all_installed
end
AOLA:check_dependencies()

--Shortcut for single-option menu
function AOLA:ok_menu(title, desc, callback, localize)
	local menu_title = not localize and title or managers.localization:text(title)
	local menu_message = not localize and desc or managers.localization:text(desc)
	local menu_options = {}
	if not callback then
		menu_options = {
			[1] = {
				text = managers.localization:text("dialog_ok"),
				is_cancel_button = true
			}
		}
	else
		menu_options = {
			[1] = {
				text = managers.localization:text("dialog_ok"),
				callback = callback
			}
		}
	end
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--Shortcut for download menu
function AOLA:dl_menu(title, desc, yes_title, callback)
	local menu_title = title
	local menu_message = desc
	local menu_options = {
		[1] = {
			text = managers.localization:text(yes_title),
			callback = callback
		},
		[2] = {
			text = managers.localization:text("dialog_cancel"),
			is_cancel_button = true
		}
	}
	local menu = QuickMenu:new(menu_title, menu_message, menu_options)
	menu:Show()
end

--List of first generation legendary skins and parts
AOLA._gen_1_mods = {
	--Vlad's Rodina
	ak74_rodina = {
		"wpn_fps_ass_74_b_legend",
		"wpn_upg_ak_fg_legend",
		"wpn_upg_ak_g_legend",
		"wpn_upg_ak_s_legend",
		"wpn_upg_ak_fl_legend"
	},
	--Midas Touch
	deagle_bling = {
		"wpn_fps_pis_deagle_b_legend"
	},
	--Dragon Lord
	flamethrower_mk2_fire = {
		"wpn_fps_fla_mk2_body_fierybeast"
	},
	--Green Grin
	rpg7_boom = {
		"wpn_fps_rpg7_m_grinclown"
	},
	--The Gimp
	m134_bulletstorm = {
		"wpn_fps_lmg_m134_body_upper_spikey",
		"wpn_fps_lmg_m134_barrel_legendary"
	},
	--Alamo Dallas
	p90_dallas_sallad = {
		"wpn_fps_smg_p90_b_legend"
	},
	--Big Kahuna
	r870_waves = {
		"wpn_fps_shot_r870_b_legendary",
		"wpn_fps_shot_r870_s_legendary",
		"wpn_fps_shot_r870_fg_legendary"
	},
	--Santa's Slayers
	x_1911_ginger = {
		"wpn_fps_pis_1911_g_legendary",
		"wpn_fps_pis_1911_fl_legendary"
	},
	--Don Pastrami
	model70_baaah = {
		"wpn_fps_snp_model70_b_legend",
		"wpn_fps_snp_model70_s_legend"
		--"wpn_fps_snp_model70_ns_suppressor"--Don't need to do this anymore since we aren't making it a standalone mod, just use the model in an override
	},
	--Hungry Wolf
	par_wolf = {
		"wpn_fps_lmg_svinet_b_standard",
		"wpn_fps_lmg_svinet_s_legend"
	},
	--Astatoz
	m16_cola = {
		"wpn_fps_ass_m16_b_legend",
		"wpn_fps_ass_m16_fg_legend",
		"wpn_fps_ass_m16_s_legend"
	},
	--Anarcho
	judge_burn = {
		"wpn_fps_pis_judge_b_legend",
		"wpn_fps_pis_judge_g_legend"
	},
	--Apex
	boot_buck = {
		"wpn_fps_sho_boot_b_legendary",
		"wpn_fps_sho_boot_fg_legendary",
		"wpn_fps_sho_boot_o_legendary",
		"wpn_fps_sho_boot_s_legendary"
	},
	--Admiral
	ksg_same = {
		"wpn_fps_sho_ksg_b_legendary"
	},
	--Mars Ultor
	tecci_grunt = {
		"wpn_fps_ass_tecci_b_legend",
		"wpn_fps_ass_tecci_fg_legend",
		"wpn_fps_ass_tecci_s_legend"
	},
	--Demon
	serbu_lones = {
		"wpn_fps_shot_shorty_b_legendary",
		"wpn_fps_shot_shorty_fg_legendary",
		"wpn_fps_shot_shorty_s_legendary"
	},
	--Plush Phoenix
	new_m14_lones = {
		"wpn_fps_ass_m14_b_legendary",
		"wpn_fps_ass_m14_body_legendary",
		"wpn_fps_ass_m14_body_upper_legendary",
		"wpn_fps_ass_m14_body_lower_legendary"
	}
}

AOLA._based_on = {
	wpn_fps_ass_74_b_legend_addon = "wpn_fps_ass_74_b_standard",
	wpn_upg_ak_fg_legend_addon = "wpn_upg_ak_fg_combo2",
	wpn_upg_ak_g_legend_addon = "wpn_upg_ak_g_standard",
	wpn_upg_ak_s_legend_addon = "wpn_upg_ak_s_folding",
	wpn_upg_ak_fl_legend_addon = "wpn_fps_upg_fl_ass_smg_sho_peqbox",
	wpn_fps_pis_deagle_b_legend_addon = "wpn_fps_pis_deagle_b_standard",
	wpn_fps_fla_mk2_body_fierybeast_addon = "wpn_fps_fla_mk2_body",
	wpn_fps_rpg7_m_grinclown_addon = "wpn_fps_rpg7_m_rocket",
	wpn_fps_lmg_m134_body_upper_spikey_addon = "wpn_fps_lmg_m134_body_upper",
	wpn_fps_lmg_m134_barrel_legendary_addon = "wpn_fps_lmg_m134_barrel_extreme",
	wpn_fps_smg_p90_b_legend_addon = "wpn_fps_smg_p90_b_short",
	wpn_fps_shot_r870_b_legendary_addon = "wpn_fps_shot_r870_b_long",
	wpn_fps_shot_r870_s_legendary_addon = "wpn_fps_shot_r870_s_nostock",
	wpn_fps_shot_r870_fg_legendary_addon = "wpn_fps_shot_r870_fg_wood",
	wpn_fps_pis_1911_g_legendary_addon = "wpn_fps_pis_1911_g_bling",
	wpn_fps_pis_1911_fl_legendary_addon = "wpn_fps_upg_fl_pis_laser",
	wpn_fps_snp_model70_b_legend_addon = "wpn_fps_snp_model70_b_standard",
	wpn_fps_snp_model70_s_legend_addon = "wpn_fps_snp_model70_s_standard",
	wpn_fps_lmg_svinet_b_standard_addon = "wpn_fps_lmg_par_b_standard",
	wpn_fps_lmg_svinet_s_legend_addon = "wpn_fps_lmg_par_s_standard",
	wpn_fps_ass_m16_b_legend_addon = "wpn_fps_m4_uupg_b_long",
	wpn_fps_ass_m16_fg_legend_addon = "wpn_fps_m16_fg_railed",
	wpn_fps_ass_m16_s_legend_addon = "wpn_fps_m16_s_solid_vanilla",
	wpn_fps_pis_judge_b_legend_addon = "wpn_fps_pis_judge_b_standard",
	wpn_fps_pis_judge_g_legend_addon = "wpn_fps_pis_judge_g_standard",
	wpn_fps_sho_boot_b_legendary_addon = "wpn_fps_sho_boot_b_standard",
	wpn_fps_sho_boot_fg_legendary_addon = "wpn_fps_sho_boot_fg_standard",
	wpn_fps_sho_boot_o_legendary_addon = "wpn_fps_sho_boot_em_extra",
	wpn_fps_sho_boot_s_legendary_addon = "wpn_fps_sho_boot_s_short",
	wpn_fps_sho_ksg_b_legendary_addon = "wpn_fps_sho_ksg_b_long",
	wpn_fps_ass_tecci_b_legend_addon = "wpn_fps_ass_tecci_b_standard",
	wpn_fps_ass_tecci_fg_legend_addon = "wpn_fps_ass_tecci_fg_standard",
	wpn_fps_ass_tecci_s_legend_addon = "wpn_fps_ass_tecci_s_standard",
	wpn_fps_shot_shorty_b_legendary_addon = "wpn_fps_shot_r870_b_short",
	wpn_fps_shot_shorty_fg_legendary_addon = "wpn_fps_shot_r870_fg_small",
	wpn_fps_shot_shorty_s_legendary_addon = "wpn_fps_shot_r870_s_nostock_vanilla",
	wpn_fps_ass_m14_b_legendary_addon = "wpn_fps_ass_m14_b_standard",
	wpn_fps_ass_m14_body_legendary_addon = "wpn_fps_ass_m14_body_ebr",
	wpn_fps_ass_m14_body_upper_legendary_addon = "wpn_fps_ass_m14_body_upper",
	wpn_fps_ass_m14_body_lower_legendary_addon = "wpn_fps_ass_m14_body_lower"
	--wpn_fps_snp_model70_ns_suppressor_addon = "wpn_fps_snp_model70_ns_suppressor"--Don't need to do this anymore since we aren't making it a standalone mod, just use the model in an override
}
