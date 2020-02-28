local achievement_list = {
	--Hoxton, Nova's Shank
	"bulldog_1",--Why Don't We Just Use a Spoon?
	
	--Monkey Wrench
	"sah_11",--Heavy Metal
	
	--Outfits
	"dah_1",--Valuable Ornaments
	"nmh_1",--Just Some Medical Students
	"glace_1",--Taking the High Road
	"mex_9",--Identity Theft
	"sah_1",--Trip to the Coast
	"wwh_1",--Friendship Frozen
	"trk_cou_0",--Ink, Paper, Roll Out the Dough
	"bex_1",--Mariachis Have More Fun
	"bex_2",--Is That a Gun or a Guitar?
	"bex_4",--Guitars And ARs
	"bex_6",--Your Gunfire is Drowning out my Trumpet
	"bex_7",--Mariachi Day
	
	--Secret
	"armored_1",--We're Gonna Need a Bigger Boat
	"armored_2",--But Wait - There's More!
	"bat_2",--Cat Burglar
	"berry_2",--Clean House
	"bigbank_5",--Don't Bring the Heat
	"bob_3",--I'm a Swinger
	"born_5",--Full Throttle
	"bph_11",--Beacon of.. nope
	"brb_8",--All the Gold in Brooklyn
	"cac_13",--Remember, No Russian
	"cac_26",--Watch The Power Switch!
	"cac_9",--Quick Draw
	"cane_2",--Santa Slays Slackers
	"charliesierra_5",--All Eggs in One Basket
	"cow_10",--I've Got the Power
	"cow_4",--Pump It Up
	"dah_9",--Blood Diamond
	"dark_3",--The Pacifist
	"diamonds_are_forever",--Diamonds Are Forever
	"doctor_fantastic",--Doctor Fantastic
	"fish_5",--Pacifish
	"fort_4",--Gone in 240 Seconds
	"green_6",--OVERDRILL
	"halloween_2",--Full Measure
	"i_wasnt_even_there",--I Wasn't Even There!
	"jerry_4",--1... 2... 3... JUMP!
	"kenaz_4",--High Roller
	"kosugi_2",--I Will Pass Through Walls
	"lets_do_this",--Let's Do Th...
	"live_2",--Sound of Silence
	"lord_of_war",--Lord of War
	"man_2",--Not Even Once
	"melt_3",--They Don't Pay Us Enough
	"moon_5",--The Grinch
	"nmh_10",--Keeping the Cool
	"pal_2",--Dr. Evil
	"payback_2",--Silent But Deadly
	"peta_3",--Hazzard County
	"pig_2",--Walk Faster
	"run_10",--It's Nice to be Nice
	"rvd_11",--Waste Not, Want Not
	"sah_10",--Press [F] to Pay Respects
	"spa_5",--A Rendezvous With Destiny
	"tag_10",--Stalker
	"trk_af_3",--Bring it Back Safe
	"trk_fs_3",--Stomping Grounds
	"trk_sh_3",--Puts the "S" in Laughterhouse.
	"uno_1",--A Good Haul
	"uno_2",--Hostage Situation
	"uno_3",--Self Checkout
	"uno_4",--Attacked Helicopter
	"uno_5",--Hack This!
	"uno_6",--Let them Boogie
	"uno_7",--Settling a Scar
	"uno_8",--Out Of Bounds
	"uno_9",--What's in the Box?
	"wwh_9"--The Fuel Must Flow
}

for _, id in pairs(achievement_list) do
	IOF._state[id] = false
end
