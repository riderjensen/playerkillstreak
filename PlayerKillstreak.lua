local PlayerKillstreak, events = CreateFrame("Frame"), {};

-- bitwise operator (bitwise and) - we use it to check for specific flags since that is the real way it should be done.
local bit_band = bit.band

local function hasaFlag(flags, flag)
	return bit_band(flags, flag) == flag
end

function Emote_Message(message)
	SendChatMessage(message,"EMOTE")
end

function events:PLAYER_DEAD(...)
	Killstreak = 0;
	DEFAULT_CHAT_FRAME:AddMessage("You have died and your killstreak has been reset to 0!")
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
				Killstreak = Killstreak + 1;
				Emote_Message("is on a " .. Killstreak .. " player killstreak!");
			end

		end
		
	end
end

function events:ADDON_LOADED(self, ...)
	if self == "PlayerKillstreak" then
		if Killstreak == nil then
			Killstreak = 0
		end
		DEFAULT_CHAT_FRAME:AddMessage("PlayerKillstreak loaded, use /pks to check your current killstreak. Good luck")
	end
end


SLASH_PLAYERKILLSTREAK1 = "/pks"
SlashCmdList["PLAYERKILLSTREAK"] = function(msg)
	Emote_Message("has a current killstreak of " .. Killstreak .. "!");
end


PlayerKillstreak:SetScript("OnEvent", function(self, event, ...)
	events[event](self, ...); -- call one of the functions above (event:xxx())
   end);
   
for k, v in pairs(events) do
	PlayerKillstreak:RegisterEvent(k); -- Register events for which handlers have been defined (event:)
end

