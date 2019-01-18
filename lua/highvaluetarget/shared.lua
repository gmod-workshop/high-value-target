--- High Value Target
-- @module hvt
-- @author Doctor Jew

hvt = hvt or {}

hvt.Targets = {}

include("config.lua")

-- Convenience functions

--- Retrieve a value from the configuration.
-- @shared
-- @tparam string key The key to search for, this can include a sub-key as well (i.e HUD.Scale)
-- @param default A fallback default value in case the key is not found
-- @return The retrieved value or the fallback default if not found
function hvt.GetConfig(key, default)
  if not hvt.Config then return default end

  local cat, sub = string.match(key, "([%w]+).?([%w]*)")

  local tbl = hvt.Config[cat]

  if istable(tbl) and sub then
    if tbl == nil then
      tbl = {}
    end

    return Either(tbl[sub] ~= nil, tbl[sub], default)
  end

  return Either(tbl ~= nil, tbl, default)
end

--- Get the group name for a given entity class.
-- @shared
-- @tparam string class The class of the entity
-- @return Returns the associated name of the group or nil
function hvt.GetTargetGroup(class)
  for group, classes in pairs(hvt.Config.Groups) do
    for _, target in ipairs(classes) do
      if string.lower(target) == string.lower(class or "") then return group end
    end
  end

  return nil
end

--- Get the count for an entity group.
-- @tparam string The name of the group
-- @return Returns the group count or 0
function hvt.GetGroupCount(group)
  group = hvt.Targets[group] or hvt.GetTargetGroup(class)

  if not group then return 0 end

  return isnumber(group) and group or isnumber(hvt.Targets[group]) and hvt.Targets[group] or 0
end

-- Internal tracking hooks

hook.Add("InitPostEntity", "HVT.InitPostEntity", function()
  for _, ent in ipairs(ents.GetAll()) do
    if not IsValid(ent) then continue end
    if ent.DisableHVT then continue end
    if hook.Run("HVT.AddTarget", ent) == false then continue end

    local group = hvt.GetTargetGroup(ent:GetClass())

    if not group then continue end

    hvt.Targets[group] = hvt.Targets[group] or 0

    hvt.Targets[group] = hvt.Targets[group] + 1
  end

  if CLIENT then hvt.Initialize() end
end)

hook.Add("OnEntityCreated", "HVT.OnEntityCreated", function(ent)
  if not IsValid(ent) then return end
  if ent.DisableHVT then return end
  if hook.Run("HVT.AddTarget", ent) == false then return end

  local group = hvt.GetTargetGroup(ent:GetClass())

  if not group then return end

  hvt.Targets[group] = isnumber(hvt.Targets[group]) and hvt.Targets[group] or 0

  hvt.Targets[group] = hvt.Targets[group] + 1

  if CLIENT then
    hvt.UpdatePanel(group)

    if hvt.Targets[group] > 0 then return end

    hvt.FadePanel(group)
  end
end)

hook.Add("EntityRemoved", "HVT.EntityRemoved", function(ent)
  if not IsValid(ent) then return end
  if ent.DisableHVT then return end
  if hook.Run("HVT.RemoveTarget", ent) == false then return end

  local group = hvt.GetTargetGroup(ent:GetClass())

  if not group then return end

  hvt.Targets[group] = isnumber(hvt.Targets[group]) and hvt.Targets[group] or 0

  hvt.Targets[group] = math.max(hvt.Targets[group] - 1, 0)

  if CLIENT then
    hvt.UpdatePanel(group)

    if hvt.Targets[group] > 0 then return end

    hvt.FadePanel(group)
  end
end)
