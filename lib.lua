--
--- includes
local consts = require("consts")
local usrSettings = require("usrSettings")

--
--- lib
local lib = { }

--
--- message to all players
function lib.BroadcastMsg(msg)
	for _, player in pairs(game.players)
	do
		if player.valid
		then
			player.print(msg)
		end
	end
end

--
--- print message in console chat
function lib.PrintMsg(player, msg)
	if player ~= nil
	and player.valid
	then
		player.print(msg)
	else
		game.print(msg)
	end
end

--
--- check if entity is valid
function lib.IsValid(entity)
	return entity ~= nil
	and entity.valid
end

--- is entity a ghost
function lib.IsGhost(entity)
	return entity ~= nil
	and entity.name == consts.ENTITY_GHOST
end

--
--- is entity a ghost interface
function lib.IsGhostInterface(entity)
	return entity ~= nil
	and lib.IsGhost(entity)
	and entity.ghost_name == consts.TURRET_INTERFACE
end

--
--- is entity an interface
function lib.IsInterface(entity)
	return entity ~= nil
	and entity.name == consts.TURRET_INTERFACE
end

--
--- is entity a ghost turret
function lib.IsGhostTurret(entity)
	return entity ~= nil
	and lib.IsGhost(entity)
	and (entity.ghost_type == consts.AMMO_TURRET or entity.ghost_type == consts.ARTILLERY_TURRET)
end

--
--- is entity a turret
function lib.IsTurret(entity)
	return entity ~= nil
	and not lib.IsGhost(entity)
	and (entity.type == consts.AMMO_TURRET or entity.type == consts.ARTILLERY_TURRET)
end

--
--- is entity a buffer
function lib.IsBuffer(entity)
	return entity ~= nil
	and not lib.IsGhost(entity)
	and entity.name == consts.TURRET_BUFFER
end

--
--- get interface position from turret direction
function lib.GetInterfacePosition(turret)
	local area = turret.selection_box

	if turret.direction == consts.NORTH or turret.direction == consts.WEST
	then
		return { area.right_bottom.x - 0.5, area.right_bottom.y - 0.5 }

	elseif turret.direction == consts.EAST
	then
		return { area.left_top.x, area.right_bottom.y - 0.5 }

	elseif turret.direction == consts.SOUTH
	then
		return { area.left_top.x, area.left_top.y + 0.5 }
	end

	-- default bottom-right
	return { area.right_bottom.x - 0.5, area.right_bottom.y - 0.5 }
end

--
--- get interface count around turret
function lib.GetInterfaceCount(turret)
	if not lib.IsValid(turret)
	then return 0 end

	return turret.surface.count_entities_filtered{ name = consts.TURRET_INTERFACE, area = turret.selection_box }
end

--
--- get interfaces around turret
function lib.GetInterfaces(turret)
	if not lib.IsValid(turret)
	then return { } end

	return turret.surface.find_entities_filtered{ name = consts.TURRET_INTERFACE, area = turret.selection_box }
end

--
--- get ghost interface count around turret
function lib.GetGhostInterfaceCount(turret)
	if not lib.IsValid(turret)
	then return 0 end

	return turret.surface.count_entities_filtered{ name = consts.ENTITY_GHOST, ghost_name = consts.TURRET_INTERFACE, area = turret.selection_box }
end

--
--- get ghost interfaces around turret
function lib.GetGhostInterfaces(turret)
	if not lib.IsValid(turret)
	then return { } end

	return turret.surface.find_entities_filtered{ name = consts.ENTITY_GHOST, ghost_name = consts.TURRET_INTERFACE, area = turret.selection_box }
end

--
--- get all turrets
function lib.GetAllTurrets(surface)
	if not lib.IsValid(surface)
	then return { } end

	return surface.find_entities_filtered{ type = consts.TURRET_TYPES }
end

--
--- get turret around interface
function lib.GetAnyTurret(interface)
	if not lib.IsValid(interface)
	then return nil end

	local position = interface.position

	return
	interface.surface.find_entities_filtered{ type = consts.TURRET_TYPES, position = position }[1]
	or
	interface.surface.find_entities_filtered{ name = consts.ENTITY_GHOST, ghost_type = consts.TURRET_TYPES, position = position }[1]
	or
	nil
end

--
--- eventually cancel deconstruction mark
function lib.CancelDeconstruction(entity)
	if lib.IsValid(entity)
	and not lib.IsGhost(entity)
	and entity.to_be_deconstructed()
	then
		entity.cancel_deconstruction(entity.force)
	end
end

--
--- get any interface type around turret
local function GetAnyInterface(turret)
	if not lib.IsValid(turret)
	then return nil end

	return
	lib.GetInterfaces(turret)[1]
	or
	lib.GetGhostInterfaces(turret)[1]
end

--
--- lay a new ghost interface attached to turret
function lib.AddGhostInterface(turret)
	if not lib.IsValid(turret)
	or consts.blacklist[turret.name] ~= nil
	or not usrSettings.autoInterface
	or not turret.force.technologies[consts.LOGISTIC_TURRETS].researched
	or GetAnyInterface(turret) ~= nil -- skip if turret already has associated interface.
	then return false end

	-- place a ghost interface
	turret.surface.create_entity
	{
		name = consts.ENTITY_GHOST,
		ghost_name = consts.TURRET_INTERFACE,
		position = lib.GetInterfacePosition(turret),
		force = turret.force,
		raise_built = true
	}

	return true
end

--
--- destroy interfaces
function lib.DestroyInterfaces(interfaces)
	if next(interfaces) == nil
	then return end

	for _, interface in pairs(interfaces)
	do
		if interface.valid
		then
			interface.destroy()
		end
	end
end

--
--- get entity requester setup in a table
function lib.GetRequesterSetup(entity)
	local requesterSetup = { }

	if lib.IsValid(entity)
	then
		for slot = 1, entity.request_slot_count
		do
			local requestSlot = entity.get_request_slot(slot)
			if requestSlot ~= nil
			then
				table.insert(requesterSetup, { slot = slot, name = requestSlot.name, count = requestSlot.count })
			else
				table.insert(requesterSetup, { slot = slot, name = "", count = 0 })
			end
		end
	end

	return requesterSetup
end

--
--- write entity requester slot setup
function lib.WriteRequesterSlots(requesterSetup, entity)
	if not lib.IsValid(entity)
	then return end

	for _, requestSlot in pairs(requesterSetup)
	do
		if requestSlot.count > 0
		then
			entity.set_request_slot({ name = requestSlot.name, count = requestSlot.count }, requestSlot.slot)
		else
			entity.clear_request_slot(requestSlot.slot)
		end
	end
end

--
--- update entity requester slots
function lib.UpdateRequesterSlots(sourceEntity, destEntity)
	if not lib.IsValid(sourceEntity)
	or not lib.IsValid(destEntity)
	then return end

	for slot = 1, sourceEntity.request_slot_count
	do
		local requestSlot = sourceEntity.get_request_slot(slot)
		if requestSlot ~= nil
		then
			destEntity.set_request_slot({ name = requestSlot.name, count = requestSlot.count }, slot)
		else
			destEntity.clear_request_slot(slot)
		end
	end
end

--
--- get player from event
function lib.GetPlayer(event)
	return event.player_index ~= nil
	and game.get_player(event.player_index)
	or nil
end

--

return lib

--
