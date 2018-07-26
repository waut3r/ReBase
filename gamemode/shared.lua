AddCSLuaFile("libraries/glua.lua")
include("libraries/glua.lua")

glua.IncludeFiles(
    DOMAIN_SHARED,
    "rename/entity.lua",
    "rename/player.lua",
    "libraries/debug.lua",
    "libraries/math.lua",
    "classes/color.lua"
)

debug.Print("ReBase has fully loaded")
