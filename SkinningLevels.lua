------------------------------------------------------------------------------------------
-----------------------------------   GLOBAL DEFS  ---------------------------------------
------------------------------------------------------------------------------------------

function SkinningLevelsFrame_OnClick(self, button, down)
  LibStub("AceConfigDialog-3.0"):Open("SkinningLevels")
end

function SkinningLevelsFrame_OnEnter(self, motion)
  GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, -3)
  
  local text = "Visit a skinning trainer\nto pick up skinning"
  if SkinningLevels.rank then
    text = string.format("Skinning: %d of %d", SkinningLevels.rank, SkinningLevels.rankMax)
  end
  
  GameTooltip:SetText(text)
  GameTooltip:Show()
end

function SkinningLevelsFrame_OnLeave(self, motion)
  GameTooltip:Hide()  
end

------------------------------------------------------------------------------------------
-------------------------------   LOCAL & OBJECT DEFS  -----------------------------------
------------------------------------------------------------------------------------------

function SkinningLevels:SKILL_LINES_CHANGED()
  self:CheckAndUpdate(false, true)
end

function SkinningLevels:ShouldApplyWarning(method)
  if self.warning and method == self.warningMethod and self.rank and self.rankMax then
    return (self.rankMax - self.rank) <= self.warningLevel and self.rank <= 300
  end
end

function SkinningLevels:CheckAndUpdate(force_update, triggeredByEvent)
  local skillRank, skillRankMax = self:getCurrentRankAndMax()
    
  if force_update or self.rank ~= skillRank or self.rankMax ~= skillRankMax then
    self:Update(skillRank, skillRankMax)
  end
  if triggeredByEvent then
    if self:ShouldApplyWarning("in_chat") then
      DEFAULT_CHAT_FRAME:AddMessage("|cFFDD4444SkinningLevels: You're about to hit your skinning cap. Visit trainer soon!|r")
    elseif self:ShouldApplyWarning("raid_warning") then
      RaidNotice_AddMessage(RaidWarningFrame, "You're about to hit your skinning cap. Visit trainer soon!", ChatTypeInfo["RAID_WARNING"])
    end
  end
end

function SkinningLevels:getCurrentRankAndMax()
  for i = 1, GetNumSkillLines() do
    local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank,
              isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription
              = GetSkillLineInfo(i)
    if not isHeader and skillName == "Skinning" then
      return skillRank, skillMaxRank
    end
  end
end

function SkinningLevels:Update(skillRank, skillRankMax)
  self.rank = skillRank
  self.rankMax = skillRankMax
  
  if skillRank then
    self.orange:calcRange(skillRank)
    self.yellow:calcRange(skillRank)
    self.green:calcRange(skillRank)
  end
  
  self:calcAndSetFrameSize()
  
  self.frame:SetScale(self.scale)
  self.frame:SetAlpha(self.alpha)

  self:setTexts()
end

function SkinningLevels:calcAndSetFrameSize()
  local width, height
  
  if self.split and self.rank then
    width = 120
    height = 85
    
    if not self.yellow.min and not self.yellow.max then
      height = height - (self.TEXT_V_SPACE * 2)
    elseif not self.green.min and not self.green.max then
      height = height - self.TEXT_V_SPACE
    end
    
  else
    width = 130
    height = 55
  end
  
  if not self.title then
    height = height - self.TEXT_V_SPACE - 1
  end

  if self:ShouldApplyWarning("bottom_frame") then
    height = height + self.TEXT_V_SPACE
  end
  
  self.frame:SetWidth(width)
  self.frame:SetHeight(height)
end

function SkinningLevels:setTexts()
  
  self:clearTexts()
  
  self.currentText = 1
  
  if self.title then
    self:addLine("SkinningLevels")
  end
  
  if self.rank then
    self:setRangeTexts()
  
    if self:ShouldApplyWarning("bottom_frame") then
      self:addLine("Visit trainer!", 'FFBB3333')
    end
  
  else
    self:addLine("No Skinning found", 'FFBB3333')
  end
end

function SkinningLevels:addLine(text, colorHex)
  if colorHex then
    self.text[self.currentText]:SetText("|c" .. colorHex .. text .. "|r")    
  else
    self.text[self.currentText]:SetText(text)
  end
  self.currentText = self.currentText + 1
end

function SkinningLevels:setRangeTexts()
  if self.split then
    self:setSplitText()
  else
    self:setContinuousText()
  end
end

function SkinningLevels:setSplitText()
  self:addLine(self.orange.min .. " - " .. self.orange.max, 'FFFF7F3F')
    
  if self.yellow.min and self.yellow.max then
    self:addLine(self.yellow.min .. " - " .. self.yellow.max, 'FFFFFF00')
  end
  
  if self.green.min and self.green.max then
    self:addLine(self.green.min .. " - " .. self.green.max, 'FF3FBD3F')
  end
end

function SkinningLevels:setContinuousText()
  local greenPart, yellowPart, orangePart = "", ""

  if self.green.min and self.green.max then
    greenPart = "|cFF3FBD3F" .. self.green.min .. " - |r"
  end
  
  if self.yellow.min and self.yellow.max then
    yellowPart = "|cFFFFFF00" .. self.yellow.min .. " - |r"
  end
  
  if self.endAtRed and type(self.orange.max) == 'number' then
    orangePart = "|cFFFF7F3F" .. self.orange.min .. " - |r|cFFFF0000" .. (self.orange.max + 1) .. "|r"
  else
    orangePart = "|cFFFF7F3F" .. self.orange.min .. " - " .. self.orange.max .. "|r"
  end
  
  self:addLine(greenPart .. yellowPart .. orangePart)
end

function SkinningLevels:clearTexts()
  for i = 1, self.NR_FONT_STRINGS do
    self.text[i]:SetText("")
  end
end
