--
--- Constants & Vars
local consts = { }

--
--- consts
consts.LOGISTIC_TURRETS				= "logistic-turrets"
consts.TURRET_INTERFACE				= "turret-interface"
consts.TURRET_BUFFER				= "turret-buffer"
consts.TECH_RECIPE					= { [consts.LOGISTIC_TURRETS] = { consts.TURRET_INTERFACE, consts.TURRET_BUFFER } }

consts.AMMO_TYPE					= "ammo"
consts.AMMO_TURRET					= "ammo-turret"
consts.ARTILLERY_TURRET				= "artillery-turret"
consts.TURRET_TYPES					= { consts.AMMO_TURRET, consts.ARTILLERY_TURRET }

consts.ENTITY_GHOST					= "entity-ghost"

consts.MAX_REQUESTED_ITEMS			= 100	-- default max items that can be requested

consts.INVALID_TIMEOUT				= 25	-- time-out before removing invalid lg from repository (nb of unsuccessful reload try)

consts.NORTH						= defines.direction.north
consts.EAST							= defines.direction.east
consts.SOUTH 						= defines.direction.south
consts.WEST							= defines.direction.west

-- default settings values
consts.LGT_REQUEST_FROM_BUFFERS 	= "lgt-request-from-buffers"
consts.REQUEST_FROM_BUFFERS			= false
consts.LGT_LOADED_MAGAZINES 		= "lgt-loaded-magazines"
consts.MAX_LOADED_MAGAZINES			= 3
consts.LGT_AUTO_INTERFACE 			= "lgt-auto-interface"
consts.AUTO_INTERFACE				= false
consts.LGT_BROADCAST_REQUEST_SLOTS 	= "lgt-broadcast--request-slots"
consts.BROADCAST_REQUEST_SLOTS  	= false
consts.LGT_RELOADING_PERIOD		 	= "lgt-reloading-period"
consts.RELOADING_PERIOD 			= 150	-- default reloading period in game ticks (2.5s)

--
--- vars
consts.blacklist =
{
	["cutscene-gun-turret"]					= true,
	["vehicle-gun-turret"] 					= true,
	["vehicle-gun-turretv2"] 				= true,
	["vehicle-gun-turretv3"] 				= true,
	["vehicle-rocket-turret"] 				= true,
	["vehicle-rocket-turretv2"] 			= true,
	["vehicle-rocket-turretv3"] 			= true,
	["ion-cannon-targeter"]		 			= true,
	["se-meteor-defence-container"]			= true,
	["se-meteor-point-defence-container"]	= true,
	--["<other-turret-to-be-blacklisted>"] = true,
}

--

return consts

--
