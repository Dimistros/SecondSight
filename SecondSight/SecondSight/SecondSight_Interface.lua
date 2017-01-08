-- Author      : Dimistros
-- Create Date : 1/2/2017 7:08:43 PM

DEFAULT_CHAT_FRAME:AddMessage("SecondSight_Interface.lua loaded");
SeSi.IF = {};

function SeSi.IF:ExitButton_OnClick()
	--local value = SeSi.TEST.UnitAttackBothHandsTEST("target");
	--for i,k in pairs(value) do
		DEFAULT_CHAT_FRAME:AddMessage(SeSi.TEST.UnitBuff());
	--end

end

function SeSi.IF:FrameTemplate_OnLoad()
	DEFAULT_CHAT_FRAME:AddMessage("default frame loaded");
end

function SeSi.IF:Button1_OnClick()
	stats = SeSi.Player.GetPlayerStats();
	for i,k in pairs(stats) do
		DEFAULT_CHAT_FRAME:AddMessage(i.. " : " ..k);
	end
end

function Button2_OnClick()
	TRstats = SeSi.Target.GetTargetStats();
	for i,k in pairs(TRstats) do
		DEFAULT_CHAT_FRAME:AddMessage(i.. " : " ..k);
	end
end

function Button4_OnClick()
	local playerStats = SeSi.Player.GetPlayerStats();
	local targetStats = SeSi.Target.GetTargetStats();
	local hand = "WEAPONSKILL_MH";
	local table = SeSi.Player.GetAttackingTable(playerStats, targetStats, hand);
	for i,k in pairs(table) do
		DEFAULT_CHAT_FRAME:AddMessage(i.. " : " ..k);
	end
end

