--
--- includes
local consts = require("consts")
local usrSettings = require("usrSettings")
local lib = require("lib")

--
--- classes
local LogisticGun = require("LogisticGunClass")
local Interface = require("InterfaceClass")
local Turret = require("TurretClass")

--
--- Logistic Gun Repository
local lgRepository =
{
	logisticGuns = { }
}

--
--- Init repository
function lgRepository.Init()
	global.logisticGuns = { }						-- initialize global repository
	lgRepository.logisticGuns = global.logisticGuns	-- set local reference to repository
end

--
--- load repository
function lgRepository.Load()
	lgRepository.logisticGuns = global.logisticGuns	-- set local reference to repository

	-- restore metatables
	for _, lg in pairs(lgRepository.logisticGuns)
	do
		setmetatable(lg, { __index = LogisticGun })

		if lg.interface ~= nil
		then
			setmetatable(lg.interface, { __index = Interface })
		end

		if lg.turret ~= nil
		then
			setmetatable(lg.turret, { __index = Turret })
		end
	end
end

--
--- get Logistic Gun
--- polymorphism based on argument type
function lgRepository.Get(arg)
	if arg == nil
	then return nil, nil end

	local type = type(arg)

	if type == "number"
	then
		local lg = lgRepository.logisticGuns[arg]
		if lg ~= nil
		then
			return arg, lg
		end

	elseif type == "table"
	then
		local unitNumber = arg.unit_number
		for k, lg in pairs(lgRepository.logisticGuns)
		do
			if lg.interface ~= nil
			and lg.interface.unitNumber == unitNumber
			then
				return k, lg
			end
		end
	end

	return nil, nil
end

--
--- store interface/turret in repository if not any ghost entity
function lgRepository.Store(lg)
	if lg == nil
	or not lg:IsValid()
	or lib.IsGhost(lg.interface.entity)
	or lib.IsGhost(lg.turret.entity)
	then return end

	local k, _ = lgRepository.Get(lg.interface.entity)
	if k ~= nil
	then
		lgRepository.logisticGuns[k] = lg
		return
	end

	table.insert(lgRepository.logisticGuns, lg)
end

--
--- remove interface/turret from repository
--- polymorphism based on argument type
function lgRepository.Remove(arg)
	if arg == nil
	then return end

	local type = type(arg)
	local k

	if type == "number"
	then
		k = arg

	elseif type == "table"
	then
		k, _ = lgRepository.Get(arg)
	end

	if k ~= nil
	then
		table.remove(lgRepository.logisticGuns, k)
	end
end

--
--- process turret reloading on tick event - workload manager
function lgRepository.ReloadAmmoHandler(event)
	local lg = { }
	for k = #lgRepository.logisticGuns - (event.tick % usrSettings.reloadingPeriod), 1, -usrSettings.reloadingPeriod
	do
		lg = lgRepository.logisticGuns[k]
		if lg ~= nil
		then
			if pcall(lg.Reload, lg)
			then
				lg.invalidCount = 0
			else
				lg.invalidCount = lg.invalidCount + 1
				if lg.invalidCount >= consts.INVALID_TIMEOUT
				then
					lgRepository.Remove(k)
					return
				end
			end
		end
	end
end

--
--- return true if entity is to update in requester setup upload / download
local function IsToUpdate(entity1, entity2, network)
	return entity1.turret.entity.type == entity2.turret.entity.type
	and entity1.turret.entity.name == entity2.turret.entity.name
	and entity1.interface.unitNumber ~= entity2.interface.unitNumber
	and entity1.interface.entity.logistic_network ~= nil
	and entity1.interface.entity.logistic_network == network
end

--
--- broadcast logistic network request slots
function lgRepository.UploadRequesterSetup(sourceLg)
	if sourceLg == nil
	or not sourceLg:IsValid()
	then return end

	local network = sourceLg.interface.entity.logistic_network
	if not lib.IsValid(network)
	then return end

	-- read slots
	local requesterSetup = lib.GetRequesterSetup(sourceLg.interface.entity)

	if next(requesterSetup) ~= nil
	then
		for _, destLg in pairs(lgRepository.logisticGuns)
		do
			if destLg:IsValid()
			and IsToUpdate(destLg, sourceLg, network)
			then
				lib.WriteRequesterSlots(requesterSetup, destLg.interface.entity)
				destLg.interface.entity.request_from_buffers = sourceLg.interface.entity.request_from_buffers
			end
		end
	end
end

--
--- automatically update newly created turret requester from existing network, if any
function lgRepository.DownloadRequesterSetup(destLg)
	if destLg == nil
	or not destLg:IsValid()
	then return end

	local network = destLg.interface.entity.logistic_network
	if not lib.IsValid(network)
	then return end

	for _, sourceLg in pairs(lgRepository.logisticGuns)
	do
		if sourceLg:IsValid()
		and IsToUpdate(sourceLg, destLg, network)
		then
			lib.UpdateRequesterSlots(sourceLg.interface.entity, destLg.interface.entity)
			destLg.interface.entity.request_from_buffers = sourceLg.interface.entity.request_from_buffers
			return
		end
	end
end

--

return lgRepository

--
