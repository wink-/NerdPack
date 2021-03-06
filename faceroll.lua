NeP.Faceroll = {}

local aC = '|cff'..NeP.Interface.addonColor
local rangeCheck = LibStub("LibRangeCheck-2.0")

-- This to put an icon on top of the spell we want
local activeFrame = CreateFrame('Frame', 'activeCastFrame', UIParent)
activeFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
activeFrame:SetBackdropColor(0,0,0,1);
activeFrame.texture = activeFrame:CreateTexture()
activeFrame.texture:SetTexture("Interface/TARGETINGFRAME/UI-RaidTargetingIcon_8")
activeFrame.texture:SetPoint("CENTER")
activeFrame:SetFrameStrata('HIGH')
activeFrame:Hide()

-- Work in Progress...
local display = CreateFrame('Frame', 'Faceroll_Info', activeFrame)
display:SetClampedToScreen(true)
display:SetSize(0, 0)
display:SetPoint("TOP")
display:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
display:SetBackdropColor(0,0,0,1);
display.text = display:CreateFontString('PE_StatusText')
display.text:SetFont("Fonts\\ARIALN.TTF", 16)
display.text:SetPoint("CENTER", display)

local function showActiveSpell(spell, target)
	local spellButton = NeP.Buttons[spell]
	if spell and spellButton then
		local bSize = spellButton:GetWidth()
		activeFrame:SetSize(bSize+5, bSize+5)
		display:SetSize(display.text:GetStringWidth()+20, display.text:GetStringHeight()+20)
		activeFrame.texture:SetSize(activeFrame:GetWidth()-5,activeFrame:GetHeight()-5)
		activeFrame:SetPoint("CENTER", spellButton, "CENTER")
		display:SetPoint("TOP", spellButton, 0, display.text:GetStringHeight()+20)
		local spell = aC.."Spell:|r "..spell
		local isTargeting = aC..tostring(UnitIsUnit("target", target))
		local target = aC.."\nTarget:|r"..(UnitName(target) or '')
		display.text:SetText(spell..target.."("..isTargeting..")")
		activeFrame:Show()
		display:Show()
	end
end

-- Hide it
NeP.Timer.Sync("nep_faceroll", 1, function()
	activeFrame:Hide()
	display:Hide()
end)

local _rangeTable = {
	['melee'] = 1.5,
	['ranged'] = 40,
}

function FallBack_Distance(b)
	if UnitExists(b) then
		local minRange, maxRange = rangeCheck:GetRange(b)
		return maxRange or minRange
	end
	return 0
end

function NeP.Engine.FaceRoll()

	-- cast on ground
	function NeP.Engine.CastGround(spell, target)
		showActiveSpell(spell, target)
	end

	-- Cast
	function NeP.Engine.Cast(spell, target)
		showActiveSpell(spell, target)
	end

	-- Macro
	function NeP.Engine.Macro(text)
		NeP.Core.Print('[RUN MACRO]: '..text)
	end

	function NeP.Engine.UseItem(name, target)
		NeP.Core.Print('[USE ITEM]: '..name)
	end

	function NeP.Engine.UseInvItem(name)
		NeP.Core.Print('[USE ITEM]: '..name)
	end

	function NeP.Engine.LineOfSight(_, b)
		return NeP.Helpers.infront(b)
	end

	-- Distance
	function NeP.Engine.Distance(unit1, unit2)
		local y1, x1, z1, instance1 = UnitPosition(unit1)
		local y2, x2, z2, instance2 = UnitPosition(unit2)
		if y2 and instance1 == instance2 then
			return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
		end
		return FallBack_Distance(unit2)
	end

	function NeP.Engine.Infront(a, b)
		return NeP.Helpers.infront(b)
	end

	NeP.Engine.UnitCombatRange = NeP.Engine.Distance

	function NeP.Engine.UnitAttackRange(unitA, unitB, rType)
		return rType and _rangeTable[rType] + 3.5 or 0
	end

end

NeP.Engine.FaceRoll()