--
--- includes
local lib = require("lib")

--
--- included classes
local TurretBuffer = require("TurretBufferClass")

--
--- Turret Buffer Repository
local tbRepository =
{
	turretBuffers = { }
}

--
--- Init repository
function tbRepository.Init()
	global.turretBuffers = { }				    		-- initialize buffers repository
	tbRepository.turretBuffers = global.turretBuffers  	-- set local reference to buffers repository
end

--
--- load repository
function tbRepository.Load()
	tbRepository.turretBuffers = global.turretBuffers	-- set local reference to buffers repository
	-- restore metatables
	for _, tb in pairs(tbRepository.turretBuffers)
	do
		setmetatable(tb, { __index = TurretBuffer })
	end
end

--
--- get Turret Buffer
--- polymorphism based on argument type
function tbRepository.Get(arg)
	if arg == nil
	then return nil, nil end

	local type = type(arg)

	if type == "number"
	then
		local tb = tbRepository.turretBuffers[arg]
		if tb ~= nil
		then
			return arg, tb
		end

	elseif type == "table"
	then
		local unitNumber = arg.unit_number
		for k, tb in pairs(tbRepository.turretBuffers)
		do
			if tb.unitNumber == unitNumber
			then
				return k, tb
			end
		end
	end

	return nil, nil
end

--
--- store a buffer
function tbRepository.Store(turretBuffer)
	if turretBuffer == nil
	or not turretBuffer:IsValid()
	or lib.IsGhost(turretBuffer.entity)
	then return end

	local k, _ = tbRepository.Get(turretBuffer.entity)
	if k ~= nil
	then
		tbRepository.turretBuffers[k] = turretBuffer
		return
	end

	table.insert(tbRepository.turretBuffers, turretBuffer)
end

--
--- remove a buffer
function tbRepository.Remove(arg)
	if arg == nil
	then return end

	local type = type(arg)
	local k

	if type == "number"
	then
		k = arg

	elseif type == "table"
	then
		k, _ = tbRepository.Get(arg)
	end

	if k ~= nil
	then
		table.remove(tbRepository.turretBuffers, k)
	end
end

--
--- return true if entity is to update in requester setup upload / download
local function IsToUpdate(entity1, entity2, network)
	return entity1.unitNumber ~= entity2.unitNumber
	and entity1.entity.logistic_network ~= nil
	and entity1.entity.logistic_network == network
end

--
--- broadcast (upload) logistic network request slots
function tbRepository.UploadRequesterSetup(sourceBuffer)
	if sourceBuffer == nil
	or not sourceBuffer:IsValid()
	then return end

	local network = sourceBuffer.entity.logistic_network
	if not lib.IsValid(network)
	then return end

	-- read slots
	local requesterSetup = lib.GetRequesterSetup(sourceBuffer.entity)

	if next(requesterSetup) ~= nil
	then
		for _, destBuffer in pairs(tbRepository.turretBuffers)
		do
			if destBuffer:IsValid()
			and IsToUpdate(destBuffer, sourceBuffer, network)
			then
				-- write slots
				lib.WriteRequesterSlots(requesterSetup, destBuffer.entity)
			end
		end
	end
end

--
--- update (download) newly created buffer request slots from existing network, if any
function tbRepository.DownloadRequesterSetup(destBuffer)
	if destBuffer == nil
	or not destBuffer:IsValid()
	then return end

	local network = destBuffer.entity.logistic_network
	if not lib.IsValid(network)
	then return end

	for _, sourceBuffer in pairs(tbRepository.turretBuffers)
	do
		if sourceBuffer:IsValid()
		and IsToUpdate(sourceBuffer, destBuffer, network)
		then
			lib.UpdateRequesterSlots(sourceBuffer.entity, destBuffer.entity)
			return
		end
	end
end

--

return tbRepository

--
