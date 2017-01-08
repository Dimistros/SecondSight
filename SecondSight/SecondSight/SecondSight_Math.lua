-- Author      : dimistros
-- Create Date : 1/5/2017 9:16:18 AM

-- DEPENDENCIES
-- BonusScanner
-- SuperMacro

--DETECTED SERVERBUGS:
--melee attacks with a fishing pole use your fishing skills instead of your unarmed skill

-- BUGS:
-- dodge from agility is not tailored towards lvl

----TODO:
-- get auras from buffs :-/
-- create flags + reset function for breached tresholds like i.e. armor cap, 1% min resist for casters -- warn the player!
-- add rogue crit talent with weapon specialization dagger and fist: http://wowprogramming.com/docs/api/GetItemInfo and http://wowprogramming.com/docs/api/GetAuctionItemSubClasses
-- add warrior crit bonus talent axe
DEFAULT_CHAT_FRAME:AddMessage("SecondSight_Math.lua loaded");

-- player formulas
SeSi.Player = {};

-- player is attacking table
function SeSi.Player.GetAttackingTable(playerStats, targetStats, hand)
	local table = {};
	table["MISS"] = SeSi.Player.MeleeMiss.AdaptToDefense(playerStats, targetStats, hand);
	table["DODGE"] = SeSi.Target.GetDodge(playerStats, targetStats, hand);
	return table;
end 

-- player attacking enemy 
SeSi.Player.MeleeMiss = {};

function SeSi.Player.MeleeMiss.AdaptToDefense(playerStats, targetStats, hand)
	local chance = SeSi.Player.MeleeMiss.GetEqualLevelMiss(playerStats); 

	if targetStats["IS_PLAYER"] == 1 then
		return chance; -- player weapon 
	end

	local targetDefense = 5 * targetStats["LEVEL"];
	local playerWeaponSkill;

	if SeSi.Player.Feral.IsFeralForm() == 1 then
		playerWeaponSkill = 5 * playerStats["LEVEL"];
	else
		playerWeaponSkill = playerStats[hand];
	end

	local difference = targetDefense - playerWeaponSkill;
	local factor = SeSi.ServerValues.Player.MissChancePerDefenseSmall;

	if difference > 10 then
		local factor = SeSi.ServerValues.Player.MissChancePerDefenseBig;
		chance = chance + SeSi.ServerValues.Player.MissChancePerDefenseBonus;
	end
	
	chance = chance + difference * factor;
	return max(0,chance);
end

function SeSi.Player.MeleeMiss.GetEqualLevelMiss(playerStats)
	local chance = SeSi.ServerValues.Player.BaseMissChance 
		- SeSi.Player.MeleeMiss.GetMissReductionFromTalents(playerStats) 
			- BonusScanner:GetBonus("TOHIT");
	if playerStats["DUAL_WIELDING"] == 1 then
		chance = chance + SeSi.ServerValues.Player.DualWieldMissBonus;
	end
	return max(chance, 0);
end

function SeSi.Player.MeleeMiss.GetMissReductionFromTalents(playerStats)
	if playerStats["CLASS"] == "HUNTER" then
		-- surefooted, third tree, third enum
		local _,_,_,_,bonus = GetTalentInfo(3, 11);
		return bonus;
	elseif playerStats["CLASS"] == "PALADIN" then
		--precision 
		local _,_,_,_,bonus = GetTalentInfo(2, 3);
		return bonus;
	elseif playerStats["CLASS"] == "ROGUE" then
		--precision 
		local _,_,_,_,bonus = GetTalentInfo(2, 6);
		return bonus;
	elseif playerStats["CLASS"] == "SHAMAN" then
		--Nature's Guidance 
		local _,_,_,_,bonus = GetTalentInfo(3, 6);
		return bonus;
	else
		return 0;
		end
end

-- Dodge formulas
SeSi.Player.Dodge = {};

function SeSi.Player.Dodge.AdaptToDefense(playerStats, targetStats, hand)
	local chance = SeSi.Player.Dodge.GetEqualLevelDodge(playerStats)
	local targetDefense = 5 * targetStats["LEVEL"];
	local playerWeaponSkill;

	if SeSi.Player.Feral.IsFeralForm() == 1 then
		playerWeaponSkill = 5 * playerStats["LEVEL"];
	else
		playerWeaponSkill = playerStats[hand];
	end

	local difference = targetDefense - playerWeaponSkill;
	local factor = SeSi.ServerValues.Player.DodgeChancePerDefenseSmall;

	if difference > 0 then
		factor = SeSi.ServerValues.Player.DodgeChancePerDefenseBig;
	end
	chance = chance + factor * difference;
	return max(0,chance);
end

function SeSi.Player.Dodge.GetEqualLevelDodge(playerStats)
	return 
		SeSi.Player.Dodge.GetDodgeFromAgility(playerStats)
			+ SeSi.ServerValues.Player.PLAYER_BASE_DODGE[playerStats["CLASS"]]
				+ SeSi.Player.Dodge.GetDodgeFromTalents(playerStats)
					+ SeSi.Player.Dodge.GetDodgeRacialBonus(playerStats)
						+ BonusScanner:GetBonus("DODGE");
end

function SeSi.Player.Dodge.GetDodgeFromAgility(playerStats)
	return playerStats["AGILITY"] * SeSi.ServerValues.Player.PLAYER_AGI_TO_DODGE[playerStats["CLASS"]];
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

function SeSi.Player.Dodge.GetDodgeRacialBonus(playerStats)
	if playerStats["RACE"] == "NightElf" then
		return 1;
	end
	return 0;
end

-- player parry formulas
SeSi.Player.Parry = {};

function SeSi.Player.Parry.GetEqualLevelParry(playerStats)
	if (SeSi.Player.Parry.HasParrySkill() == 0) then
		return 0;
	else
		return SeSi.ServerValues.Player.BaseParryChance --base
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
		-- deflection, third tree, third enum
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

-- player crit
SeSi.Player.MeleeCrit = {};
function SeSi.Player.MeleeCrit.GetCritFromTalents(playerStats)	
	if playerStats["CLASS"] == "DRUID" and SeSi.Player.Feral.IsFeralForm() == 1 then
		-- sharpened claws, second tree, 8 enum
		local _,_,_,_,bonus = GetTalentInfo(2, 8);
		return 2 * bonus; -- each point gives 2 crit
	elseif playerStats["CLASS"] == "HUNTER" then
		-- killer instinct, third tree, 13 enum
		local _,_,_,_,bonus = GetTalentInfo(3, 13);
		return bonus;
	elseif playerStats["CLASS"] == "PALADIN" then
		--conviction 
		local _,_,_,_,bonus = GetTalentInfo(3, 7);
		return bonus;
	elseif playerStats["CLASS"] == "ROGUE" then
		--malice 
		local _,_,_,_,bonus = GetTalentInfo(1, 3);
		return bonus;
	elseif playerStats["CLASS"] == "SHAMAN" then
		--thundering strikes 
		local _,_,_,_,bonus = GetTalentInfo(2, 4);
		return bonus;
	elseif playerStats["CLASS"] == "WARRIOR" then
		--cruelty 
		local _,_,_,_,bonus = GetTalentInfo(2, 2);
		return bonus;
	else
		return 0;
		end
end

SeSi.Player.Feral = {};
function SeSi.Player.Feral.IsFeralForm()
	if buffed("Bear Form") or buffed("Cat Form") or buffed("Dire Bear Form") or buffed("Aquatic Form") or buffed("Travel Form") then
		return 1;
	end
	return 0;
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
	_, playerStats["ARMOR"] = UnitResistance(pl, 0); --physical
	_, playerStats["HOLY_RES"] = UnitResistance(pl, 1); 
	_, playerStats["FIRE_RES"] = UnitResistance(pl, 2);
	_, playerStats["NATURE_RES"] = UnitResistance(pl, 3);
	_, playerStats["FROST_RES"] = UnitResistance(pl, 4);
	_, playerStats["SHADOW_RES"] = UnitResistance(pl, 5);
	_, playerStats["ARCANE_RES"] = UnitResistance(pl, 6);

	-- weapon skill
	local mainBase, mainMod, offBase, offMod = UnitAttackBothHands(pl);
	playerStats["WEAPONSKILL_MH"] = mainBase + mainMod;
	playerStats["WEAPONSKILL_OH"] = offBase + offMod;
	-- find out if player is dual wielding
	local mainSpeed, offSpeed = UnitAttackSpeed(pl);
	playerStats["SPEED_MH"] = mainSpeed;
	playerStats["SPEED_OH"] = offSpeed;
	if offSpeed == nil then
		playerStats["DUAL_WIELDING"] = 0;
	else
		playerStats["DUAL_WIELDING"] = 1;
	end

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

	if UnitIsPlayer(tr) then
		trStat["IS_PLAYER"] = 1;
	else 
		trStat["IS_PLAYER"] = 0;
	end
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

function SeSi.Target.GetDodge(playerStats, targetStats, hand)
	if targetStats["IS_PLAYER"] == 1 then
		return 0; -- can't compute for players since dodge is based on agi and talents which cannot be read
	end
	local chance = SeSi.ServerValues.Target.BaseDodgeChance;
	local targetDefense = 5 * targetStats["LEVEL"];
	local playerWeaponSkill;

	if SeSi.Player.Feral.IsFeralForm() == 1 then
		playerWeaponSkill = 5 * playerStats["LEVEL"];
	else
		playerWeaponSkill = playerStats[hand];
	end

	local difference = targetDefense - playerWeaponSkill;
	local factor = SeSi.ServerValues.Target.DodgeChancePerDefenseSmall;

	if difference > 10 then
		local factor = SeSi.ServerValues.Target.DodgeChancePerDefenseBig
	end
	
	chance = chance + difference * factor;
	return max(0,chance);
end

function SeSi.Target.GetParry(playerStats, targetStats, hand)
	if targetStats["IS_PLAYER"] == 1 then
		return 0; -- can't compute for players since dodge is based on agi and talents which cannot be read
	end
	local chance = SeSi.ServerValues.Target.BaseDodgeChance;
	local targetDefense = 5 * targetStats["LEVEL"];
	local playerWeaponSkill;

	if SeSi.Player.Feral.IsFeralForm() == 1 then
		playerWeaponSkill = 5 * playerStats["LEVEL"];
	else
		playerWeaponSkill = playerStats[hand];
	end

	local difference = targetDefense - playerWeaponSkill;
	local factor = SeSi.ServerValues.Target.DodgeChancePerDefenseSmall;

	if difference > 10 then
		local factor = SeSi.ServerValues.Target.DodgeChancePerDefenseBig
	end
	
	chance = chance + difference * factor;
	return max(0,chance);
end
-----------------------------
SeSi.TEST = {};

--function SeSi.TEST.UnitArmorTEST() -- UnitResistanceTEST is better
--	local pl = "player";
--	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor(pl);
--	local values = {};
	
--	values["base"] = base;
--	values["effectiveArmor"] = effectiveArmor;
--	values["armor"] = armor;
--	values["posBuff"] = posBuff;
--	values["negBuff"] = negBuff;
--	return values;
--end

--function SeSi.TEST.UnitResistanceTEST(i) -- using
--	DEFAULT_CHAT_FRAME:AddMessage(i);
--	local pl = "player";
--	local base, total, bonus, minus = UnitResistance(pl , i);
--	local values = {};
--	values["base"] = base;
--	values["total"] = total;
--	values["bonus"] = bonus;
--	values["minus"] = minus;
--	return values;
--end

--function SeSi.TEST.GetCombatRating() -- not working
--	local rating = GetSkillLineInfo(skillIndex);
--	local values = {};
--	values["rating"] = rating;
--	return values;
--end

--function SeSi.TEST.UnitAttackBothHandsTEST(unit)
--	local mainBase, mainMod, offBase, offMod = UnitAttackBothHands(unit);
--	local values = {};
--	values["mainBase"] = mainBase;
--	values["mainMod"] = mainMod;
--	values["offBase"] = offBase;
--	values["offMod"] = offMod;
--	return values;

--end

function SeSi.TEST.UnitBuff()
	return UnitIsPlayer('target')
	--DEFAULT_CHAT_FRAME:AddMessage(buffed("Cat Form", 'player'));
	--DEFAULT_CHAT_FRAME:AddMessage(buffed("Bear Form", 'player'));
	--DEFAULT_CHAT_FRAME:AddMessage(buffed("Dire Bear Form", 'player'));
	
	
end