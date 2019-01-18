AddCSLuaFile("config.lua")
AddCSLuaFile("hook.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

CreateConVar("hvt_enabled", "1", { FCVAR_ARCHIVE }, "Enable/disable the high value target system.")

function hvt.Update()
  for group, config in pairs(hvt.Config.Groups) do
    if not config.Delay or config.Delay <= 0 then continue end
    if hvt.GetTargetCount(group) > 0 then
      if not timer.Exists("hvt.timer." .. group) then
        timer.Create("hvt.timer." .. group, hvt.Config.Delay, 1, function()
          for _, class in ipairs(config.Classes or {}) do
            for _, ent in ipairs(ents.FindByClass(class)) do
              SafeRemoveEntity(ent)
            end
          end

          if config.CustomCheck then
            for _, ent in ipairs(ents.GetAll()) do
              if config.CustomCheck(ent) then SafeRemoveEntity(ent) end
            end
          end
        end)
      end
    elseif timer.Exists("hvt.timer." .. group) then
      timer.Remove("hvt.timer." .. group)
    end
  end
end
