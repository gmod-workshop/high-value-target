if SERVER then
  AddCSLuaFile("highvaluetarget/shared.lua")
  AddCSLuaFile("highvaluetarget/cl_init.lua")

  include("highvaluetarget/init.lua")
end

if CLIENT then
  include("highvaluetarget/cl_init.lua")
end
