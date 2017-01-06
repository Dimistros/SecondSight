-- Author      : dimistros
-- Create Date : 1/5/2017 9:16:18 AM


-- BUGS:
-- dodge from agility is not tailored towards lvl

----TODO:
-- change variables to seperate document (server dependencies)
-- get UnitResistance spells total is correct, no need for scanner. armor 0 is ok, too
-- get auras from buffs :-/

DEFAULT_CHAT_FRAME:AddMessage("SecondSight_Math.lua loaded");
--SeSi = {};

-- Player Class Stats:
SeSi.ClassStats = {};
SeSi.ClassStats.PLAYER_AGI_TO_DODGE = {};
SeSi.ClassStats.PLAYER_AGI_TO_DODGE["WARRIOR"] =  0.05;
SeSi.ClassStats.PLAYER_AGI_TO_DODGE["PALADIN"] =  0.05;
SeSi.ClassStats.PLAYER_AGI_TO_DODGE["HUNTER"] =  0.03774;
SeSi.ClassStats.PLAYER_AGI_TO_DODGE["ROGUE"] =  0.06897;
SeSi.ClassStats.PLAYER_AGI_TO_DODGE["PRIEST"] =  0.05;
SeSi.ClassStats.PLAYER_AGI_TO_DODGE["SHAMAN"] =  0.05;
SeSi.ClassStats.PLAYER_AGI_TO_DODGE["MAGE"] =  0.05;
SeSi.ClassStats.PLAYER_AGI_TO_DODGE["WARLOCK"] =  0.05;
SeSi.ClassStats.PLAYER_AGI_TO_DODGE["DRUID"] =  0.05;

SeSi.ClassStats.PLAYER_BASE_DODGE = {};
SeSi.ClassStats.PLAYER_BASE_DODGE["WARRIOR"] =  0;
SeSi.ClassStats.PLAYER_BASE_DODGE["PALADIN"] =  0.75;
SeSi.ClassStats.PLAYER_BASE_DODGE["HUNTER"] =  0.64;
SeSi.ClassStats.PLAYER_BASE_DODGE["ROGUE"] =  0;
SeSi.ClassStats.PLAYER_BASE_DODGE["PRIEST"] =  3;
SeSi.ClassStats.PLAYER_BASE_DODGE["SHAMAN"] =  1.75;
SeSi.ClassStats.PLAYER_BASE_DODGE["MAGE"] =  3.25;
SeSi.ClassStats.PLAYER_BASE_DODGE["WARLOCK"] =  2;
SeSi.ClassStats.PLAYER_BASE_DODGE["DRUID"] =  0.75;


-- player formulas
SeSi.Player = {};

-- Dodge formulas
SeSi.Player.Dodge = {};

function SeSi.Player.Dodge.GetEqualLevelDodge(playerStats)
	return 
		SeSi.Player.Dodge.GetDodgeFromAgility(playerStats)
			+ SeSi.ClassStats.PLAYER_BASE_DODGE[playerStats["CLASS"]]
				+ SeSi.Player.Dodge.GetDodgeFromTalents(playerStats)
					+ SeSi.Player.Dodge.GetDodgeBuffs(playerStats)
						+ BonusScanner:GetBonus("DODGE");
end

function SeSi.Player.Dodge.GetDodgeFromAgility(playerStats)
	return playerStats["AGILITY"] * SeSi.ClassStats.PLAYER_AGI_TO_DODGE[playerStats["CLASS"]];
end

function SeSi.Player.Dodge.GetDodgeFromTalents(playerStats)
	if playerStats["CLASS"] == "ROGUE" then
		-- Lightning reflexes, second tree, third enum
		local _,_,_,_,bonus = GetTalentInfo(2, 3);
		return bonus;
	elseif playerStats["CLASS"] == "SHAMAN" then
		-- anticipation
		local _,_,_,_,bonus = GetTalentInfo(2, 9);
		return bonus;
	else
		return 0;
		end
end

function SeSi.Player.Dodge.GetDodgeBuffs(playerStats)
	if playerStats["RACE"] == "NightElf" then
		return 1;
	end
	return 0;
end

-- player parry formulas
SeSi.Player.Parry = {};

function SeSi.Player.Parry.GetEqualLevelParry(playerStats)
	if not SeSi.Player.Parry.HasParrySkill() then
		return 0;
	elseif SeSi.Player.Parry.HasParrySkill() then
		return 5 --base
			+ SeSi.Player.Parry.GetParryFromTalents(playerStats)
				+ BonusScanner:GetBonus("Parry");
		end
end

function SeSi.Player.Parry.HasParrySkill()
	local i = 1
	while i <50 do
		local spellName = GetSpellName( i, BOOKTYPE_SPELL );
		if not spellName then
			do break end
		elseif spellName == SeSi.Loc.Parry then
			return 1;
			end
		i = i + 1;
	end
	return 0;
end

function SeSi.Player.Parry.GetParryFromTalents(playerStats)
	if playerStats["CLASS"] == "HUNTER" then
		-- defelction, third tree, third enum
		local _,_,_,_,bonus = GetTalentInfo(3, 3);
		return bonus;
	elseif playerStats["CLASS"] == "PALADIN" then
		--deflection 
		local _,_,_,_,bonus = GetTalentInfo(3, 5);
		return bonus;
	elseif playerStats["CLASS"] == "ROGUE" then
		--deflection 
		local _,_,_,_,bonus = GetTalentInfo(2, 5);
		return bonus;
	elseif playerStats["CLASS"] == "WARRIOR" then
		--deflection 
		local _,_,_,_,bonus = GetTalentInfo(1, 2);
		return bonus;
	else
		return 0;
		end
end


-- get player stats

function SeSi.Player.GetPlayerStats()
	local pl = "player";
	local playerStats = {};
	--character info
	_, playerStats["CLASS"], _ = UnitClass(pl);
	playerStats["LEVEL"] = UnitLevel(pl);
	_, playerStats["RACE"] = UnitRace(pl);
	--base stats:
	playerStats["STRENGTH"] = UnitStat(pl, 1);
	playerStats["AGILITY"] = UnitStat(pl, 2);
	playerStats["STAMINA"] = UnitStat(pl, 3);
	playerStats["INTELLECT"] = UnitStat(pl, 4);
	playerStats["SPIRIT"] = UnitStat(pl, 5);
	playerStats["ARMOR"] = UnitArmor(pl);
	--special item stats:
	--like +crit chance, cannot be read from vanilla api to my knowledge
	--using addon BonusScanner
	playerStats["HITBONUS"] = BonusScanner:GetBonus("TOHIT");
	playerStats["CRITBONUS"] = SeSi.GetCritTalents(playerStats) + BonusScanner:GetBonus("CRIT");
	--defense
	playerStats["DODGEBONUS"] = BonusScanner:GetBonus("DODGE");
	playerStats["PARRYBONUS"] = BonusScanner:GetBonus("PARRY");
	playerStats["BLOCKBONUS"] = BonusScanner:GetBonus("BLOCK");
	playerStats["BLOCKVALUEBONUS"] = BonusScanner:GetBonus("BLOCKVALUE");

	--defensive
	local baseDefense, armorDefense = UnitDefense(pl);
	playerStats["DEFENSE"] = baseDefense + armorDefense;
	playerStats["ARMOR"] = nil;



	--talents
	return playerStats
end

function SeSi.GetCritTalents(playerStats)
	if playerStats["CLASS"] == "WARRIOR" then
		-- cruelty, second tree, second enum
		local _,_,_,_,critBonusTalent = GetTalentInfo(2, 2);
		return critBonusTalent;
	elseif playerStats["CLASS"] == "WARRIOR" then
		local _,_,_,_,critBonusTalent = GetTalentInfo(2, 2);
		return critBonusTalent;
	else
		return 0;
		end
end


SeSi.Target = {};

function SeSi.Target.GetTargetStats()
	local tr = "target";
	local trStat = {};
	trStat["LEVEL"] = UnitLevel(tr);
	trStat["ARMOR"] = UnitArmor(tr);
	trStat["ATTACKPOWER"] = UnitAttackPower(tr);
	--damage caused:
	local lowDmg, hiDmg, offlowDmg, offhiDmg, posBuff, negBuff, percentmod = UnitDamage(tr);
	trStat["MHLOWDMG"] = lowDmg;
	trStat["MHHIDMG"] = hiDmg;
	trStat["OHLOWDMG"] = offlowDmg;
	trStat["OHHIDMG"] = offhiDmg;
	trStat["DMGPOSBUFF"] = posBuff;
	trStat["DMGNEGBUFF"] = negBuff;
	trStat["DMGPERCENTMOD"] = percentmod;
	local mainSpeed, offSpeed = UnitAttackSpeed(tr);
	trStat["MHSPEED"] = mainSpeed;
	trStat["OHSPEED"] = offSpeed;

	return trStat;
end

-----------------------------
SeSi.TEST = {};

function SeSi.TEST.UnitArmorTEST()
	local pl = "player";
	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor(pl);
	local values = {};
	
	values["base"] = base;
	values["effectiveArmor"] = effectiveArmor;
	values["armor"] = armor;
	values["posBuff"] = posBuff;
	values["negBuff"] = negBuff;
	return values;
end

function SeSi.TEST.UnitResistanceTEST(i)
	DEFAULT_CHAT_FRAME:AddMessage(i);
	local pl = "player";
	local base, total, bonus, minus = UnitResistance(pl , i);
	local values = {};
	values["base"] = base;
	values["total"] = total;
	values["bonus"] = bonus;
	values["minus"] = minus;
	return values;
end