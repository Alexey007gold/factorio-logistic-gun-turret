local interface =
{
    type = "logistic-container",
	name = "turret-interface",
	icon = "__Logistic-Gun-Turret__/graphics/gun-turret-icon.png",
	icon_size = 32,
	flags = { "placeable-player", "player-creation", "hide-alt-info" },
	-- flags = { "placeable-player", "player-creation" },
	minable = { mining_time = 0.5, result = "turret-interface" },
	max_health = 400,
	-- compatibility with "Wall Blocks Spitters" mod overriding all turret collision_mask to "layer-13"
	--collision_mask = { "layer-11" }, -- base changed to 15
	collision_mask = { layers={ } },
	collision_box = { { -0.35, -0.35 }, { 0.35, 0.35 } },
	selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
	selection_priority = 100,
	resistances =
	{
		{ type = "fire", percent = 90 },
		{ type = "impact", percent = 60 }
	},
	inventory_size = 10,
    logistic_mode = "requester",
	logistic_slots_count = 3,
	squeak_behaviour = false,
	scale_info_icons = true
}

local chestRequester = table.deepcopy(data.raw["logistic-container"]["requester-chest"])

-- explicitly only copy these properties to avoid errors when a mod mutates the base prototype
interface.animation = chestRequester.animation
interface.corpse = chestRequester.corpse
interface.open_sound = chestRequester.open_sound
interface.close_sound = chestRequester.close_sound
interface.vehicle_impact_sound = chestRequester.vehicle_impact_sound
interface.opened_duration = chestRequester.opened_duration
interface.circuit_wire_connection_point = chestRequester.circuit_wire_connection_point
interface.circuit_connector_sprites = chestRequester.circuit_connector_sprites
interface.circuit_wire_max_distance = chestRequester.circuit_wire_max_distance

data:extend{interface}

--

local buffer =
{
    type = "logistic-container",
	name = "turret-buffer",
	icon = "__Logistic-Gun-Turret__/graphics/gun-turret-icon.png",
	icon_size = 32,
	flags = { "placeable-player", "player-creation", "hide-alt-info" },
	-- flags = { "placeable-player", "player-creation" },
	minable = { mining_time = 0.5, result = "turret-buffer" },
	max_health = 400,
	-- compatibility with "Wall Blocks Spitters" mod overriding all turret collision_mask to "layer-13"
	--collision_mask = { "layer-11" }, -- base changed to 15
	collision_mask = { layers={ } },
	collision_box = { { -0.35, -0.35 }, { 0.35, 0.35 } },
	selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
	selection_priority = 100,
	resistances =
	{
		{ type = "fire", percent = 90 },
		{ type = "impact", percent = 60 }
	},
	inventory_size = 20,
    logistic_mode = "buffer",
	logistic_slots_count = 20,
	squeak_behaviour = false,
	scale_info_icons = true
}

local chestBuffer = table.deepcopy(data.raw["logistic-container"]["buffer-chest"])

-- explicitly only copy these properties to avoid errors when a mod mutates the base prototype
buffer.animation = chestBuffer.animation
buffer.corpse = chestBuffer.corpse
buffer.open_sound = chestBuffer.open_sound
buffer.close_sound = chestBuffer.close_sound
buffer.vehicle_impact_sound = chestBuffer.vehicle_impact_sound
buffer.opened_duration = chestBuffer.opened_duration
buffer.circuit_wire_connection_point = chestBuffer.circuit_wire_connection_point
buffer.circuit_connector_sprites = chestBuffer.circuit_connector_sprites
buffer.circuit_wire_max_distance = chestBuffer.circuit_wire_max_distance

data:extend{buffer}

--
