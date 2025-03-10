local PlayerKillstreak, events = CreateFrame("Frame"), {};

-- bitwise operator (bitwise and) - we use it to check for specific flags since that is the real way it should be done.
local bit_band = bit.band

-- Taken from Meefs Mod
--t = { {a, b, c}, {d, e, f} };
--print(t[1][1]);  -- > prints "a"
-- We're gonna store all our killstreak sounds in a table (whos values are also each a table of the possible sound file names) and call them by their relative index.
-- for example, PKSSounds[1][X-Y] will all be first blood sounds - so we will get a random firstblood sound with PKSSounds[1][Number between 1 and # values]
-- doing this allows us to very easily add new sounds, and even overwrite the sound table completely for possible sound packs or different options, etc. (plus its pretty effecient)
-- most of the sounds are done in this way, I tried to make stuff really readable and easy to change in case someone wanted to customize it.

-- https://dota2.fandom.com/wiki/Announcer_responses
local PKSSounds = { 
	{"announcer_kill_first_blood_01.mp3"}, -- Single
	{"announcer_kill_double_01.mp3"}, -- Double
	{"announcer_kill_triple_01.mp3"}, -- Triple
	{"announcer_kill_spree_01.mp3"}, -- Killing spree
	{"announcer_kill_dominate_01.mp3"}, -- Dominating
	{"announcer_kill_ultra_01.mp3"}, -- Ultra
	{"announcer_kill_mega_01.mp3"}, -- Mega kill
	{"announcer_kill_rampage_01.mp3"}, -- Rampage
	{"announcer_kill_unstop_01.mp3"}, -- Unstoppable
	{"announcer_kill_wicked_01.mp3"}, -- Wicked sick
	{"announcer_kill_monster_01.mp3"}, -- Monster
	{"announcer_kill_godlike_01.mp3"}, -- Godlike
	{"announcer_kill_holy_01.mp3"}, -- Beyond godlike
	{"announcer_ownage_01.mp3"} -- Ownage
}
-- https://dota2.fandom.com/wiki/Rick_and_Morty_Announcer_Pack
local PKSSounds_RickNMorty = { 
	{"rm_fb_01.mp3", "rm_fb_02.mp3", "rm_fb_03.mp3", "rm_fb_04.mp3", "rm_fb_05.mp3", "rm_fb_06.mp3", "rm_fb_07.mp3", "rm_fb_08.mp3"}, -- Single
	{"rm_double_01.mp3", "rm_double_02.mp3", "rm_double_03.mp3", "rm_double_04.mp3"}, -- Double
	{"rm_triple_01.mp3", "rm_triple_02.mp3", "rm_triple_03.mp3", "rm_triple_04.mp3", "rm_triple_05.mp3"}, -- Triple
	{"rm_ks_01.mp3", "rm_ks_02.mp3", "rm_ks_03.mp3", "rm_ks_04.mp3", "rm_ks_05.mp3", "rm_ks_06.mp3", "rm_ks_07.mp3", "rm_ks_08.mp3", "rm_ks_09.mp3", "rm_ks_10.mp3", "rm_ks_11.mp3"}, -- Killing spree
	{"rm_dom_01.mp3", "rm_dom_02.mp3", "rm_dom_03.mp3", "rm_dom_04.mp3"}, -- Dominating
	{"rm_ultra_01.mp3", "rm_ultra_02.mp3", "rm_ultra_03.mp3", "rm_ultra_04.mp3", "rm_ultra_05.mp3"}, -- Ultra
	{"rm_mega_01.mp3", "rm_mega_02.mp3", "rm_mega_03.mp3", "rm_mega_04.mp3", "rm_mega_05.mp3"}, -- Mega kill
	{"rm_rampage_01.mp3", "rm_rampage_02.mp3", "rm_rampage_03.mp3", "rm_rampage_04.mp3", "rm_rampage_05.mp3", "rm_rampage_06.mp3", "rm_rampage_07.mp3", "rm_rampage_08.mp3"}, -- Rampage
	{"rm_unstoppable_01.mp3", "rm_unstoppable_02.mp3", "rm_unstoppable_03.mp3"}, -- Unstoppable
	{"rm_ws_01.mp3", "rm_ws_02.mp3", "rm_ws_03.mp3", "rm_ws_04.mp3"}, -- Wicked sick
	{"rm_mk_01.mp3", "rm_mk_02.mp3", "rm_mk_03.mp3", "rm_mk_04.mp3", "rm_mk_05.mp3", "rm_mk_06.mp3"}, -- Monster
	{"rm_godlike_01.mp3", "rm_godlike_02.mp3", "rm_godlike_03.mp3", "rm_godlike_04.mp3", "rm_godlike_05.mp3", "rm_godlike_06.mp3"}, -- Godlike
	{"rm_holy_01.mp3", "rm_holy_02.mp3", "rm_holy_03.mp3", "rm_holy_04.mp3", "rm_holy_05.mp3", "rm_holy_06.mp3", "rm_holy_07.mp3", "rm_holy_08.mp3"}, -- Beyond godlike
	{"rm_ownage_01.mp3", "rm_ownage_02.mp3", "rm_ownage_03.mp3", "rm_ownage_04.mp3"} -- Ownage
}

local PKSSounds_Halo = {
	{"KS-OpenSeason.mp3"}, -- Single
	{"KS-DoubleKill.mp3"}, -- Double
	{"KS-TripleKill.mp3"}, -- Triple
	{"KS-KillingSpree.mp3"}, -- Killing spree
	{"KS-WreckingCrew.mp3"}, -- Dominating
	{"KS-Killtacular.mp3"}, -- Ultra
	{"KS-Killtrocity.mp3", "KS-RunningRiot.mp3"}, -- Mega
	{"KS-Killtastrophe.mp3", "KS-Rampage.mp3"}, -- Rampage
	{"KS-Untouchable.mp3"}, -- Unstoppable
	{"KS-Extermination.mp3", "KS-BuckWild.mp3"}, -- Wicked sick
	{"KS-Invincible.mp3"}, -- Monster
	{"KS-Broseidon.mp3"}, -- Godlike
	{"KS-Unfrigginbelievable.mp3"}, -- Beyond godlike
	{"KS-HailtotheKing.mp3"} -- Ownage
}

-- https://dota2.fandom.com/wiki/Bastion_Announcer_Pack
local PKSSounds_Bastion = {
	{"b_fb_01.mp3", "b_fb_02.mp3", "b_fb_03.mp3"}, -- Single
	{"b_double_01.mp3"}, -- Double
	{"b_triple_01.mp3"}, -- Triple
	{"b_ks_01.mp3", "b_ks_02.mp3", "b_ks_03.mp3"}, -- Killing spree
	{"b_dom_01.mp3"}, -- Dominating
	{"b_ultra_01.mp3"}, -- Ultra
	{"b_mega_01.mp3"}, -- Mega
	{"b_rampage_01.mp3"}, -- Rampage
	{"b_unstoppable_01.mp3"}, -- Unstoppable
	{"b_ws_01.mp3"}, -- Wicked sick
	{"b_mk_01.mp3"}, -- Monster
	{"b_godlike_01.mp3"}, -- Godlike
	{"b_holy_01.mp3", "b_holy_02.mp3", "b_holy_03.mp3", "b_holy_05.mp3", "b_holy_04.mp3", "b_holy_06.mp3", "b_holy_07.mp3", "b_holy_08.mp3", "b_holy_09.mp3", "b_holy_10.mp3"}, -- Beyond godlike
	{"b_ownage_01.mp3"} -- Ownage
}

local PKSoundPathNoExt = "Interface\\AddOns\\PlayerKillstreak\\Sounds\\%s"


local function hasaFlag(flags, flag)
	return bit_band(flags, flag) == flag
end

function Emote_Message(message)
	SendChatMessage(message,"EMOTE")
end

function EmoteStreakAndHighScore()
	Emote_Message("is on a " .. KillstreakSettings["streak"] .. " player killstreak! That's a new high score!");
end

function EmoteStreak()
	Emote_Message("is on a " .. KillstreakSettings["streak"] .. " player killstreak!");
end

function EmoteHighScore()
	Emote_Message("has a current player killstreak high score of " .. KillstreakSettings["highscore"] .. "!");
end

function PrintHelpText()
	print("|cFFFF0000PlayerKillstreak Commands:|r");
	print("|cFFFF0000/pks streak|r - emotes our your current killstreak.");
	print("|cFFFF0000/pks highscore|r - emotes out your highest killstreak.");
	print("|cFFFF0000/pks sound|r - toggles the sound on/off for kills.");
end

function ToggleSound()
	if KillstreakSettings["sound_enabled"] == false then
		KillstreakSettings["sound_enabled"] = true;
		print("|cFFFF0000PlayerKillstreak:|r Sound Enabled.");
	else
		KillstreakSettings["sound_enabled"] = false;
		print("|cFFFF0000PlayerKillstreak:|r Sound Disabled");
	end
end

-- Stolen from Meefs Mod
function PlayKillstreakSound(streak)
	local soundindex = math.min(13, streak)
	local randomInt = math.random(4)

	local PKS_SoundFile;

	if randomInt == 1 then
		--play rick n morty killstreak sound instead
		PKS_SoundFile = PKSSounds_RickNMorty[soundindex][math.random(#PKSSounds_RickNMorty[soundindex])]
	elseif randomInt == 2 then
		--play halo killstreak sound instead
		PKS_SoundFile = PKSSounds_Halo[soundindex][math.random(#PKSSounds_Halo[soundindex])]
	elseif randomInt == 3 then
		--play bastion killstreak sound instead
		PKS_SoundFile = PKSSounds_Bastion[soundindex][math.random(#PKSSounds_Bastion[soundindex])]
	else
		--play regular killstreak sound
		PKS_SoundFile = PKSSounds[soundindex][math.random(#PKSSounds[soundindex])]
	end
	PlaySoundFile(string.format(PKSoundPathNoExt, PKS_SoundFile), "Master")

end


function events:PLAYER_DEAD(...)
	if KillstreakSettings["streak"] > 0 then
		DEFAULT_CHAT_FRAME:AddMessage(string.format("You have died and your killstreak of %i has been reset to 0!", KillstreakSettings["streak"]))
	end
	KillstreakSettings["streak"] = 0;
end

function events:COMBAT_LOG_EVENT_UNFILTERED(...)
	local timestamp, eventType, hideCasterboolean, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

    -- THIS IS A REAL EXAMPLE of killing a molten giant in MC from wowcombatlog.txt - the only reliable fucking way to figure out what the hell blizzard kept in for classic; Though there actually is a hideCaster 3rd param that is a boolean. I'm not sure if the raid flags WORK (sourceraidflags, destraidflags) since those were added in 4.2, but they might and they are set to 0x0 so they do need to be accounted for at least.
    -- 1/28 18:25:27.087 PARTY_KILL,Player-4396-00041B98,"Chinagold-Fairbanks",0x511,0x0,Creature-0-4380-409-5515-11658-0005B0DFC1,"Molten Giant",0x10a48,0x0
    --    timestamp     event       sourceguid,            sourceName, sourceflags, sourceraidflags, destguid,                     destName,   destflags,   destraidflags

	if eventType == "PARTY_KILL" then

		if (sourceFlags) and (destFlags) then
			
			if hasaFlag(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) and hasaFlag(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) then
				-- WE KILLED A PLAYER
				KillstreakSettings["streak"] = KillstreakSettings["streak"] + 1;
				
				if KillstreakSettings["streak"] > KillstreakSettings["highscore"] then
					KillstreakSettings["highscore"] = KillstreakSettings["streak"];
					EmoteStreakAndHighScore();
				else
					EmoteStreak();
				end

				if (KillstreakSettings["sound_enabled"]) then
					PlayKillstreakSound(KillstreakSettings["streak"]);
				end

			end

		end
		
	end
end

function events:ADDON_LOADED(self, ...)
	if self == "PlayerKillstreak" then
		if KillstreakSettings == nil then
			KillstreakSettings = {
                sound_enabled = true,
                streak = 0,
				highscore = 0
            }
		end
		DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000PlayerKillstreak Loaded:|r use /pks to access the menu. Good luck")
	end
end

SLASH_PLAYERKILLSTREAK1 = "/pks"
SlashCmdList["PLAYERKILLSTREAK"] = function(msg)
	msg = string.lower(msg);
	if msg == "streak" then
		EmoteStreak();
	elseif msg == "highscore" then
		EmoteHighScore();
	elseif msg == "sound" then
		ToggleSound();
	else
		PrintHelpText();
	end
end


PlayerKillstreak:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...); -- call one of the functions above (event:xxx())
   end);
   
for k, v in pairs(events) do
	PlayerKillstreak:RegisterEvent(k); -- Register events for which handlers have been defined (event:)
end

