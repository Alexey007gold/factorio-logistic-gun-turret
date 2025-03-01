--
-- includes
local consts = require("consts")
local usrSettings = require("usrSettings")
local lib = require("lib")
local lgRepository = require("logisticGunRepository")
local tbRepository = require("turretBufferRepository")

--
--- classes
local LogisticGun = require("LogisticGunClass")
local TurretBuffer = require("TurretBufferClass")

--
--- Events Handler
local eventsHandler = { }

--
--- enable recipe if tech already researched
local function EnableRecipes()
	for _, force in pairs(game.forces)
	do
		for tech, recipes in pairs(consts.TECH_RECIPE)
		do
			if force.technologies[tech].researched
			then
				for _, recipe in pairs(recipes)
				do
					force.recipes[recipe].enabled = true
				end
			end
		end
	end
end

--
--- update all turrets
local function UpdateTurrets()
	if not usrSettings.autoInterface
	then return end

	local count = 0
	for _, surface in pairs(game.surfaces)
	do
		for _, turret in pairs(lib.GetAllTurrets(surface))
		do
			if lib.AddGhostInterface(turret)
			then
				count = count + 1
			end
		end
	end
	if count > 0
	then
		lib.BroadcastMsg("Logistic Gun Turret: " .. count .. " turrets upgraded.")
	end
end

--
--- on_init handler
function eventsHandler.OnInitHandler()
	usrSettings.GetSettings()
	lgRepository.Init()
	tbRepository.Init()
end

--
--- on_load handler
function eventsHandler.OnLoadHandler()
	usrSettings.GetSettings()
	lgRepository.Load()
	tbRepository.Load()
end

--
--- on_configuration_changed handler
function eventsHandler.ConfigurationChangedHandler()
	EnableRecipes()	-- eventually enable recipe if already researched
	UpdateTurrets()	-- eventually upgrade existing turrets
end

--
--- build entity handler
function eventsHandler.BuildEntityHandler(event)
	local entity = event.created_entity or event.entity
	if not lib.IsValid(entity)
	then return end

	-- check if create ghost interface or interface or ghost turret or turret
	if lib.IsGhostInterface(entity)
	or lib.IsInterface(entity)
	or lib.IsGhostTurret(entity)
	or lib.IsTurret(entity)
	then
		--local logisticGun = LogisticGun:Build(entity, lib.GetPlayer(event))
		local status, logisticGun = pcall(LogisticGun.Build, LogisticGun, entity, lib.GetPlayer(event))
		--log(serpent.block(status))
		--log(serpent.block(logisticGun))
		if status == false then return end
		if logisticGun ~= nil
		then
			lgRepository.DownloadRequesterSetup(logisticGun)
			logisticGun.interface:BuildAmmoStorage()
			lgRepository.Store(logisticGun)
		end

	elseif lib.IsBuffer(entity)
	then
		local turretBuffer = TurretBuffer.New(entity)
		tbRepository.DownloadRequesterSetup(turretBuffer)
		tbRepository.Store(turretBuffer)
    end
end

--
--- mined entity handler
function eventsHandler.MinedEntityHandler(event)
	local entity = event.entity
	if not lib.IsValid(entity)
	then return end

	if lib.IsTurret(entity)
	then
		-- destroy any ghost interface
		lib.DestroyInterfaces(lib.GetGhostInterfaces(entity))

        -- mine interface if any and if turret mined by player
        local interface = lib.GetInterfaces(entity)[1]
        if lib.IsValid(interface)
        then
            local player = lib.GetPlayer(event)
            if lib.IsValid(player)
            then
                -- mine interface
				-- will be removed from repository when interface removal event fires
				player.mine_entity(interface, interface.force)
            end
        end

	elseif lib.IsInterface(entity)
	then
        lgRepository.Remove(entity)

	elseif lib.IsBuffer(entity)
    then
        tbRepository.Remove(entity)
	end
end

--
--- check setup when interface GUI is closed
function eventsHandler.GUIClosedHandler(event)
	local entity = event.entity
	if not lib.IsValid(entity)
	then return end

	if lib.IsInterface(entity)
	then
		-- get Logistic Gun associated to interface
		local _, logisticGun = lgRepository.Get(entity)
		if logisticGun == nil
		or not logisticGun:IsValid()
		then return	end

		-- check requester user setup
		logisticGun.interface:CheckRequesterSetup(lib.GetPlayer(event))

		-- update interface ammo storage repository
		logisticGun.interface:BuildAmmoStorage()

		-- conditionnaly broadcast setup to other interfaces in the same logistic network
		if usrSettings.broadcastRequestSlots
		then
			lgRepository.UploadRequesterSetup(logisticGun)
		end

	elseif lib.IsBuffer(entity)
	then
		local _, turretBuffer = tbRepository.Get(entity)
		if turretBuffer == nil
		or not turretBuffer:IsValid()
		then return	end

		if usrSettings.broadcastRequestSlots
		then
			tbRepository.UploadRequesterSetup(turretBuffer)
		end
	end
end

--
--- logistic turrets research ended
function eventsHandler.ResearchFinishedHandler(event)
	if (event.research.name == consts.LOGISTIC_TURRETS)
	and usrSettings.autoInterface
	then
		lib.BroadcastMsg("Logistic Turrets research ended. Upgrading.")
		UpdateTurrets()
	end
end

--

return eventsHandler

--
