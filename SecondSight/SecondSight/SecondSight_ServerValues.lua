-- Author      : dimistros
-- Create Date : 1/6/2017 4:23:00 PM

DEFAULT_CHAT_FRAME:AddMessage("SecondSight_ServerValues.lua loaded");

-- Player Class Stats:
SeSi.ServerValues = {};
SeSi.ServerValues.Player = {};
SeSi.ServerValues.Player.PLAYER_AGI_TO_DODGE = {};
SeSi.ServerValues.Player.PLAYER_AGI_TO_DODGE["WARRIOR"] =  0.05;
SeSi.ServerValues.Player.PLAYER_AGI_TO_DODGE["PALADIN"] =  0.05;
SeSi.ServerValues.Player.PLAYER_AGI_TO_DODGE["HUNTER"] =  0.03774;
SeSi.ServerValues.Player.PLAYER_AGI_TO_DODGE["ROGUE"] =  0.06897;
SeSi.ServerValues.Player.PLAYER_AGI_TO_DODGE["PRIEST"] =  0.05;
SeSi.ServerValues.Player.PLAYER_AGI_TO_DODGE["SHAMAN"] =  0.05;
SeSi.ServerValues.Player.PLAYER_AGI_TO_DODGE["MAGE"] =  0.05;
SeSi.ServerValues.Player.PLAYER_AGI_TO_DODGE["WARLOCK"] =  0.05;
SeSi.ServerValues.Player.PLAYER_AGI_TO_DODGE["DRUID"] =  0.05;

SeSi.ServerValues.Player.PLAYER_BASE_DODGE = {};
SeSi.ServerValues.Player.PLAYER_BASE_DODGE["WARRIOR"] =  0;
SeSi.ServerValues.Player.PLAYER_BASE_DODGE["PALADIN"] =  0.75;
SeSi.ServerValues.Player.PLAYER_BASE_DODGE["HUNTER"] =  0.64;
SeSi.ServerValues.Player.PLAYER_BASE_DODGE["ROGUE"] =  0;
SeSi.ServerValues.Player.PLAYER_BASE_DODGE["PRIEST"] =  3;
SeSi.ServerValues.Player.PLAYER_BASE_DODGE["SHAMAN"] =  1.75;
SeSi.ServerValues.Player.PLAYER_BASE_DODGE["MAGE"] =  3.25;
SeSi.ServerValues.Player.PLAYER_BASE_DODGE["WARLOCK"] =  2;
SeSi.ServerValues.Player.PLAYER_BASE_DODGE["DRUID"] =  0.75;

SeSi.ServerValues.Player.BaseMissChance = 5;
SeSi.ServerValues.Player.DualWieldMissBonus = 19;
SeSi.ServerValues.Player.MissChancePerDefenseBase = 0.04;
SeSi.ServerValues.Player.MissChancePerDefenseSmall = 0.1;
SeSi.ServerValues.Player.MissChancePerDefenseBig = 0.4;
SeSi.ServerValues.Player.MissChancePerDefenseBonus = 2;

SeSi.ServerValues.Player.DodgeChancePerDefenseSmall = 0.04;

SeSi.ServerValues.Player.BaseParryChance = 5;

SeSi.ServerValues.Target = {};
SeSi.ServerValues.Target.BaseDodgeChance = 5;
SeSi.ServerValues.Target.DodgeChancePerDefenseSmall = 0.04;
SeSi.ServerValues.Target.DodgeChancePerDefenseBig = 0.1;
SeSi.ServerValues.Target.DodgeChanceFormulaThreshold = 0;

SeSi.ServerValues.Target.BaseParryChance = 5;
SeSi.ServerValues.Target.ParryChancePerDefenseNormal = 0.04;
SeSi.ServerValues.Target.ParryChancePerDefenseSmall = 0.1;
SeSi.ServerValues.Target.ParryChancePerDefenseBig = 0.4;
SeSi.ServerValues.Target.ParryChanceFormulaThreshold = 10;

SeSi.ServerValues.Target.BaseBlockChance = 5;
SeSi.ServerValues.Target.BlockPerDefenseBig = 0.04;
SeSi.ServerValues.Target.BlockPerDefenseSmall = 0;