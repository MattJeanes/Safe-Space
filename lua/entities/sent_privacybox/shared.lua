ENT.Type = "anim"
if WireLib then
	ENT.Base 			= "base_wire_entity"
else
	ENT.Base			= "base_gmodentity"
end 
ENT.PrintName		= "PrivacyBox"
ENT.Author			= "Dr. Matt"
ENT.Contact			= "mattjeanes23@gmail.com"
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Category		= "Other"

CreateConVar("privacybox_doubletrace", "1", {FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED})
CreateConVar("privacybox_spawnoffset", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED})