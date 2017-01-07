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
SeSi.ServerValues.Player.DualWieldMissBonus = 19
SeSi.ServerValues.Player.MissChancePerDefenseSmall = 0.1;
SeSi.ServerValues.Player.MissChancePerDefenseBig = 0.4;
SeSi.ServerValues.Player.MissChancePerDefenseBonus = 2;

SeSi.ServerValues.Player.DodgeChancePerDefenseSmall = 0.04;
SeSi.ServerValues.Player.DodgeChancePerDefenseBig = 0.1;

SeSi.ServerValues.Player.BaseParryChance = 5;