--- High Value Target
-- @module hvt
-- @author Doctor Jew

include("shared.lua")

hvt = hvt or {}

CreateClientConVar("hvt_hud_enabled", "1", true, false, "Enable/disable the high value target HUD.")

CreateClientConVar("hvt_hud_x", "50", true, false, "The X percentage offset of the HUD (0.0 - 1.0)")
CreateClientConVar("hvt_hud_y", "4", true, false, "The Y percentage offset of the HUD (0.0 - 1.0)")
CreateClientConVar("hvt_hud_scale", "1.0", true, false, "The scale of the high value target HUD.")
CreateClientConVar("hvt_hud_flash", "1", true, false, "Should the HUD flash red when the counter changes?")
CreateClientConVar("hvt_hud_fade", "1", true, false, "Should the HUD fade out when the counter is 0?")

CreateClientConVar("hvt_hud_r", "0", true, false, "The red value of the HVT HUD (0 - 255)")
CreateClientConVar("hvt_hud_g", "0", true, false, "The green value of the HVT HUD (0 - 255)")
CreateClientConVar("hvt_hud_b", "0", true, false, "The blue value of the HVT HUD (0 - 255)")
CreateClientConVar("hvt_hud_a", "100", true, false, "The alpha value of the HVT HUD (0 - 255)")

CreateClientConVar("hvt_hud_font_title", "HVT.Group16", true, false, "The font used for the title.")
CreateClientConVar("hvt_hud_font_count", "HVT.Group72", true, false, "The font used for the counter.")

CreateClientConVar("hvt_hud_font_r", "255", true, false, "The red value of the HVT HUD font (0 - 255)")
CreateClientConVar("hvt_hud_font_g", "255", true, false, "The green value of the HVT HUD font (0 - 255)")
CreateClientConVar("hvt_hud_font_b", "255", true, false, "The blue value of the HVT HUD font (0 - 255)")
CreateClientConVar("hvt_hud_font_a", "255", true, false, "The alpha value of the HVT HUD font (0 - 255)")

-- Font Creation

for i = 8, 96, 8 do
  surface.CreateFont("HVT.Group" .. i, {
    font = "Roboto",
    shadow = false,
    size = i
  })
end

-- Panel Creation

--- Initialize the HUD for the system.
-- @client
function hvt.Initialize()
  hvt.Panels = hvt.Panels or {}

  hvt.GetParent()

  for group in pairs(hvt.Config.Groups) do
    hvt.ClearPanel(group)
    hvt.BuildPanel(group)
  end
end

--- Get the parent panel for the HUD.
-- @client
-- @return The root panel of the HUD
function hvt.GetParent()
  if ispanel(hvt.ParentPanel) then return hvt.ParentPanel end

  if ispanel(hvt.RootPanel) then hvt.RootPanel:Remove() end
  if ispanel(hvt.ParentPanel) then hvt.ParentPanel:Remove() end

  local PANEL = vgui.Create("DFrame")
  PANEL:SetTitle("")
  PANEL:ShowCloseButton(false)
  PANEL:SetSize(ScrW(), ScrH())
  PANEL:Center()
  PANEL:ParentToHUD()

  function PANEL:Paint(w, h) end

  hvt.RootPanel = PANEL

  local LAYOUT = PANEL:Add("DIconLayout")
  LAYOUT:SetSize(100, 100)
  LAYOUT:SetLayoutDir(TOP)
  LAYOUT:SetSpaceX(15)
  LAYOUT:CenterHorizontal()
  LAYOUT:SetContentAlignment(8)

  hvt.ParentPanel = LAYOUT

  return LAYOUT
end

--- Updates the parent panel that contains the other panels.
-- @client
function hvt.UpdateParent()
  local PARENT = hvt.GetParent()

  local count = 0
  for k, v in pairs(hvt.Panels) do
    if ispanel(v["MAIN"]) then count = count + 1 end
  end

  local scale = cvars.Number("hvt_hud_scale", 1.0)
  local w, h = 15 * (count - 1) + 100 * scale * count, 100 * scale

  PARENT:SetSize(w, h)

  PARENT:SetPos((ScrW() - w) * cvars.Number("hvt_hud_x", 50) / 100, (ScrH() - h) * cvars.Number("hvt_hud_y", 50) / 100)
end

function hvt.Update()
  for group in pairs(hvt.Config.Groups) do
    hvt.UpdatePanel(group)

    if hvt.GetTargetCount(group) <= 0 then
      hvt.FadePanel(group)
    end
  end
end

function hvt.FadePanel(group)
  if not (hvt.Panels[group] and ispanel(hvt.Panels[group]["MAIN"])) then return end
  if not cvars.Bool("hvt_hud_fade") then return end

  hvt.Panels[group]["MAIN"]:AlphaTo(0, 0.5, 0, function(tbl, pnl)
    if hvt.GetTargetCount(group) <= 0 then
      hvt.ClearPanel(group)
    elseif ispanel(pnl) then
      pnl:AlphaTo(cvars.Number("hvt_hud_font_a"), 0.1, 0)
    end
  end)
end

function hvt.ClearPanel(group)
  hvt.Panels[group] = hvt.Panels[group] or {}
  for k, v in pairs(hvt.Panels[group] or {}) do
    if ispanel(v) then v:Remove() end

    hvt.Panels[group] = {}
  end

  hvt.UpdateParent()
end

function hvt.UpdatePanel(group)
  local GROUP = hvt.Panels[group]

  if not GROUP then hvt.BuildPanel(group) end

  local FRAME, COUNT = GROUP["MAIN"], GROUP["COUNT"]

  if not cvars.Bool("hvt_hud_enabled", true) then
    return hvt.ClearPanel(group)
  end

  if not (ispanel(FRAME) and ispanel(COUNT)) then hvt.BuildPanel(group) end

  FRAME, COUNT = hvt.Panels[group]["MAIN"], hvt.Panels[group]["COUNT"]

  if not (ispanel(FRAME) and ispanel(COUNT)) then return end

  local current = tonumber(COUNT:GetText())
  local count = hvt.GetTargetCount(group)

  if current ~= count then
    COUNT:SetText(tostring(count))

    if cvars.Bool("hvt_hud_flash") then
      local color = FRAME:GetColor()
      FRAME:ColorTo(Color(255, 0, 0, 100), 0.1, 0, function()
        FRAME:ColorTo(color, 0.1, 0)
      end)
    end
  end

  local scale = cvars.Number("hvt_hud_scale", 1.0)
  FRAME:SetSize(100 * scale, 100 * scale)

  local color = Color(cvars.Number("hvt_hud_r"), cvars.Number("hvt_hud_g"), cvars.Number("hvt_hud_b"),  cvars.Number("hvt_hud_a"))
  FRAME:SetBackgroundColor(color)

  local text_color = Color(cvars.Number("hvt_hud_font_r"), cvars.Number("hvt_hud_font_g"), cvars.Number("hvt_hud_font_b"), cvars.Number("hvt_hud_font_a"))

  local TITLE = hvt.Panels[group]["TITLE"]

  TITLE:SetTextColor(text_color)
  COUNT:SetTextColor(text_color)

  if count <= 0 then
    hvt.FadePanel(group)
  end

  hvt.UpdateParent()
end

--- Reconstruct the HVT panel for a group
-- @client
-- @return The counter panel object
function hvt.BuildPanel(group)
  if not cvars.Bool("hvt_hud_enabled", true) then return end

  if hvt.GetTargetCount(group) <= 0 then return end

  local broken = false
  for _, name in ipairs({ "MAIN", "TITLE", "COUNT" }) do
    if not ispanel(hvt.Panels[group][name]) then broken = true break end
  end

  if not broken then return hvt.Panels[group]["MAIN"] end

  hvt.ClearPanel(group)

  local scale = cvars.Number("hvt_hud_scale", 1.0)
  local bg = Color(cvars.Number("hvt_hud_r"), cvars.Number("hvt_hud_g"), cvars.Number("hvt_hud_b"),  cvars.Number("hvt_hud_a"))

  local FRAME = hvt.GetParent():Add("DPanel")
  FRAME:SetBackgroundColor(bg)
  FRAME:SetSize(100 * scale, 100 * scale)
  FRAME:Center()

  function FRAME:SetColor(color) self:SetBackgroundColor(color) end

  function FRAME:GetColor() return self:GetBackgroundColor() end

  hvt.Panels[group]["MAIN"] = FRAME

  local text_color = Color(cvars.Number("hvt_hud_font_r"), cvars.Number("hvt_hud_font_g"), cvars.Number("hvt_hud_font_b"), cvars.Number("hvt_hud_font_a"))

  local GROUP = FRAME:Add("DLabel")
  GROUP:SetFont("HVT.Group16")
  GROUP:SetTextColor(text_color)
  GROUP:SetText(string.upper(group))
  GROUP:SetContentAlignment(5)
  GROUP:CenterHorizontal(0.5)
  GROUP:Dock(TOP)
  GROUP:DockMargin(0, FRAME:GetTall() * 0.1, 0, 0)

  hvt.Panels[group]["TITLE"] = GROUP

  local COUNT = FRAME:Add("DLabel")
  COUNT:SetFont("HVT.Group72")
  COUNT:SetTextColor(text_color)
  COUNT:SetText(hvt.GetTargetCount(group))
  COUNT:SetContentAlignment(5)
  COUNT:CenterHorizontal()
  COUNT:Dock(FILL)

  hvt.Panels[group]["COUNT"] = COUNT

  hvt.UpdateParent()

  return FRAME
end

cvars.AddChangeCallback("hvt_hud_enabled", hvt.Update)

cvars.AddChangeCallback("hvt_hud_x", hvt.Update)
cvars.AddChangeCallback("hvt_hud_y", hvt.Update)
cvars.AddChangeCallback("hvt_hud_scale", hvt.Update)
cvars.AddChangeCallback("hvt_hud_fade", hvt.Update)

cvars.AddChangeCallback("hvt_hud_r", hvt.Update)
cvars.AddChangeCallback("hvt_hud_g", hvt.Update)
cvars.AddChangeCallback("hvt_hud_b", hvt.Update)
cvars.AddChangeCallback("hvt_hud_a", hvt.Update)

cvars.AddChangeCallback("hvt_hud_font_r", hvt.Update)
cvars.AddChangeCallback("hvt_hud_font_g", hvt.Update)
cvars.AddChangeCallback("hvt_hud_font_b", hvt.Update)
cvars.AddChangeCallback("hvt_hud_font_a", hvt.Update)
