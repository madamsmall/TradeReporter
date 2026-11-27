---@diagnostic disable: create-global
----------------------------------------------------------------------------------------------------
-- TradeReporter by Madamsmall
--
-- Reports in your chat window any items or money traded to you.
----------------------------------------------------------------------------------------------------

TradePartner = ""
Given = false
Received = false
Accepted = false
RecM = ""
GaveM = ""
PlayerItemName = {}
PlayerItemQuantity = {}
PlayerEnchantName = {}
TargetItemName = {}
TargetItemQuantity = {}
TargetEnchantName = {}
PlayerItemLink = {}
TargetItemLink = {}

function TR_OnLoad(TradeReporter)
	TradeReporter:RegisterEvent("UI_ERROR_MESSAGE")
	TradeReporter:RegisterEvent("UI_INFO_MESSAGE")
	TradeReporter:RegisterEvent("TRADE_ACCEPT_UPDATE")
	TradeReporter:RegisterEvent("TRADE_SHOW")
	TradeReporter:RegisterEvent("TRADE_CLOSED")
	TradeReporter:RegisterEvent("TRADE_REQUEST_CANCEL")
	TradeReporter:RegisterEvent("PLAYER_MONEY")
	TradeReporter:RegisterEvent("PLAYER_TRADE_MONEY")
	TradeReporter:RegisterEvent("TRADE_MONEY_CHANGED")
	DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TradeReporter: Loaded v2.0.0 (Forever)"))
end

-- /tr and /tradereporter
SLASH_TR1 = "/tr"
SLASH_TR2 = "/tradereporter"
SlashCmdList["TR"] = function(msg)
	DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TradeReporter: Loaded v1.0.0 (Forever)"))
end

function ResetVars()
	TradePartner = ""
	Given = false
	Received = false
	Accepted = false
	RecM = ""
	GaveM = ""
	PlayerItemName = {}
	PlayerItemQuantity = {}
	TargetEnchantName = {}
	PlayerEnchantName = {}
	TargetItemName = {}
	TargetItemQuantity = {}
	PlayerItemLink = {}
	TargetItemLink = {}
end

function ReportToChat()
	-- report items received from target to player
	for i = 1, 6 do
		if TargetItemName[i] then
			local itemLink = TargetItemLink[i]
			local quantity = TargetItemQuantity[i]
			-- print the header message for a trade if it hasn't been printed yet
			if not Received then
				DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Received in Trade from " .. TradePartner .. ": "))
				Received = true
			end

			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: " .. quantity .. "x ") .. itemLink)
		end
	end
	-- report enchant received from target to player
	if PlayerEnchantName[7] then
		local itemLink = PlayerItemLink[7]
		local enchantName = PlayerEnchantName[7]
		if not Received then
				DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Received in Trade from " .. TradePartner .. ": "))
				Received = true
		end

		DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Enchant [") .. enchantName .. ColorMessage("] applied to ") .. itemLink)
	end
	-- report money received from target to player
	if RecM and RecM ~= "" and RecM ~= 0 then
		-- print the header message for a trade if it wasn't printed before items were listed
		if not Received then
				DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Received in Trade from " .. TradePartner .. ": " .. GetMoneyColorText(RecM)))
				Received = true
		else
			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: ") .. GetMoneyColorText(RecM))
		end
	end

	-- report items given from player to target
	for i = 1, 6 do
		if PlayerItemName[i] then
			local itemLink = PlayerItemLink[i]
			local quantity = PlayerItemQuantity[i]
			if not Given then
				DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Gave in Trade to " .. TradePartner .. ": "))
				Given = true
			end

			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: " .. quantity .. "x ") .. itemLink)
		end
	end
	-- report enchant given from player to target
	if TargetEnchantName[7] then
		local itemLink = TargetItemLink[7]
		local enchantName = TargetEnchantName[7]
		if not Given then
				DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Gave in Trade to " .. TradePartner .. ": "))
				Given = true
		end

		DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Enchant [") .. enchantName .. ColorMessage("] applied to ") .. itemLink)
	end
	-- report money given from player to target
	if GaveM and GaveM ~= "" and GaveM ~= 0 then
		if not Given then
				DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Gave in Trade to " .. TradePartner .. ": " .. GetMoneyColorText(GaveM)))
				Given = true
		else
			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: ") .. GetMoneyColorText(GaveM))
		end
	end

	ResetVars()
end

local function eventHandler(self, event, arg1, arg2)
	local message = arg2
	if(message == ERR_TRADE_BAG_FULL or message == ERR_TRADE_TARGET_BAG_FULL) then
		DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Error - " .. message))
	elseif(message == ERR_TRADE_COMPLETE) then
			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: " .. message))
			ReportToChat()
	elseif(message == ERR_INITIATE_TRADE_S or message == ERR_TRADE_REQUEST_S) then
		DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: " .. message))
		TradePartner = TradeFrameRecipientNameText:GetText()
	elseif(message == ERR_TRADE_CANCELLED) then
		DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: " .. message))
		ResetVars()
	elseif(event == "TRADE_ACCEPT_UPDATE") then
		TradePartner = TradeFrameRecipientNameText:GetText()
		if arg1 == 1 then
			Accepted = true
			RecM = tonumber(GetTargetTradeMoney())
			GaveM = tonumber(GetPlayerTradeMoney())

			-- Items being traded from player
			for i = 1, 6 do
				if GetTradePlayerItemInfo(i) then
					local name, texture, quantity, quality, isUsable, enchantApplied = GetTradePlayerItemInfo(i)
					PlayerItemName[i] = name
					PlayerItemQuantity[i] = quantity
					PlayerItemLink[i] = GetTradePlayerItemLink(i)
				end
			end
			-- Items being traded to player
			for i = 1, 6 do
				if GetTradeTargetItemInfo(i) then
					local name, texture, quantity, quality, isUsable, enchantApplied = GetTradeTargetItemInfo(i)
					TargetItemName[i] = name
					TargetItemQuantity[i] = quantity
					TargetItemLink[i] = GetTradeTargetItemLink(i)
				end
			end
			-- Enchants being applied by target to player (item in player side slot 7)
			if GetTradePlayerItemInfo(7) then
					local name, texture, quantity, quality, enchantReceived = GetTradePlayerItemInfo(7)
					PlayerItemName[7] = name
					PlayerEnchantName[7] = enchantReceived
					PlayerItemLink[7] = GetTradePlayerItemLink(7)
				end
			-- Enchants being applied by player to target (item in target side slot 7)
			if GetTradeTargetItemInfo(7) then
					local name, texture, quantity, quality, isUsable, enchantGiven = GetTradeTargetItemInfo(7)
					TargetItemName[7] = name
					TargetEnchantName[7] = enchantGiven
					TargetItemLink[7] = GetTradeTargetItemLink(7)
				end
		else
			Accepted = false
		end
	end
end

function ColorMessage(message)
	return "|cffA0B5FA" .. message .. "|r"
end

function GetMoneyColorText(money)
	if not money then return end

	local GOLD="ffd100"
	local SILVER="e6e6e6"
	local COPPER="c8602c"

	local g = math.floor( money / 1e4 );
	local s = math.floor( money / 100 ) - g*100 ;
	local c = money - ( g * 100 + s ) * 100;

	local sil = ""
	if s < 10 then sil = "0" .. s
	else sil = "" .. s
	end

	local cop = ""
	if c < 10 then
		cop = "0" .. c
	else
		cop = "" .. c
	end

	local text = ""

	text = text .. g .. "|cff" .. GOLD .. "g |r" .. sil .. "|cff" .. SILVER .. "s |r" .. cop .. "|cff" .. COPPER .. "c|r"

	return text;
end

local frame = CreateFrame("Frame", "TradeReporter");
TR_OnLoad(frame);
frame:SetScript("OnEvent", eventHandler);