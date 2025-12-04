----------------------------------------------------------------------------------------------------
-- TradeReporter by Madamsmall
--
-- Reports in your chat window any items or money traded to you.
----------------------------------------------------------------------------------------------------

TradeReporter = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceHook-2.0", "AceConsole-2.0", "AceDebug-2.0");

tradePartner = "";	
given = false
received = false	
accepted = false
recM = ""
gaveM = ""
playerItemName = {}
playerItemQuantity = {}
targetItemName = {}
targetItemQuantity = {}
playerItemLink = {}
targetItemLink = {}

function TR_OnEvent()
	if(event == "UI_ERROR_MESSAGE") then
		if(arg1 == "Inventory is full.") then			
			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("Unable to trade: " .. arg1))		
		end
	elseif(event == "UI_INFO_MESSAGE") then
		if(arg1 == ERR_TRADE_CANCELLED) then
			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: " .. arg1))
		elseif(arg1 == ERR_TRADE_COMPLETE) then
			ReportToChat()
			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: " .. arg1))
		end
	elseif(event == "TRADE_SHOW") then
		tradePartner = UnitName("NPC")
	elseif(event == "TRADE_REQUEST_CANCEL") then
		ResetVars()
	elseif(event == "TRADE_ACCEPT_UPDATE") then
		if arg1 == 1 and arg2 == 1 then
			accepted = true
			recM = tonumber(GetTargetTradeMoney())
			gaveM = tonumber(GetPlayerTradeMoney())

			for i = 1, 6 do 
				if GetTradePlayerItemInfo(i) then					
					local name, texture, quantity, quality, isUsable, enchant = GetTradePlayerItemInfo(i)
					playerItemName[i] = name
					playerItemQuantity[i] = quantity
					playerItemLink[i] = GetTradePlayerItemLink(i)
				end				
			end

			for i = 1, 6 do 
				if GetTradeTargetItemInfo(i) then					
					local name, texture, quantity, quality, isUsable, enchant = GetTradeTargetItemInfo(i)
					targetItemName[i] = name
					targetItemQuantity[i] = quantity
					targetItemLink[i] = GetTradeTargetItemLink(i)
				end				
			end
		else 
			accepted = false
		end
	end
end

function TR_OnLoad(self)
	self:RegisterEvent("UI_ERROR_MESSAGE")	
	self:RegisterEvent("UI_INFO_MESSAGE")	
	self:RegisterEvent("TRADE_ACCEPT_UPDATE")
	self:RegisterEvent("TRADE_SHOW")
	self:RegisterEvent("TRADE_CLOSED")	
	self:RegisterEvent("TRADE_REQUEST_CANCEL")
	self:RegisterEvent("PLAYER_MONEY")			
	self:RegisterEvent("PLAYER_TRADE_MONEY")
	self:RegisterEvent("TRADE_MONEY_CHANGED")
end

function OnEnable()				
	DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TradeReporter: Loaded(v1.0.0)")) 
end
 
function ResetVars()
	tradePartner = "" 	
	given = false
	received = false
	accepted = false
	recM = ""
	gaveM = ""
	playerItemName = {}
	playerItemQuantity = {}
	targetItemName = {}
	targetItemQuantity = {}
	playerItemLink = {}
	targetItemLink = {}
end

function ReportToChat()	
	for i = 1, 6 do 							
		if targetItemName[i] then			
			local itemLink = targetItemLink[i]
			local quantity = targetItemQuantity[i]

			if not received then 
				DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Received in Trade from " .. tradePartner .. ": ")) 
				received = true
			end
					
			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: " .. quantity .. "x ") .. itemLink) 	
		end
	end  
	if recM and recM ~= "" and recM ~= 0 then
		if not received then 
				DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Received in Trade from " .. tradePartner .. ": " .. GetMoneyColorText(recM))) 
				received = true
		else
			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: ") .. GetMoneyColorText(recM))
		end 
	end 

	for i = 1, 6 do 
		if playerItemName[i] then
			local itemLink = playerItemLink[i]
			local quantity = playerItemQuantity[i]		
			if not given then 
				DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Gave in Trade to " .. tradePartner .. ": ")) 
				given = true
			end
					
			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: " .. quantity .. "x ") .. itemLink) 				
		end
	end
	if gaveM and gaveM ~= "" and gaveM ~= 0 then
		if not given then 
				DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: Gave in Trade to " .. tradePartner .. ": " .. GetMoneyColorText(gaveM))) 
				given = true
		else
			DEFAULT_CHAT_FRAME:AddMessage(ColorMessage("TR: ") .. GetMoneyColorText(gaveM))
		end
	end 		
	ResetVars()		
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

local frame = CreateFrame("Frame", "TradeReporter Addon Frame");
frame:SetScript("OnEvent", TR_OnEvent);
TR_OnLoad(frame);