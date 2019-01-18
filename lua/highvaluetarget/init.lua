AddCSLuaFile("config.lua")
AddCSLuaFile("hook.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

CreateConVar("hvt_enabled", "1", { FCVAR_ARCHIVE }, "Enable/disable the high value target system.")
