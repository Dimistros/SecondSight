-- Author      : Dimistros
-- Create Date : 1/2/2017 7:08:43 PM

DEFAULT_CHAT_FRAME:AddMessage("SecondSight_Interface.lua loaded");
SeSi.IF = {};

function SeSi.IF:ExitButton_OnClick()
	DEFAULT_CHAT_FRAME:AddMessage(SeSi.Player.Parry.GetEqualLevelParry(SeSi.Player.GetPlayerStats()));
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