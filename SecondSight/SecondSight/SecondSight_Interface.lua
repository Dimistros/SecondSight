-- Author      : Dimistros
-- Create Date : 1/2/2017 7:08:43 PM

DEFAULT_CHAT_FRAME:AddMessage("SecondSight_Interface.lua loaded");
SeSi.IF = {};

function SeSi.IF:FrameTemplate_OnLoad()
	DEFAULT_CHAT_FRAME:AddMessage("default frame loaded");
end

function SeSi.IF.getPlayer_OnClick()
	stats = SeSi.Player.GetPlayerStats();
	for i,k in pairs(stats) do
		DEFAULT_CHAT_FRAME:AddMessage(i.. " : " ..k);
	end
end

function SeSi.IF:getTarget_OnClick()
	TRstats = SeSi.Target.GetTargetStats();
	for i,k in pairs(TRstats) do
		DEFAULT_CHAT_FRAME:AddMessage(i.. " : " ..k);
	end
end

function SeSi.IF:testButton_OnClick()
	local playerStats = SeSi.Player.GetPlayerStats();
	local targetStats = SeSi.Target.CreateGenericEqualTarget(playerStats)
	--local targetStats = SeSi.Target.GetTargetStats()

	local playerAttackTableMH = SeSi.LimitTable(SeSi.Player.GetAttackingTable(playerStats, targetStats, "MH", 0));
	local playerAttackTableOH = SeSi.LimitTable(SeSi.Player.GetAttackingTable(playerStats, targetStats, "OH", 0));
	local playerAttackTableYellow = SeSi.LimitTable(SeSi.Player.GetAttackingTable(playerStats, targetStats, "MH", 1));
	SeSi.Report(playerAttackTableMH);
	SeSi.Report(playerAttackTableOH);
	SeSi.Report(playerAttackTableYellow);
end


function ExitButton_OnClick()
	FrameTemplate:Hide();
end
