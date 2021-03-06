--- High Value Target
-- @module hvt
-- @author Doctor Jew

hvt = hvt or {}

hvt.Targets = {}

include("config.lua")
include("hook.lua")

--- Get the group name for a given entity class.
-- @shared
-- @tparam string class The class of the entity
-- @return Returns the associated name of the group or nil
function hvt.GetTargetGroup(class)
  for group, config in pairs(hvt.Config.Groups) do
    for _, target in ipairs(config.Classes or {}) do
      if string.lower(target) == string.lower(class or "") then return group end
    end
  end

  return nil
end

--- Get the count for an entity group.
-- @shared
-- @tparam string group The name of the group
-- @return Returns the group count or 0
function hvt.GetTargetCount(group)
  group = hvt.Targets[group] or hvt.GetTargetGroup(group)

  if not group then return 0 end

  return isnumber(group) and group or isnumber(hvt.Targets[group]) and hvt.Targets[group] or 0
end

function hvt.UpdateGroupCounts()
  for group, config in pairs(hvt.Config.Groups) do
    local count = 0
    for _, class in ipairs(config.Classes or {}) do
      count = count + #ents.FindByClass(class)
    end

    if config.CustomCheck then
      for _, ent in ipairs(ents.GetAll()) do
        if config.CustomCheck(ent) then count = count + 1 end
      end
    end

    hvt.Targets[group] = count
  end
end
