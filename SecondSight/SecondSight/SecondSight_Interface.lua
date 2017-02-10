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
	--local playerStats = SeSi.Player.GetPlayerStats();
	--local targetStats = SeSi.Target.GetTargetStats();
	--local hand = "WEAPONSKILL_MH";
	--local table = SeSi.Player.GetAttackingTable(playerStats, targetStats, hand);
	--for i,k in pairs(table) do
	--	DEFAULT_CHAT_FRAME:AddMessage(i.. " : " ..k);
	--end
	local MhWeaponType = SeSi.Player.GetWeaponType("MainHandSlot");
	DEFAULT_CHAT_FRAME:AddMessage(MhWeaponType);
end


function ExitButton_OnClick()
	FrameTemplate:Hide();
end
