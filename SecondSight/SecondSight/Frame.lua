-- Author      : Dimistros
-- Create Date : 1/2/2017 7:08:43 PM

function ExitButton_OnClick()
	
end

function GetMissChance()

end

function GetPlayerStats()
	local pl = "player";

	--base stats:
	playerStats = {};
	playerStats["STRENGTH"] = UnitStat(pl, 1);
	playerStats["AGILITY"] = UnitStat(pl, 2);
	playerStats["STAMINA"] = UnitStat(pl, 3);
	playerStats["INTELLECT"] = UnitStat(pl, 4);
	playerStats["SPIRIT"] = UnitStat(pl, 5);
	playerStats["ARMOR"] = UnitArmor(pl);

	--special item stats:
	--like +crit chance, cannot be read from vanilla api to my knowledge
	--using addon BonusScanner
	--playerStats["HITBONUS"] = BonusScanner:GetBonus(["TOHIT"]);
	--playerStats["CRITBONUS"] = BonusScanner:GetBonus(["CRIT"]);


	

	return playerStats;
	
end

function FrameTemplate_OnLoad()
	stats = GetPlayerStats();
	for i in stats do
		DEFAULT_CHAT_FRAME:AddMessage("BSCAN:".. BonusScanner.active);
		DEFAULT_CHAT_FRAME:AddMessage(stats[i]);
	end
end
