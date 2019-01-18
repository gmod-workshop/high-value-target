hook.Add("Initialize", "HVT.Initialize", function()
  hvt.UpdateGroupCounts()

  if CLIENT then hvt.Initialize() end
end)

local function UpdateGroups()
  hvt.UpdateGroupCounts()

  if CLIENT then hvt.Update() end
end

hook.Add("OnEntityCreated", "HVT.OnEntityCreated", UpdateGroups)
hook.Add("EntityRemoved", "HVT.EntityRemoved", UpdateGroups)

if CLIENT then
  hook.Add("PopulateToolMenu", "HVT.PopulateToolMenu", function()
    spawnmenu.AddToolMenuOption("Utilities", "High Value Target", "HVTSVSettings", "Server Settings", "", "", function(panel)
      panel:Help("Server Settings")

      panel:AddControl("ComboBox", {
        MenuButton = 1,
        Folder = "util_hvt_sv",
        Options = {
          ["#preset.default"] = {}
        }
      })
    end)

    spawnmenu.AddToolMenuOption("Utilities", "High Value Target", "HVTCLSettings", "Client Settings", "", "", function(panel)
      panel:Help("Client Settings")

      panel:AddControl("ComboBox", {
        MenuButton = 1,
        Folder = "util_hvt_cl",
        Options = {
          ["#preset.default"] = {}
        }
      })

      panel:Help("General HUD Settings")

      panel:CheckBox("HUD Enabled", "hvt_hud_enabled")
      panel:CheckBox("HUD Fade", "hvt_hud_fade")
      panel:CheckBox("HUD Flash", "hvt_hud_flash")

      panel:NumSlider("HUD X", "hvt_hud_x", 0, 100, 0)
      panel:NumSlider("HUD Y", "hvt_hud_y", 0, 100, 0)

      panel:NumSlider("HUD Scale", "hvt_hud_scale", 0.0, 5.0, 1)

      do
        panel:Help("Background Color")

        local color = vgui.Create("DColorMixer")
        color:SetConVarR("hvt_hud_r")
        color:SetConVarG("hvt_hud_g")
        color:SetConVarB("hvt_hud_b")
        color:SetConVarA("hvt_hud_a")

        panel:AddItem(color)
      end

      do
        panel:Help("Font Color")

        local color = vgui.Create("DColorMixer")
        color:SetConVarR("hvt_hud_font_r")
        color:SetConVarG("hvt_hud_font_g")
        color:SetConVarB("hvt_hud_font_b")
        color:SetConVarA("hvt_hud_font_a")

        panel:AddItem(color)
      end
    end)
  end)

  hook.Add("AddToolMenuCategories", "HVT.AddToolMenuCategories", function()
    spawnmenu.AddToolCategory("Utilities", "High Value Target", "High Value Target")
  end)
end
