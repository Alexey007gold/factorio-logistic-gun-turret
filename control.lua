--
--- Logistic Gun Turret
---
--- Adds to game:
--- 	a Turret Interface that attaches to gun turrets, to keep them stocked with ammo.
--- 	a Turret Buffer as storage proxy for Turret Interfaces.
---
--- by Bl4ckmail / Robokat / CaptainWHot
---

--
--- includes
local consts = require("consts")
local eventsHandler = require("eventsHandler")
local lgRepository = require("logisticGunRepository")

--
--- Control

--
--- set startup events handlers
script.on_init(eventsHandler.OnInitHandler)
script.on_load(eventsHandler.OnLoadHandler)
script.on_configuration_changed(eventsHandler.ConfigurationChangedHandler)

--
--- events filters
local playerBuiltFilter =
{
	{ filter = "ghost_type", type = consts.AMMO_TURRET },
	{ filter = "type", type = consts.AMMO_TURRET },

	{ filter = "ghost_type", type = consts.ARTILLERY_TURRET },
	{ filter = "type", type = consts.ARTILLERY_TURRET },

	{ filter = "ghost_name", name = consts.TURRET_INTERFACE },
	{ filter = "name", name = consts.TURRET_INTERFACE },

	{ filter = "name", name = consts.TURRET_BUFFER }
}

local defaultFilter =
{
	{ filter = "type", type = consts.AMMO_TURRET },
	{ filter = "type", type = consts.ARTILLERY_TURRET },
	{ filter = "name", name = consts.TURRET_INTERFACE },
	{ filter = "name", name = consts.TURRET_BUFFER }
}

--
-- built event handling
script.on_event(defines.events.on_built_entity, eventsHandler.BuildEntityHandler, playerBuiltFilter)
script.on_event(defines.events.on_robot_built_entity, eventsHandler.BuildEntityHandler, defaultFilter)
script.on_event(defines.events.script_raised_built, eventsHandler.BuildEntityHandler, defaultFilter)
script.on_event(defines.events.script_raised_revive, eventsHandler.BuildEntityHandler, defaultFilter)

--
-- mined event handling
script.on_event(defines.events.on_pre_player_mined_item, eventsHandler.MinedEntityHandler, defaultFilter)
script.on_event(defines.events.on_robot_pre_mined, eventsHandler.MinedEntityHandler, defaultFilter)
script.on_event(defines.events.on_entity_died, eventsHandler.MinedEntityHandler, defaultFilter)
script.on_event(defines.events.script_raised_destroy, eventsHandler.MinedEntityHandler, defaultFilter)

--
-- research finished event handling
script.on_event(defines.events.on_research_finished, eventsHandler.ResearchFinishedHandler)

--
-- interface gui closed event handling
script.on_event(defines.events.on_gui_closed, eventsHandler.GUIClosedHandler)

--
-- on_tick event handling
script.on_event(defines.events.on_tick, lgRepository.ReloadAmmoHandler)

--
