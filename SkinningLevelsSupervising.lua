
------------------------------------------------------------------------------------------
-----------------------------------   GLOBAL DEFS  ---------------------------------------
------------------------------------------------------------------------------------------

function SkinningLevelsFrame_OnEvent(frame, event, ...)
  if event == 'PLAYER_LOGOUT' then
    SkinningLevels:SaveVariablesToDB()
  end
end

SkinningLevels = LibStub("AceAddon-3.0"):NewAddon("SkinningLevels", "AceEvent-3.0")
SkinningLevelsDB = SkinningLevelsDB or {}

------------------------------------------------------------------------------------------
-------------------------------   LOCAL & OBJECT DEFS  -----------------------------------
------------------------------------------------------------------------------------------

SkinningLevels.TEXT_V_SPACE = 15
SkinningLevels.NR_FONT_STRINGS = 5

local options = {
  name = "SkinningLevels",
  handler = SkinningLevels,
  type = "group",
  args = {
    description = {
      name = "What is this? SkinningLevels shows you which level mobs you can skin"
             .. " and at what difficulty (|cFF3FBD3Fgreen|r/|cFFFFFF00yellow|r/|cFFFF7F3Forange|r)\n"
             .. "To move the frame hold rightclick and drag to desired location",
      order = 5,
      type = "description",
    },
    enable = {
      name = "Enable",
      desc = "Enables / disables the addon",
      order = 10,
      width = 'half',
      type = "toggle",
      set = function(info, val) 
              if val then
                SkinningLevels:Enable()
              else
                SkinningLevels:Disable()
              end
            end,
      get = function(info) return SkinningLevels.enabled end,
    },
    title = {
      name = "Title",
      desc = "Displays the title in the addon frame",
      order = 15,
      type = "toggle",
      set = function(info, val)
              SkinningLevels.title = val
              SkinningLevels:CheckAndUpdate(true)
            end,
      get = function(info) return SkinningLevels.title end,
    },
    style = {
      name = "Split style",
      desc = "Toggles split / continuous styles",
      order = 40,
      width = 'half',
      type = "toggle",
      set = function(info, val)
              SkinningLevels.split = val
              SkinningLevels:CheckAndUpdate(true)
            end,
      get = function(info) return SkinningLevels.split end,
    },
    endAtRed = {
      name = "End with red",
      desc = "Display the orange range equal to green and yellow (up to max level)",
      order = 45,
      disabled = function(info) 
                   return SkinningLevels.split or SkinningLevels.orange.max == '??'
                 end,
      type = "toggle",
      set = function(info, val)
              SkinningLevels.endAtRed = val
              SkinningLevels:CheckAndUpdate(true)
            end,
      get = function(info) return SkinningLevels.endAtRed end,
    },
    warningGroup = {
      name = "Hit Cap Warning",
      desc = "test",
      order = 1000,
      type = "group",
      inline = true,
      args = {
        warningEnabled = {
          name = "Warning Enabled",
          desc = "Display warning when you are close to skinning cap (75, 150, 255, 300)",
          order = 10,
          type = "toggle",
          set = function(info, val)
                  SkinningLevels.warning = val
                  SkinningLevels:CheckAndUpdate(true)
                end,
          get = function(info) return SkinningLevels.warning end,
        },
        warningLevel = {
          name = "Levels In Advance",
          desc = "When to show the warning (skinning levels in advance)",
          order = 30,
          type = "range",
          min = 0,
          max = 25,
          step = 1,
          set = function(info, val)
                  SkinningLevels.warningLevel = val
                  SkinningLevels:CheckAndUpdate(true)
                end,
          get = function(info) return SkinningLevels.warningLevel end,
        },
        warningMethod = {
          name = "WarningMethod",
          desc = "How the warning will be shown",
          order = 20,
          type = "select",
          values = {
            raid_warning = "Raid Warning",
            in_chat = "Chat message",
            bottom_frame = "Bottom of frame",
          },
          set = function(info, val)
                  SkinningLevels.warningMethod = val
                  SkinningLevels:CheckAndUpdate(true)
                end,
          get = function(info) return SkinningLevels.warningMethod end,
        },
      }
    },
    scale = {
      name = "Scale",
      desc = "[0.4-1.6] Changes the scale of the frame",
      order = 20,
      type = "range",
      min = 0.4,
      max = 1.6,
      step = 0.01,
      set = function(info, val)
              SkinningLevels.scale = val
              SkinningLevels:CheckAndUpdate(true)
            end,
      get = function(info) return SkinningLevels.scale end,
    },
    alpha = {
      name = "Transparency",
      desc = "[0.2-1] Changes the transparency of the frame",
      order = 50,
      type = "range",
      min = 0.2,
      max = 1,
      step = 0.01,
      set = function(info, val)
            SkinningLevels.alpha = val
            SkinningLevels:CheckAndUpdate(true)
          end,
      get = function(info) return SkinningLevels.alpha end,
    },
    reset = {
      name = "Reset",
      desc = "Resets the addon to default settings",
      order = 60,
      confirm = true,
      type = "execute",
      func = "ResetToDefault",
    },
    posCenter = {
      name = "Center Of Screen",
      desc = "Sets the position to center of the screen so you can find it if you couldn't before",
      order = 30,
      type = "execute",
      func = "SetPositionToCenterOfScreen",
    },
  },
}

function SkinningLevels:OnInitialize()
  LibStub("AceConfig-3.0"):RegisterOptionsTable("SkinningLevels", options, {"skinninglevels", "sl"})
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SkinningLevels", "SkinningLevels")
  self:LoadSavedVariables()

  self.frame = SkinningLevelsFrame
  self.frame:RegisterForDrag("RightButton")
  self.frame:RegisterEvent("PLAYER_LOGOUT")
  
  self:CreateTexts()
  
  if type(self.enabled) == "boolean" and not self.enabled then
    self:SetEnabledState(false)
    self.frame:Hide()
  end
end

function SkinningLevels:CreateTexts()
  self.text = {}
  for i = 1, self.NR_FONT_STRINGS do
    self.text[i] = self.frame:CreateFontString("SkinningLevelsText" .. i, "OVERLAY", "GameFontNormal")
    self.text[i]:SetPoint("TOP", 0, 2 - (i * self.TEXT_V_SPACE))
    self.text[i]:SetJustifyH("CENTER")
    self.text[i]:SetText("Test"..i)
  end
end

function SkinningLevels:LoadSavedVariables()
  if type(SkinningLevelsDB.title) == 'boolean' then
    self.enabled = SkinningLevelsDB.enabled
    self.title = SkinningLevelsDB.title
    self.scale = SkinningLevelsDB.scale
    self.alpha = SkinningLevelsDB.alpha
    self.split = SkinningLevelsDB.split
    self.endAtRed = SkinningLevelsDB.endAtRed
    self.warning = SkinningLevelsDB.warning
    self.warningLevel = SkinningLevelsDB.warningLevel
    self.warningMethod = SkinningLevelsDB.warningMethod
  else
    self.enabled = true
    self.title = true
    self.scale = 1
    self.alpha = 1
    self.split = false
    self.endAtRed = false
    self.warning = true
    self.warningLevel = 10
    self.warningMethod = "bottom_frame"
  end
end

function SkinningLevels:SaveVariablesToDB()
  SkinningLevelsDB.enabled = self.enabled
  SkinningLevelsDB.title = self.title
  SkinningLevelsDB.scale = self.scale
  SkinningLevelsDB.alpha = self.alpha
  SkinningLevelsDB.split = self.split
  SkinningLevelsDB.endAtRed = self.endAtRed
  SkinningLevelsDB.warning = self.warning
  SkinningLevelsDB.warningLevel = self.warningLevel
  SkinningLevelsDB.warningMethod = self.warningMethod
end

function SkinningLevels:OnEnable()
--  ChatFrame1:AddMessage("SkinningLevels:OnEnable()")
  self:RegisterEvent("SKILL_LINES_CHANGED")
  self:CheckAndUpdate(true)  
  self.frame:Show()
  self.enabled = true
end

function SkinningLevels:OnDisable()
--  ChatFrame1:AddMessage("SkinningLevels:OnDisable()")
  self:UnregisterEvent("SKILL_LINES_CHANGED")
  self.frame:Hide()
  self.enabled = false
end

function SkinningLevels:ResetToDefault()
  self.frame:ClearAllPoints()
  self.frame:SetPoint("TOP", Minimap, "BOTTOM", 0, -15)
  self.title = true
  self.split = false
  self.endAtRed = false
  self.scale = 1
  self.alpha = 1
  self.warning = true
  self.warningLevel = 10
  self.warningMethod = "bottom_frame"
  if not self.enabled then
    self:Enable()
  else
    self:CheckAndUpdate(true)
  end
end

function SkinningLevels:SetPositionToCenterOfScreen()
  self.frame:ClearAllPoints()
  self.frame:SetPoint("CENTER", UIParent, "CENTER")
end
