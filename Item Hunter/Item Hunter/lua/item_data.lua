--Item data for collectible achievements
ItemHunter.item_data = ItemHunter.item_data or {}

--Cheerful Child (halloween_nightmare_1)
--Gilliam's Sweet Little Baby (halloween_nightmare_2)
--Temper Tantrum (halloween_nightmare_3)
--Water Works (halloween_nightmare_4)
ItemHunter.item_data.halloween_nightmare = {}
ItemHunter.item_data.halloween_nightmare.level = "haunted"--Safe House Nightmare
ItemHunter.item_data.halloween_nightmare.difficulty = {"normal", "hard", "overkill", "overkill_145"}
ItemHunter.item_data.halloween_nightmare.objectives = {
	interactions = {
		{id = "Idstring(@IDed460720f09333e7@)", name = "halloween_trick", offset = Vector3(0,0,10)}
	}
}

--Praying Mantis (gmod_1)
--Bullseye (gmod_2)
--My Spider Sense is Tingling (gmod_3)
--Eagle Eyes (gmod_4)
--Like A Boy Killing Snakes (gmod_5)
--There and Back Again (gmod_6)
ItemHunter.item_data.gmod = {}
ItemHunter.item_data.gmod.level = "any"
ItemHunter.item_data.gmod.exclude = {
	"safehouse",--The Safe House (Laundromat)
	"chill",--Safe House (Customizable)
	"chill_combat",--Safe House Raid
	"haunted",--Safe House Nightmare
	"hvh",--Cursed Kill Room
	"short1_stage1", "short1_stage2",--Flash Drive (Stealth Tutorial)
	"short2_stage1", "short2_stage2b",--Get the Coke (Loud Tutorial)
	"skm_mus",--Holdout (The Diamond)
	"skm_red2",--Holdout (First World Bank)
	"skm_run",--Holdout (Heat Street)
	"skm_watchdogs_stage2"--Holdout (Boat Load)
}
ItemHunter.item_data.gmod.objectives = {
	interactions = {
		{id = "Idstring(@IDb3cc2abe1734636c@)", name = "gage_assignment"},--Green Mantis
		{id = "Idstring(@IDe8088e3bdae0ab9e@)", name = "gage_assignment"},--Yellow Bull
		{id = "Idstring(@ID96504ebd40f8cf98@)", name = "gage_assignment"},--Red Spider
		{id = "Idstring(@ID05956ff396f3c58e@)", name = "gage_assignment"},--Blue Eagle
		{id = "Idstring(@IDc90378ad89058c7d@)", name = "gage_assignment"}--Purple Snake
	}
}

--400 Bucks (sinus_1)
--Jason trophy (trophy_hobo_knife)
ItemHunter.item_data.sinus_1 = {}
ItemHunter.item_data.sinus_1.level = "jolly"--Aftershock
ItemHunter.item_data.sinus_1.host_only = true
ItemHunter.item_data.sinus_1.objectives = {
	interactions = {
		{id = "Idstring(@ID75f9f627f511ecf0@)", name = "hold_pku_knife"}
	},
	civilians = {
		{id = Idstring("units/pd2_dlc_holly/characters/civ_male_hobo_1/civ_male_hobo_1")}
	}
}

--Au Ticket (green_7)
ItemHunter.item_data.green_7 = {}
ItemHunter.item_data.green_7.level = "red2"--First World Bank
ItemHunter.item_data.green_7.objectives = {
	interactions = {
		{id = "Idstring(@ID584bea03f3b5d712@)", name = "drill"},--Drill
		{id = "Idstring(@IDbc82f074e26377d3@)", name = "red_take_envelope"}--Envelope
	}
}

--Note: disabled
--Pyromaniacs (farm_4)
ItemHunter.item_data.farm_4 = {}
ItemHunter.item_data.farm_4.level = "dinner"--Slaughterhouse (dinner)
ItemHunter.item_data.farm_4.difficulty = {}
ItemHunter.item_data.farm_4.objectives = {
	interactions = {
		{id = "Idstring(@IDfafc44e9ee9e084f@)", name = "hold_take_gas_can"}
	}
}

--Pork Royale (farm_6)
ItemHunter.item_data.farm_6 = {}
ItemHunter.item_data.farm_6.level = "dinner"--Slaughterhouse
ItemHunter.item_data.farm_6.difficulty = {"overkill_145", "easy_wish", "overkill_290", "sm_wish"}
ItemHunter.item_data.farm_6.objectives = {
	interactions = {
		{id = "Idstring(@ID9d8090e54d60088d@)", name = "pku_pig", offset = Vector3(0,0,-350)}
	}
}

--Mellon (voff_4)
--The Ring trophy (trophy_ring)
ItemHunter.item_data.voff_4 = {}
ItemHunter.item_data.voff_4.level = "pbr2"--Birth of Sky
ItemHunter.item_data.voff_4.objectives = {
	interactions = {
		{id = "Idstring(@ID81c2839a6218ee04@)", name = "ring_band"}
	}
}

--Note: only available on Normal
--The Saviour (man_4)
ItemHunter.item_data.man_4 = {}
ItemHunter.item_data.man_4.level = "man"--Undercover
ItemHunter.item_data.man_4.difficulty = {"normal"}
ItemHunter.item_data.man_4.objectives = {
	interactions = {
		{id = "Idstring(@IDca8a8a281362414d@)", name = "stash_planks_pickup"}
	}
}

--Scavenger (born_4)
ItemHunter.item_data.born_4 = {}
ItemHunter.item_data.born_4.level = "born"--Biker Heist Day 1
ItemHunter.item_data.born_4.objectives = {
	interactions = {
		{id = "Idstring(@ID98eaa2fc760d6c7b@)", name = "press_pick_up", offset = Vector3(0,0,50)}
	}
}

--The Dentist Delight (flat_3)
ItemHunter.item_data.flat_3 = {}
ItemHunter.item_data.flat_3.level = "flat"--Panic Room
ItemHunter.item_data.flat_3.objectives = {
	interactions = {
		{id = "Idstring(@IDdae9380929168444@)", name = "pku_toothbrush"}
	}
}

--Spooky Pumpkin trophy (trophy_spooky)
ItemHunter.item_data.trophy_spooky = {}
ItemHunter.item_data.trophy_spooky.level = "help"--Prison Nightmare
ItemHunter.item_data.trophy_spooky.host_only = true
ItemHunter.item_data.trophy_spooky.objectives = {
	units = {
		{id = "Idstring(@ID513a873fc49c5944@)", offset = Vector3(0, 0, 15)}
	}
}

--Chemical Weapons (tango_1)
ItemHunter.item_data.tango_1 = {}
ItemHunter.item_data.tango_1.level = "multiple"
ItemHunter.item_data.tango_1.levels = {"alex_1", "alex_2", "alex_3"}--Rats Day 1, Day 2, Day 3
ItemHunter.item_data.tango_1.objectives = {
	interactions = {
		{id = "Idstring(@ID57d12b1cef69c184@)", name = "pickup_keys"},
		{id = "Idstring(@ID48f33f86a5cfd226@)", name = "pickup_case", offset = Vector3(0,0,10)}
	}
}

--War for Oil (tango_2)
ItemHunter.item_data.tango_2 = {}
ItemHunter.item_data.tango_2.level = "multiple"
ItemHunter.item_data.tango_2.levels = {"welcome_to_the_jungle_1",  "welcome_to_the_jungle_1_night", "welcome_to_the_jungle_2"}--Big Oil Day 1, Day 1 Night, Day 2
ItemHunter.item_data.tango_2.objectives = {
	interactions = {
		{id = "Idstring(@ID79f3d251978db6b5@)", name = "pickup_keys"},
		{id = "Idstring(@ID6271c975f8eb1064@)", name = "pickup_case", offset = Vector3(0,0,10)}
	}
}

--Mic (tango_3)
ItemHunter.item_data.tango_3 = {}
ItemHunter.item_data.tango_3.level = "multiple"
ItemHunter.item_data.tango_3.levels = {"framing_frame_1", "framing_frame_2", "framing_frame_3"}--Framing Frame Day 1, Day 2, Day 3
ItemHunter.item_data.tango_3.objectives = {
	interactions = {
		{id = "Idstring(@ID29cc1098e2f97aa8@)", name = "pickup_keys"},
		{id = "Idstring(@ID0d7d971d2fc9aa66@)", name = "pickup_case", offset = Vector3(0,0,10)}
	}
}

--Open Fire (tango_4)
ItemHunter.item_data.tango_4 = {}
ItemHunter.item_data.tango_4.level = "multiple"
ItemHunter.item_data.tango_4.levels = {"firestarter_1", "firestarter_2", "firestarter_3"}--Firestarter Day 1, Day 2, Day 3
ItemHunter.item_data.tango_4.objectives = {
	interactions = {
		{id = "Idstring(@ID30d30f492d7e2c6f@)", name = "pickup_keys"},
		{id = "Idstring(@ID856532b88da2e6c9@)", name = "pickup_case", offset = Vector3(0,0,10)}
	}
}

--Imitations (moon_4)
ItemHunter.item_data.moon_4 = {}
ItemHunter.item_data.moon_4.level = "moon"--Stealing Xmas
ItemHunter.item_data.moon_4.objectives = {
	interactions = {
		{id = "Idstring(@ID1c1e7a7d332799ba@)", name = "hold_take_mask", offset = Vector3(0,0,10)},--Dallas
		{id = "Idstring(@ID775b20eda9fdae0b@)", name = "hold_take_mask", offset = Vector3(0,0,10)}--Chains
	}
}

--Look at These Pelicans Fall (friend_5)
--Pelican Killer trophy (trophy_flamingo)
ItemHunter.item_data.friend_5 = {}
ItemHunter.item_data.friend_5.level = "friend"--Scarface Mansion
ItemHunter.item_data.friend_5.objectives = {
	units = {
		{id = Idstring("units/pd2_dlc_friend/props/sfm_prop_ext_flamingo/sfm_prop_ext_flamingo_a"), offset = Vector3(0, 0, 60)},
		{id = Idstring("units/pd2_dlc_friend/props/sfm_prop_ext_flamingo/sfm_prop_ext_flamingo_b"), offset = Vector3(0, 0, 60)}
	}
}

--Zookeeper (run_8)
ItemHunter.item_data.run_8 = {}
ItemHunter.item_data.run_8.level = "run"--Heat Street
ItemHunter.item_data.run_8.objectives = {
	interactions = {
		{id = "Idstring(@ID47dbdb1a2198bda4@)", name = "hold_take_missing_animal_poster"},
		{id = "Idstring(@IDd63c1c093af395ce@)", name = "hold_take_missing_animal_poster"},
		{id = "Idstring(@IDc730799a2e813776@)", name = "hold_take_missing_animal_poster"},
		{id = "Idstring(@IDe2ef56e1a70abcbe@)", name = "hold_take_missing_animal_poster"},
		{id = "Idstring(@ID9b87d4f18986beaa@)", name = "hold_take_missing_animal_poster"},
		{id = "Idstring(@IDdf7cc89c7ca0aebf@)", name = "hold_take_missing_animal_poster"},
		{id = "Idstring(@ID06661a5618dd09f7@)", name = "hold_take_missing_animal_poster"},
		{id = "Idstring(@IDaf25431aea7b006a@)", name = "hold_take_missing_animal_poster"}
	}
}

--Not So Fast trophy (trophy_run_turtle)
ItemHunter.item_data.trophy_run_turtle = {}
ItemHunter.item_data.trophy_run_turtle.level = "run"--Heat Street
ItemHunter.item_data.trophy_run_turtle.objectives = {
	interactions = {
		{id = "Idstring(@ID87340cce49796ae9@)", name = "hold_pick_up_turtle", offset = Vector3(0,0,10)}
	}
}

--Tied Up trophy (trophy_glace_cuffs)
ItemHunter.item_data.trophy_glace_cuffs = {}
ItemHunter.item_data.trophy_glace_cuffs.level = "glace"--Green Bridge
ItemHunter.item_data.trophy_glace_cuffs.objectives = {
	interactions = {
		{id = "Idstring(@ID8e69f944f96dc71b@)", name = "glc_hold_take_handcuffs"}
	}
}

--The Briefcase side job (jfr_1)
--Historiographer trophy (trophy_jfr_1) [Partial]
ItemHunter.item_data.jfr_1 = {}
ItemHunter.item_data.jfr_1.level = "firestarter_1"--Firestarter Day 1
ItemHunter.item_data.jfr_1.objectives = {
	interactions = {
		{id = "Idstring(@ID503f5c8d4e3dab46@)", name = "take_jfr_briefcase"}
	}
}

--The only one that is true (eng_1)
--The Bullet trophy (trophy_eng_1)
ItemHunter.item_data.eng_1 = {}
ItemHunter.item_data.eng_1.level = "multiple"
ItemHunter.item_data.eng_1.levels = {"branchbank", "firestarter_3", "jewelry_store"}--Bank Heist, Firestarter Day 3, Jewelry Store
ItemHunter.item_data.eng_1.objectives = {
	interactions = {
		{id = "Idstring(@ID8477cb869f7f17b2@)", name = "press_pick_up", offset = Vector3(0,0,20)}
	}
}

--The one that had many names (eng_2)
--The Robot trophy (trophy_eng_2)
ItemHunter.item_data.eng_2 = {}
ItemHunter.item_data.eng_2.level = "multiple"
ItemHunter.item_data.eng_2.levels = {"kosugi", "red2"}--Shadow Raid, First World Bank
ItemHunter.item_data.eng_2.objectives = {
	interactions = {
		{id = "Idstring(@IDd7250b2935078a60@)", name = "press_pick_up", offset = Vector3(0,0,20)}
	}
}

--The one that survived (eng_3)
--The Marine trophy (trophy_eng_3)
ItemHunter.item_data.eng_3 = {}
ItemHunter.item_data.eng_3.level = "multiple"
ItemHunter.item_data.eng_3.levels = {"roberts", "four_stores"}--GO Bank, Four Stores
ItemHunter.item_data.eng_3.objectives = {
	interactions = {
		{id = "Idstring(@ID1f0e0c8514903928@)", name = "press_pick_up", offset = Vector3(0,0,20)}
	}
}

--The one who declared himself the hero (eng_4)
--The Cultist trophy (trophy_eng_4)
ItemHunter.item_data.eng_4 = {}
ItemHunter.item_data.eng_4.level = "multiple"
ItemHunter.item_data.eng_4.levels = {"hox_1", "family"}--Hoxton Breakout Day 1, Diamond Store
ItemHunter.item_data.eng_4.objectives = {
	interactions = {
		{id = "Idstring(@ID3cf2613b6a24aba0@)", name = "press_pick_up", offset = Vector3(0,0,20)}
	}
}

--There Was Room For Two (wwh_8)
ItemHunter.item_data.wwh_8 = {}
ItemHunter.item_data.wwh_8.level = "wwh"--Alaskan Deal
ItemHunter.item_data.wwh_8.host_only = true
ItemHunter.item_data.wwh_8.objectives = {
	units = {
		{id = Idstring("units/payday2/characters/ene_cop_2/ene_cop_2")}
	}
}

--Headless Snowmen (wwh_10)
ItemHunter.item_data.wwh_10 = {}
ItemHunter.item_data.wwh_10.level = "wwh"--Alaskan Deal
ItemHunter.item_data.wwh_10.objectives = {
	units = {
		{id = "Idstring(@ID64f4cad27baa8df9@)", offset = Vector3(0, 0, 30)}
	}
}

--The Hunt for the Blue Sapphires (dah_8)
ItemHunter.item_data.dah_8 = {}
ItemHunter.item_data.dah_8.level = "dah"--Diamond Heist
ItemHunter.item_data.dah_8.objectives = {
	interactions = {
		{id = "Idstring(@IDaceb13c69bab6199@)", name = "cut_glass", offset = Vector3(0,0,180)},--Glass Case
		{id = "Idstring(@ID231198dfe1f97bef@)", name = "diamond_single_pickup_axis", offset = Vector3(0,0,120)}--Sapphire
	}
}

--Staple Relationship (tag_11)
ItemHunter.item_data.tag_11 = {}
ItemHunter.item_data.tag_11.level = "tag"--Breakin' Feds
ItemHunter.item_data.tag_11.objectives = {
	interactions = {
		{id = "Idstring(@ID0e39919d7ad83e4a@)", name = "tag_take_stapler", offset = Vector3(0,0,5)},
		{id = "Idstring(@ID67dcefeeaf45567c@)", name = "press_place_stapler", offset = Vector3(0,0,5)}
	}
}

--Press [F] to Pay Respects (sah_10)
ItemHunter.item_data.sah_10 = {}
ItemHunter.item_data.sah_10.level = "sah"--Shacklethorne
ItemHunter.item_data.sah_10.objectives = {
	units = {
		{id = "Idstring(@ID4b323e0ca7e24955@)", offset = Vector3(55, 105, 170)}--Mummy
	}
}

--Note: disabled
--Heavy Metal (sah_11)
ItemHunter.item_data.sah_11 = {}
ItemHunter.item_data.sah_11.level = "sah"--Shacklethorne
ItemHunter.item_data.sah_11.host_only = true
ItemHunter.item_data.sah_11.difficulty = {}
ItemHunter.item_data.sah_11.objectives = {
	units = {
		{id = Idstring("units/world/props/gym/gym_cover_metaldetector/stn_cover_metaldetector"), offset = Vector3(0, 0, 100)}
	},
	interactions = {
		{id = "Idstring(@IDb88b91bf3b4898aa@)", name = "hold_take_wrench"}
	},
	civilians = {
		{id = "Idstring(@ID6e6969100b52ea22@)"}
	}
}

--A Heist to Remember (vit_9)
ItemHunter.item_data.vit_9 = {}
ItemHunter.item_data.vit_9.level = "vit"--White House
ItemHunter.item_data.vit_9.objectives = {
	interactions = {
		{id = "Idstring(@ID2286ce1b2545957b@)", name = "press_pick_up"}
	}
}

--Note: disabled
--What's in the Box? (uno_9)
ItemHunter.item_data.uno_9 = {}
ItemHunter.item_data.uno_9.level = "pines"--White Xmas
ItemHunter.item_data.uno_9.difficulty = {}
ItemHunter.item_data.uno_9.objectives = {
	interactions = {
		{id = "Idstring(@IDc0c4c07c8ad94496@)", name = "hold_open_xmas_present", offset = Vector3(0,0,15)},--Initial presents
		{id = "Idstring(@IDa24fea75b953f368@)", name = "hold_open_xmas_present", offset = Vector3(0,0,15)}--New drops
	}
}

--Identity Theft (mex_9)
ItemHunter.item_data.mex_9 = {}
ItemHunter.item_data.mex_9.level = "mex"--Border Crossing
ItemHunter.item_data.mex_9.objectives = {
	interactions = {
		{id = "Idstring(@ID2286ce1b2545957b@)", name = "mex_pickup_murky_uniforms"}
	}
}
