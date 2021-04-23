--Don't let these weapons use any weapon skins or weapon colors
SDSS._blacklist = {
--	"akm_gold"--Golden AK.762
}

--List of first generation legendary skins and parts
SDSS._gen_1_mods = {
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

--First generation legendary skin icons (use as icons for legendary parts)
SDSS._gen_1_folders = {
	--Vlad's Rodina
	ak74_rodina = "guis/dlcs/cash/safes/sputnik/weapon_skins/ak74_rodina",
	--Midas Touch
	deagle_bling = "guis/dlcs/cash/safes/cf15/weapon_skins/deagle_bling",
	--Dragon Lord
	flamethrower_mk2_fire = "guis/dlcs/cash/safes/cop/weapon_skins/flamethrower_mk2_fire",
	--Green Grin
	rpg7_boom = "guis/dlcs/cash/safes/cop/weapon_skins/rpg7_boom",
	--The Gimp
	m134_bulletstorm = "guis/dlcs/cash/safes/cop/weapon_skins/m134_bulletstorm",
	--Alamo Dallas
	p90_dallas_sallad = "guis/dlcs/cash/safes/dallas/weapon_skins/p90_dallas_sallad",
	--Big Kahuna
	r870_waves = "guis/dlcs/cash/safes/surf/weapon_skins/r870_waves",
	--Santa's Slayers
	x_1911_ginger = "guis/dlcs/cash/safes/flake/weapon_skins/x_1911_ginger",
	--Don Pastrami
	model70_baaah = "guis/dlcs/cash/safes/bah/weapon_skins/model70_baaah",
	--Hungry Wolf
	par_wolf = "guis/dlcs/cash/safes/pack/weapon_skins/par_wolf",
	--Astatoz
	m16_cola = "guis/dlcs/cash/safes/cola/weapon_skins/m16_cola",
	--Anarcho
	judge_burn = "guis/dlcs/cash/safes/burn/weapon_skins/judge_burn",
	--Apex
	boot_buck = "guis/dlcs/cash/safes/buck/weapon_skins/boot_buck",
	--Admiral
	ksg_same = "guis/dlcs/cash/safes/same/weapon_skins/ksg_same",
	--Mars Ultor
	tecci_grunt = "guis/dlcs/cash/safes/grunt/weapon_skins/tecci_grunt",
	--Demon
	serbu_lones = "guis/dlcs/cash/safes/lones/weapon_skins/serbu_lones",
	--Plush Phoenix
	new_m14_lones = "guis/dlcs/cash/safes/lones/weapon_skins/new_m14_lones"
}

--Copied from OSA v3.0: map weapon_id to skins
--Avoid unnecessary searches in BlackMarketGui:populate_mods PostHook
SDSS._gen_1_weapons = {
	--Vlad's Rodina
	ak74 = "ak74_rodina",
	--Midas Touch
	deagle = "deagle_bling",
	x_deagle = "deagle_bling",--Also akimbo
	--Dragon Lord
	flamethrower_mk2 = "flamethrower_mk2_fire",
	--Green Grin
	rpg7 = "rpg7_boom",
	--The Gimp
	m134 = "m134_bulletstorm",
	--Alamo Dallas
	p90 = "p90_dallas_sallad",
	x_p90 = "p90_dallas_sallad",--Also akimbo
	--Big Kahuna
	r870 = "r870_waves",
	--Santa's Slayers
	x_1911 = "x_1911_ginger",
	colt_1911 = "x_1911_ginger",--Also single
	--Don Pastrami
	model70 = "model70_baaah",
	--Hungry Wolf
	par = "par_wolf",
	--Astatoz
	m16 = "m16_cola",
	--Anarcho
	judge = "judge_burn",
	x_judge = "judge_burn",--Also akimbo
	--Apex
	boot = "boot_buck",
	--Admiral
	ksg = "ksg_same",
	--Mars Ultor
	tecci = "tecci_grunt",
	--Demon
	serbu = "serbu_lones",
	--Plush Phoenix
	new_m14 = "new_m14_lones"
}

--Is there a better way to do this
--Probably not.
SDSS._akimbo_map = {
	--Pistols
	--Peacemaker and 5/7 AP don't have variants.
	{"x_rage", "new_raging_bull"},
	{"x_chinchilla", "chinchilla"},
	{"x_model3", "model3"},
	{"x_2006m", "mateba"},
	{"x_sparrow", "sparrow"},
	{"x_b92fs", "b92fs"},
	{"x_beer", "beer"},
	{"x_c96", "c96"},
	{"x_g17", "glock_17"},
	{"jowi", "g26"},
	{"x_g22c", "g22c"},
	{"x_packrat", "packrat"},
	{"x_m1911", "m1911"},
	{"x_shrew", "shrew"},
	{"x_1911", "colt_1911"},
	{"x_czech", "czech"},
	{"x_deagle", "deagle"},
	{"x_ppk", "ppk"},
	{"x_holt", "holt"},
	{"x_stech", "stech"},
	{"x_usp", "usp"},
	{"x_hs2000", "hs2000"},
	{"x_legacy", "legacy"},
	{"x_breech", "breech"},
	{"x_p226", "p226"},
	{"x_g18c", "glock_18c"},
	{"x_pl14", "pl14"},
	
	--Shotguns
	--Only a few
	{"x_rota", "rota"},
	{"x_judge", "judge"},
	{"x_basset", "basset"},
	
	--SMGs
	--All
	{"x_vityaz", "vityaz"},
	{"x_tec9", "tec9"},
	{"x_m1928", "m1928"},
	{"x_mp9", "mp9"},
	{"x_scorpion", "scorpion"},
	{"x_mp5", "new_mp5"},
	{"x_hajk", "hajk"},
	{"x_sr2", "sr2"},
	{"x_schakal", "schakal"},
	{"x_cobray", "cobray"},
	{"x_p90", "p90"},
	{"x_akmsu", "akmsu"},
	{"x_polymer", "polymer"},
	{"x_mac10", "mac10"},
	{"x_baka", "baka"},
	{"x_erma", "erma"},
	{"x_olympic", "olympic"},
	{"x_sterling", "sterling"},
	{"x_shepheard", "shepheard"},
	{"x_mp7", "mp7"},
	{"x_m45", "m45"},
	{"x_coal", "coal"},
	{"x_uzi", "uzi"},
	
	--AK.762 and AK.762 Gold
	{"akm_gold", "akm"}
}
