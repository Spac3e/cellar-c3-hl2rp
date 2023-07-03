local PLUGIN = PLUGIN || {}

PLUGIN.name = "Core Modifications"
PLUGIN.description = ""
PLUGIN.author = ""

ix.config.language = "russian"

ix.currency.symbol = ""
ix.currency.singular = "token"
ix.currency.plural = "tokens"

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sh_hooks.lua")
ix.util.Include("meta/sh_item.lua")

if CLIENT then
	language.Add("game_player_joined_game", "")
	language.Add("game_player_left_game", "")
end

do 
	local function fixOOC()
		ix.chat.Register("ooc", {
			CanSay = function(self, speaker, text)
				if (!ix.config.Get("allowGlobalOOC")) then
					speaker:NotifyLocalized("Global OOC is disabled on this server.")
					return false
				else
					local delay = ix.config.Get("oocDelay", 10)

					-- Only need to check the time if they have spoken in OOC chat before.
					if (delay > 0 and speaker.ixLastOOC) then
						local lastOOC = CurTime() - speaker.ixLastOOC

						-- Use this method of checking time in case the oocDelay config changes.
						if (lastOOC <= delay and !CAMI.PlayerHasAccess(speaker, "Helix - Bypass OOC Timer", nil)) then
							speaker:NotifyLocalized("oocDelay", delay - math.ceil(lastOOC))

							return false
						end
					end

					-- Save the last time they spoke in OOC.
					speaker.ixLastOOC = CurTime()
				end
			end,
			OnChatAdd = function(self, speaker, text)
				-- @todo remove and fix actual cause of speaker being nil
				if (!IsValid(speaker)) then
					return
				end

				local icon = serverguard.ranks:GetRank(serverguard.player:GetRank(speaker)).texture or "icon16/user.png"

				icon = Material(hook.Run("GetPlayerIcon", speaker) or icon)

				chat.AddText(icon, Color(255, 50, 50), "[OOC] ", speaker, color_white, ": "..text)
			end,
			prefix = {"//", "/OOC"},
			description = "@cmdOOC",
			noSpaceAfter = true
		})
	end

	hook.Add("InitializedConfig", "ixChatTypes2", function()
		fixOOC()
	end)

	fixOOC()
end

if (SERVER) then
	function PLUGIN:SetPlayerFlags(client, flags)
		client:SetData("playerFlags", flags)
	end

	function PLUGIN:GivePlayerFlags(client, flags)
		local addedFlags = ""

		for i = 1, #flags do
			local flag = flags[i]
			local info = ix.flag.list[flag]

			if (info) then
				if (!self:HasPlayerFlags(client, flag)) then
					addedFlags = addedFlags .. flag
				end

				if (info.callback) then
					info.callback(client, true)
				end
			end
		end

		if (addedFlags != "") then
			self:SetPlayerFlags(client, self:GetPlayerFlags(client) .. addedFlags)
		end
	end

	function PLUGIN:TakePlayerFlags(client, flags)
		local oldFlags = self:GetPlayerFlags(client)
		local newFlags = oldFlags

		for i = 1, #flags do
			local flag = flags[i]
			local info = ix.flag.list[flag]

			if (info and info.callback) then
				info.callback(client, false)
			end

			newFlags = newFlags:gsub(flag, "")
		end

		if (newFlags != oldFlags) then
			self:SetPlayerFlags(client, newFlags)
		end
	end

	function PLUGIN:ClearPlayerFlags(client)
		self:TakePlayerFlags(client, self:GetPlayerFlags(client))
	end

	function PLUGIN:GivePlayerAllFlags(client)
		for flag in pairs(ix.flag.list) do
			self:GivePlayerFlags(client, flag)
		end
	end
end

function PLUGIN:GetPlayerFlags(client)
	return client:GetData("playerFlags", "")
end

function PLUGIN:HasPlayerFlags(client, flags)
	local bHasFlag = hook.Run("PlayerHasFlags", client, flags)

	if (bHasFlag == true) then
		return true
	end

	local flagList = self:GetPlayerFlags(client)

	for i = 1, #flags do
		if (flagList:find(flags[i], 1, true)) then
			return true
		end
	end

	return false
end

ix.command.Add("PlyGiveAllFlags", {
	description = "Gives a player all available flags.",
	privilege = "Helix - Manage Player Flags",
	superAdminOnly = true,
	arguments = {
		ix.type.player
	},
	OnRun = function(self, client, target)
		for flag, info in pairs(ix.flag.list) do
			PLUGIN:GivePlayerFlags(target, flag)
		end

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:Notify(client:SteamName() .. " has given " .. target:SteamName() .. " all available flags!")
			end
		end
	end
})

ix.command.Add("PlyClearFlags", {
	description = "Removes all flags from a player.",
	privilege = "Helix - Manage Player Flags",
	superAdminOnly = true,
	arguments = {
		ix.type.player
	},
	OnRun = function(self, client, target)
		PLUGIN:ClearPlayerFlags(target)

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:Notify(client:SteamName() .. " has cleared all flags of " .. target:SteamName() .. "!")
			end
		end
	end
})