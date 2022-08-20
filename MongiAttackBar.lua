local function print(output)
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ffff[%s]|r %s", "MongiAttackBar", tostring(output)), 1, 1, 1)
end

MongiAttackBarEventHandler = CreateFrame("frame", "MongiAttackBarEventHandler")
MongiAttackBarEvents = {
	"CHAT_MSG_COMBAT_SELF_HITS",
	"CHAT_MSG_COMBAT_SELF_MISSES",
	"UNIT_INVENTORY_CHANGED",
	"UNIT_SPELLCAST_SENT",
	"CHAT_MSG_SPELL_SELF_DAMAGE",
	"ACTIONBAR_UPDATE_STATE",
	"PLAYER_ENTERING_WORLD",
}

mhstart = 0
mhend = 0
ohstart = 0
ohend = 0
local lastweapon, compareweapon = nil

function MongiAttackBarEventHandler:PLAYER_ENTERING_WORLD()
	lastweapon = GetInventoryItemLink("player", 16) 
	compareweapon = GetInventoryItemLink("player", 16)
end

function MongiAttackBarEventHandler.MH()
	local mhspeed, ohspeed = UnitAttackSpeed("player")
	local mhlow, mhhigh, ohlow, ohhigh = UnitDamage("player")
	local dmgtext = string.format("%.1f (%s - %s)", mhspeed, mhhigh, mhlow)
	mhstart = GetTime()
	mhend = mhstart + mhspeed
	MongiAttackBarMH:SetMinMaxValues(mhstart, mhend)
	MongiAttackBarMH:SetValue(mhstart)
	MongiAttackBarMHText:SetText(dmgtext)
	MongiAttackBarMH:Show()
end

function MongiAttackBarEventHandler.OH()
	local mhspeed, ohspeed = UnitAttackSpeed("player")
	local mhlow, mhhigh, ohlow, ohhigh = UnitDamage("player")
	local dmgtext = string.format("%.1f (%s - %s)", ohspeed, ohhigh, ohlow)
	ohstart = GetTime()
	ohend = ohstart + ohspeed
	MongiAttackBarOH:SetMinMaxValues(ohstart, ohend)
	MongiAttackBarOH:SetValue(ohstart)
	MongiAttackBarOHText:SetText(dmgtext)
	MongiAttackBarOH:Show()
end

MongiAttackBarEventHandler.OnEvent = function()
	this[event](MongiAttackBarEventHandler, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
end

MongiAttackBarEventHandler.OnUpdate = function()
	local mhspeed, ohspeed = UnitAttackSpeed("player")
	local mhlow, mhhigh, ohlow, ohhigh = UnitDamage("player")
	if MongiAttackBarMH:IsVisible() then
		local dmgtext = string.format("%.1fs (%s - %s)", mhspeed, mhlow, mhhigh)
		mhend = mhstart + mhspeed
		MongiAttackBarMH:SetMinMaxValues(mhstart, mhend)
		MongiAttackBarMHText:SetText(dmgtext)
		if GetTime() >= mhend then
			mhstart = 0
			mhend = 0
			MongiAttackBarMH:Hide()
		else
			local sparkPosition = ((GetTime() - mhstart) / mhspeed) * 150
			MongiAttackBarMH:SetValue(GetTime())
			MongiAttackBarMHSpark:SetPoint("CENTER", MongiAttackBarMH, "LEFT", sparkPosition, 0)
		end
	end
	if MongiAttackBarOH:IsVisible() and ohspeed then
		local dmgtext = string.format("%.1fs (%s - %s)", ohspeed, ohlow, ohhigh)
		ohend = ohstart + ohspeed
		MongiAttackBarOH:SetMinMaxValues(ohstart, ohend)
		MongiAttackBarOHText:SetText(dmgtext)
		if GetTime() >= ohend then
			ohstart = 0
			ohend = 0
			MongiAttackBarOH:Hide()
		else
			local sparkPosition = ((GetTime() - ohstart) / ohspeed) * 150
			MongiAttackBarOH:SetValue(GetTime())
			MongiAttackBarOHSpark:SetPoint("CENTER", MongiAttackBarOH, "LEFT", sparkPosition, 0)
		end
	end
	if not ohspeed then
		MongiAttackBarOH:Hide()
		ohstart = 0
		ohend = 0
	end
end

function MongiAttackBarEventHandler:CHAT_MSG_COMBAT_SELF_HITS(arg1)
	local mhspeed, ohspeed = UnitAttackSpeed("player")
	if ohspeed then
		if mhstart ~= 0 and ohstart ~= 0 then
			if (mhend - GetTime()) > (ohend - GetTime()) then
				MongiAttackBarEventHandler.OH()
			elseif (mhend - GetTime()) < (ohend - GetTime()) then
				MongiAttackBarEventHandler.MH()
			end
		elseif mhstart == 0 and ohstart ~= 0 then
			MongiAttackBarEventHandler.MH()
		elseif mhstart ~= 0 and ohstart == 0 then
			MongiAttackBarEventHandler.OH()
		else
			MongiAttackBarEventHandler.MH()
		end
	else
		MongiAttackBarEventHandler.MH()
	end
end

function MongiAttackBarEventHandler:CHAT_MSG_COMBAT_SELF_MISSES(arg1)
	local mhspeed, ohspeed = UnitAttackSpeed("player")
	if ohspeed then
		if mhstart ~= 0 and ohstart ~= 0 then
			if (mhend - GetTime()) > (ohend - GetTime()) then
				MongiAttackBarEventHandler.OH()
			elseif (mhend - GetTime()) < (ohend - GetTime()) then
				MongiAttackBarEventHandler.MH()
			end
		elseif mhstart == 0 and ohstart ~= 0 then
			MongiAttackBarEventHandler.MH()
		elseif mhstart ~= 0 and ohstart == 0 then
			MongiAttackBarEventHandler.OH()
		else
			MongiAttackBarEventHandler.MH()
		end
	else
		MongiAttackBarEventHandler.MH()
	end
end

function MongiAttackBarEventHandler:CHAT_MSG_SPELL_SELF_DAMAGE(arg1)
	local a = string.find(arg1, "Heroic Strike")
	local b = string.find(arg1, "Cleave")
	local c = string.find(arg1, "Slam")
	local e = string.find(arg1, "Raptor Strike")
	if a or b or c or d or e then
		MongiAttackBarEventHandler.MH()
	end
end

function MongiAttackBarEventHandler:UNIT_SPELLCAST_SENT(arg1)
	print(arg1)
end

function MongiAttackBarEventHandler:UNIT_INVENTORY_CHANGED(unit)
	if unit == "player" then
		compareweapon = GetInventoryItemLink(unit, 16)
		if lastweapon ~= compareweapon then
			MongiAttackBarEventHandler.MH()
			lastweapon = compareweapon
		end
	end
end

function MongiAttackBarEventHandler:ACTIONBAR_UPDATE_STATE(arg1)
	
end

MongiAttackBarEventHandler:SetScript("OnEvent", MongiAttackBarEventHandler.OnEvent)
MongiAttackBarEventHandler:SetScript("OnUpdate", MongiAttackBarEventHandler.OnUpdate)
for k, v in pairs(MongiAttackBarEvents) do
	MongiAttackBarEventHandler:RegisterEvent(v)
end
