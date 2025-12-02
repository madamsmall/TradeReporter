----------------------------------------------------------------------------------------------------
-- TradeReporter by Madamsmall
--
-- Reports in your chat window any items or money traded to you.
----------------------------------------------------------------------------------------------------

-- Define our main class object
TradeReporter = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceHook-2.0", "AceConsole-2.0", "AceDebug-2.0");

----------------------------------------------------------------------------------------------------
-- Addon Initializing/Enabling/Disabling
----------------------------------------------------------------------------------------------------
function TradeReporter:OnAddonLoaded()
	--Define a debug level to a level that does not completly spam the user with stuff from us
	self:SetDebugLevel(2);
	
	self.otherMoney = 0;
	self.tradePartner = "";
	self.currentMoney = "";
	self.newMoney = "";
	self.accepted = false;
	self.received = false
	self.given = false

	--Setup our chat command interface
	self:RegisterChatCommand({"/tr", "/madamtp", "/tradereporter"},
		{
			type = "group",
			args = {				
				sort = {
					type = "text",					
				}
			}
		},
		"TRADEREPORTER"
	);
end

function TradeReporter:OnEnable()	
	self:RegisterEvent("TRADE_ACCEPT_UPDATE")
	self:RegisterEvent("TRADE_SHOW")
	self:RegisterEvent("TRADE_CLOSED")	
	self:RegisterEvent("TRADE_REQUEST_CANCEL")
	self:RegisterEvent("PLAYER_MONEY")	

	DEFAULT_CHAT_FRAME:AddMessage(self:ColorMessage("TradeReporter: Loaded(v1.0.0)")) 
	self:LevelDebug(2, "TradeReporter: Loaded(v1.0.0)");
end

function TradeReporter:OnDisable()
	self:LevelDebug(1, "TradeReporter has been Disabled");
end

function TradeReporter:TRADE_SHOW()
	self.tradePartner = UnitName("NPC")
	self:LevelDebug(1, "Trade opened with " .. self.tradePartner);
end

function TradeReporter:TRADE_CLOSED()	
	self:LevelDebug(2, "TRADE_CLOSED fired");
end

function TradeReporter:TRADE_REQUEST_CANCEL()
    self:LevelDebug(2, "TRADE_REQUEST_CANCEL fired");
	self.tradePartner = nil 	
	self.accepted = false
	self.newMoney = ""
	self.currentMoney = ""
end

function TradeReporter:PLAYER_MONEY()
	self:LevelDebug(2, "PLAYER_MONEY fired");
	if self.accepted then 
		self.newMoney = GetMoney()	
		-- money traded
		local moneyChange = tonumber(self.newMoney) - (tonumber(self.currentMoney))
		if moneyChange > 0 then
			if not self.received then 
				DEFAULT_CHAT_FRAME:AddMessage(self:ColorMessage("Received in Trade from " .. self.tradePartner .. ": ") .. self:GetMoneyColorText(moneyChange)) 
			else
				DEFAULT_CHAT_FRAME:AddMessage(self:GetMoneyColorText(moneyChange))
			end			
		end
		if moneyChange < 0 then
			moneyChange = moneyChange * -1
			if not self.given then 
					DEFAULT_CHAT_FRAME:AddMessage(self:ColorMessage("Gave in Trade to " .. self.tradePartner .. ": ") .. self:GetMoneyColorText(moneyChange)) 
			else			
				DEFAULT_CHAT_FRAME:AddMessage(self:GetMoneyColorText(moneyChange))
			end
		end		
	end

	self.tradePartner = nil 	
	self.accepted = false
	self.newMoney = ""
	self.currentMoney = ""
	self.received = false
	self.given = false
end

function TradeReporter:ColorMessage(message)
	return "|cffA0B5FA" .. message .. "|r"	
end

function TradeReporter:TRADE_ACCEPT_UPDATE(p1, p2)
	self:LevelDebug(2, "TRADE_ACCEPT_UPDATE fired");
	-- both players accepted
	if p1 == 1  and p2 == 1 then
		self:LevelDebug(2, "Trade accepted with " .. self.tradePartner);		
		self.accepted = true;
		self.currentMoney = GetMoney()
		
		--- Items traded
		self.received = false
		self.given = false

		for i = 1, 6 do 
			local name, texture, quantity, quality, isUsable, enchant = GetTradeTargetItemInfo(i)
			if name then			
				local itemLink = GetTradeTargetItemLink(i)	

				if not self.received then 
					DEFAULT_CHAT_FRAME:AddMessage(self:ColorMessage("Received in Trade from " .. self.tradePartner .. ": ")) 
					self.received = true
				end
						
				DEFAULT_CHAT_FRAME:AddMessage(self:ColorMessage(quantity .. "x ") .. itemLink) 	
			end
		end

		for i = 1, 6 do 
			local name, texture, quantity, quality, isUsable, enchant = GetTradePlayerItemInfo(i)
			if name then			
				local itemLink = GetTradePlayerItemLink(i)

				if not self.given then 
					DEFAULT_CHAT_FRAME:AddMessage(self:ColorMessage("Gave in Trade to " .. self.tradePartner .. ": ")) 
					self.given = true
				end
						
				DEFAULT_CHAT_FRAME:AddMessage(self:ColorMessage(quantity .. "x ") .. itemLink) 	
			end
		end
	end
end

function TradeReporter:GetMoneyColorText(money)
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
	-- if(g>0) then text = text..g.."|cff"..GOLD.."g |r"; end
	-- if(s>0) then text = text..s.."|cff"..SILVER.."s |r"; end
	-- if(c>0) then text = text..c.."|cff"..COPPER.."c|r"; end

	text = text .. g .. "|cff" .. GOLD .. "g |r" .. sil .. "|cff" .. SILVER .. "s |r" .. cop .. "|cff" .. COPPER .. "c|r"

	return text;
end