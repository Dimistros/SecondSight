-- Author      : dimistros
-- Create Date : 1/5/2017 9:16:18 AM

-- DEPENDENCIES
-- BonusScanner
-- SuperMacro

--DETECTED SERVERBUGS:
--melee attacks with a fishing pole use your fishing skills instead of your unarmed skill
-- paladin is neither punished nor changed in any other way in glance factor calculation. According to wow wiki (http://wowwiki.wikia.com/wiki/Weapon_skill?oldid=349241), all melee classes should be treated equally. Shamans are treated as casters i.e.

-- BUGS:
-- dodge from agility is not tailored towards lvl

----TODO:
-- target parry is equal to dodge: wrong!
-- get auras from buffs :-/
-- create flags + reset function for breached tresholds like i.e. armor cap, 1% min resist for casters -- warn the player!

DEFAULT_CHAT_FRAME:AddMessage("SecondSight_Math.lua loaded");

SeSi.Settings = {};
SeSi.Settings.AttackingFromBehind = 0;

function SeSi.Report(table)

	DEFAULT_CHAT_FRAME:AddMessage("----------------");
	DEFAULT_CHAT_FRAME:AddMessage("Table: " .. table["INFO"]);
	DEFAULT_CHAT_FRAME:AddMessage("Miss: " .. table["MISS"]);
	DEFAULT_CHAT_FRAME:AddMessage("Dodge: " .. table["DODGE"]);
	DEFAULT_CHAT_FRAME:AddMessage("Parry: " .. table["PARRY"]);
	DEFAULT_CHAT_FRAME:AddMessage("Glancing: " .. table["GLANCING"]);
	DEFAULT_CHAT_FRAME:AddMessage("Block: " .. table["BLOCK"]);
end

-- player formulas
SeSi.Player = {};

-- player is attacking table
function SeSi.Player.GetAttackingTable(playerStats, targetStats, hand)
	local table = {};
	table["INFO"] = "Player Attacking Mob table:"
	table["MISS"] = SeSi.Player.MeleeMiss.AdaptToDefense(playerStats, targetStats, hand);
	table["DODGE"] = SeSi.Target.GetDodge(playerStats, targetStats, hand);
	table["PARRY"] = SeSi.Target.GetParry(playerStats, targetStats, hand);
	table["GLANCING"] = SeSi.Player.GetGlanceChance(playerStats, targetStats, hand);
	table["BLOCK"] = SeSi.Target.GetBlock(playerStats, targetStats, hand);
	
	return table;
end 

-- player attacking enemy 
SeSi.Player.MeleeMiss = {};

function SeSi.Player.MeleeMiss.AdaptToDefense(playerStats, targetStats, hand)
	hand = "WEAPONSKILL_".. hand;
	local chance = SeSi.Player.MeleeMiss.GetEqualLevelMiss(playerStats); 

	--if targetStats["IS_PLAYER"] == 1 then
	--	return chance; -- player weapon 
	--end --not correct on Elysium at least, weapon skill has an effect in pvp

	local targetDefense = 5 * targetStats["LEVEL"];
	local playerWeaponSkill;

	if SeSi.Player.Feral.IsFeralForm() == 1 then
		playerWeaponSkill = 5 * playerStats["LEVEL"];
	else
		playerWeaponSkill = playerStats[hand];
	end

	local difference = targetDefense - playerWeaponSkill;
	local factor = SeSi.ServerValues.Player.MissChancePerDefenseBase;

	if difference > 0 then
		factor = SeSi.ServerValues.Player.MissChancePerDefenseSmall;
		if difference > 10 then
			factor = SeSi.ServerValues.Player.MissChancePerDefenseBig;
			chance = chance + SeSi.ServerValues.Player.MissChancePerDefenseBonus;
		end
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
	hand = "WEAPONSKILL_".. hand;
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

function SeSi.Player.GetGlanceChance(playerStats, targetStats, hand)
	hand = "WEAPONSKILL_".. hand;
	local level = targetStats["LEVEL"];
	local mobDefense = 5 * targetStats["LEVEL"];
	local playerWeaponSkill;

	if SeSi.Player.Feral.IsFeralForm() == 1 then
		playerWeaponSkill = 5 * playerStats["LEVEL"];
	else
		playerWeaponSkill = min(5 * playerStats["LEVEL"], playerStats[hand]); -- cannot increase weapon skill over cap for this
	end

	local chance;
	if playerStats["CLASS"] == "WARLOCK" or playerStats["CLASS"] == "MAGE" or playerStats["CLASS"] == "PRIEST" then
		--DEFAULT_CHAT_FRAME:AddMessage("Caster detected");
		if level < 30 then
			chance = level + (mobDefense - playerWeaponSkill)*2;
		else
			chance = 30 + (mobDefense - playerWeaponSkill)*2;
		end
	else
		chance = 10 + (mobDefense - playerWeaponSkill)*2;
	end
	return max(0, min(chance, 100));
end

--function SeSi.Player.GetGlanceFactor(playerStats, targetStats, hand)
	--hand = "WEAPONSKILL_".. hand;
--	local level = targetStats["LEVEL"];
--	local mobDefense = 5 * targetStats["LEVEL"];
--	local playerWeaponSkill;

--	if SeSi.Player.Feral.IsFeralForm() == 1 then
--		playerWeaponSkill = 5 * playerStats["LEVEL"];
--	else
--		playerWeaponSkill =  playerStats[hand]; 
--	end

--	local baseLowEnd = 1.3;
--	local baseHighEnd = 1.2;
--	if playerStats["CLASS"] == "WARLOCK" 
--		or playerStats["CLASS"] == "MAGE" 
--			or playerStats["CLASS"] == "PRIEST" 
--				or playerStats["CLASS"] == "SHAMAN"
--					or playerStats["CLASS"] == "DRUID" then
--						baseLowEnd  -= 0.7;
--						baseHighEnd -= 0.3;

--					end

--	local maxLowEnd = 0.6;
--	if playerStats["CLASS"] == "WARRIOR" 
--		or playerStats["CLASS"] == "ROGUE" then
--			maxLowEnd = 0.91;
--		end

--	local diff = (mobDefense - playerWeaponSkill);
--	local lowEnd  = max(0.01, baseLowEnd - (0.05f * diff));
--	local highEnd = max(0.2, min(baseHighEnd - (0.03f * diff), 0.99));

--	return max(0, min( (lowEnd + highEnd)/2, 1));
--end


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
	playerStats["CRITBONUS"] = BonusScanner:GetBonus("CRIT");
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
	playerStats["WEAPONTYPE_MH"] = SeSi.Player.GetWeaponType("MainHandSlot");
	playerStats["WEAPONTYPE_OH"] = SeSi.Player.GetWeaponType("SecondaryHandSlot");

	return playerStats
end

SeSi.Player.MeleeCrit = {};

--function SeSi.Player.MeleeCrit.GetEqualLevelMeleeCrit(playerStats, hand)
--	return SeSi.Player.MeleeCrit.GetMeleeCritTalents(playerStats, hand)
--		+ playerStats["CRITBONUS"]
--			+ SeSi.Player.MeleeCrit.GetMeleeCritFromAgi(playerStats)
--				+ SeSi.Player.MeleeCrit.GetMeleeCritFromBuffs();
--end

function SeSi.Player.MeleeCrit.GetMeleeCritFromAgi(playerStats)
	return 0;
end

function SeSi.Player.MeleeCrit.GetMeleeCritFromBuffs()
	return 0;
end

--function SeSi.Player.MeleeCrit.GetMeleeCritTalents(playerStats, hand)
--  hand = "WEAPONTYPE_".. hand;
--	local totalBonus = 0;

--	if playerStats["CLASS"] == "DRUID" then
--		if buffed("Bear Form") or buffed("Cat Form") or buffed("Dire Bear Form") then
--			local _,_,_,_,critBonusTalent = 2 * GetTalentInfo(2, 8); --sharpened claws only, leader of the pack is a buff and is treated accordingly
--		end
--		return critBonusTalent;
--	else if playerStats["CLASS"] == "HUNTER" then
--		-- Killer Instinct, third tree, second enum
--		local _,_,_,_,critBonusTalent = GetTalentInfo(3, 13);
--		return critBonusTalent;
--	else if playerStats["CLASS"] == "PALADIN" then
--		-- Conviction, third tree, 7th enum
--		local _,_,_,_,critBonusTalent = GetTalentInfo(3, 7);
--		return critBonusTalent;
--	else if playerStats["CLASS"] == "ROGUE" then
--		-- Malice, first tree, 3th enum
--		local _,_,_,_,critBonusTalent = GetTalentInfo(1, 3);
--		totalBonus += critBonusTalent;
--		--Dagger Special
--		if playerStats[hand] == "Daggers" then
--			local _,_,_,_,critBonusTalent = GetTalentInfo(2, 11); 
--			totalBonus += critBonusTalent;
--		end
--		--Fist Weapon Special
--		if playerStats[hand] == "Fist Weapons" then
--			local _,_,_,_,critBonusTalent = GetTalentInfo(2, 16); 
--			totalBonus += critBonusTalent;
--		end
--		return totalBonus;
--	else if playerStats["CLASS"] == "SHAMAN" then
--		-- thundering strikes, second tree, 4th enum
--		local _,_,_,_,critBonusTalent = GetTalentInfo(2, 4);
--		return critBonusTalent;
--	else if playerStats["CLASS"] == "WARRIOR" then
--		-- cruelty, second tree, second enum
--		local _,_,_,_,critBonusTalent = GetTalentInfo(2, 2);
--		totalBonus += critBonusTalent;
--		--axe specialization
--		if playerStats[hand] == "One-Handed Axes" or SeSi.Player.GetWeaponType(hand) == "Two-Handed Axes" then
--			local _,_,_,_,critBonusTalent = GetTalentInfo(2, 11); 
--			totalBonus += critBonusTalent;
--		end
--		-- pole spec
--		if playerStats[hand] == "Polearms" then
--			local _,_,_,_,critBonusTalent = GetTalentInfo(2, 16); 
--			totalBonus += critBonusTalent;
--		end
--		return totalBonus;
--	else
--		return 0;
--	end
--end

function SeSi.Player.GetWeaponType(slot)
	local itemLink = GetInventoryItemLink("player",GetInventorySlotInfo(slot))
	if not(itemLink == nil) then
		local _, _, itemCode = strfind(itemLink, "(%d+):")
		local _, _, _, _, _, itemType = GetItemInfo(itemCode)
		return itemType;
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

	if difference > SeSi.ServerValues.Target.DodgeChanceFormulaThreshold then
		factor = SeSi.ServerValues.Target.DodgeChancePerDefenseBig;
	end
	
	chance = chance + difference * factor;
	return max(0,chance);
end

function SeSi.Target.GetParry(playerStats, targetStats, hand)
	if (targetStats["IS_PLAYER"] == 1) then
		return "unknown"; -- can't compute for players since dodge is based on agi and talents which cannot be read
	end

	if (SeSi.Settings.AttackingFromBehind == 1) then
		return 0; -- can't parry from behind
	end

	local chance = SeSi.ServerValues.Target.BaseParryChance
	local targetDefense = 5 * targetStats["LEVEL"];
	local playerWeaponSkill;

	if SeSi.Player.Feral.IsFeralForm() == 1 then
		playerWeaponSkill = 5 * playerStats["LEVEL"];
	else
		playerWeaponSkill = playerStats[hand];
	end

	local difference = targetDefense - playerWeaponSkill;
	local factor = SeSi.ServerValues.Target.ParryChancePerDefenseNormal;

	if difference > 0 then
		factor = SeSi.ServerValues.Target.ParryChancePerDefenseSmall;

		if difference > SeSi.ServerValues.Target.ParryChanceFormulaThreshold then
			factor = SeSi.ServerValues.Target.ParryChancePerDefenseBig;
		end
	end
	chance = chance + difference * factor;
	return max(0,chance);
end

function SeSi.Target.GetBlock(playerStats, targetStats, hand)
	if (targetStats["IS_PLAYER"] == 1) then
		return "unknown"; -- can't compute for players since block is subject to talents
	end

	if (SeSi.Settings.AttackingFromBehind == 1) then
		return 0; -- can't block from behind
	end

	local chance = SeSi.ServerValues.Target.BaseBlockChance;
	local targetDefense = 5 * targetStats["LEVEL"];
	local playerWeaponSkill;

	if SeSi.Player.Feral.IsFeralForm() == 1 then
		playerWeaponSkill = 5 * playerStats["LEVEL"];
	else
		playerWeaponSkill = playerStats[hand];
	end

	local difference = targetDefense - playerWeaponSkill;
	local factor = SeSi.ServerValues.Target.BlockPerDefenseBig;

	if difference > 0 then
		factor = SeSi.ServerValues.Target.BlockPerDefenseSmall;
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