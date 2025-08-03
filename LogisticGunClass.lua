--
--- includes
local lib = require("lib")
local usrSettings = require("usrSettings")

--
--- classes
local Interface = require("InterfaceClass")
local Turret = require("TurretClass")

--
--- Logistic Gun Class
local LogisticGunClass = { }
LogisticGunClass.__index = LogisticGunClass

--
--- constructor
function LogisticGunClass.New(interface, turret)
	local self = setmetatable({ }, LogisticGunClass)

	self.interface = Interface.New(interface)
	self.turret = Turret.New(turret)
	self.invalidCount = 0

    return self
end

--
--- validate a logisticGun
function LogisticGunClass:IsValid()
	return self.interface ~= nil
	and self.turret ~= nil
	and self.interface:IsValid()
	and self.turret:IsValid()
end

--
--- build a ghost interface
local function BuildGhostInterface(interface, turret)
	-- Prevent a rotated blueprint being placed down on the same turret creating another interface.
	-- OR relocate interfaces to the bottom right corner from a rotated blueprint, for consistent visuals.
	if lib.GetInterfaceCount(turret)
	+  lib.GetGhostInterfaceCount(turret) > 1
	then
		-- Prevent another interface being blueprinted onto the turret if the turret already has an associated interface.
		interface.destroy()
		return
	end

	if not lib.IsValid(turret) then return end
	interface.teleport(lib.GetInterfacePosition(turret))
end

--
--- build interface
local function BuildInterface(interface, turret, player)
	-- remove remaining ghost interface around turret if any
	lib.DestroyInterfaces(lib.GetGhostInterfaces(turret))

	if lib.GetInterfaceCount(turret) > 1
	then
		-- mine newly created interface if any already exists
		if lib.IsValid(player)
		then
			player.mine_entity(interface, interface.force)
			interface = lib.GetInterfaces(turret)[1]
		else
            interface = nil
        end
    end

	if not lib.IsValid(interface)
	then return nil end

	lib.CancelDeconstruction(interface)

	if not lib.IsValid(turret) then return end
	interface.teleport(lib.GetInterfacePosition(turret))
    return interface
end

--
--- cleaning entities around turret and return first interface found if any
local function GetInterfaceAround(turret, player)
	-- search for any interface
	local interfaces = lib.GetInterfaces(turret)

	if next(interfaces) ~= nil
	then
		local interface = interfaces[1]

		if not lib.IsValid(interface)
		then return nil end

		-- interface found
		-- eventually cancel deconstruction
		lib.CancelDeconstruction(interface)

		-- remove any remaining ghost interfaces around turret
		lib.DestroyInterfaces(lib.GetGhostInterfaces(turret))

		-- remove other remaining interfaces around turret if any
		if lib.IsValid(player)
		then
			local unitNumber = interface.unit_number
			for _, foundInterface in pairs(interfaces)
			do
				if foundInterface.valid
				and foundInterface.unit_number ~= unitNumber
				then
					player.mine_entity(foundInterface, foundInterface.force)
				end
			end
		end
		return interface
	end

	-- search for any ghost interface
	interfaces = lib.GetGhostInterfaces(turret)
	if next(interfaces) == nil
	then return nil end

	local interface = interfaces[1]
	if lib.IsValid(interface)
	then
		-- ghost interface found
		-- remove any remaining ghost interfaces
		local unitNumber = interface.unit_number
		for _, foundInterface in pairs(interfaces)
		do
			if foundInterface.valid
			and foundInterface.unit_number ~= unitNumber
			then
				foundInterface.destroy()
			end
		end

		return interface
	end

	return nil
end

--
--- build a Logistic Gun
function LogisticGunClass:Build(entity, player)
	--log(serpent.block(entity))
	--log(serpent.block(player))

	-- is player building interface
	if lib.IsInterface(entity)
	or lib.IsGhostInterface(entity)
	then
		local turret = lib.GetAnyTurret(entity)
		if turret == nil
		then return nil end

		-- turret found
		-- eventually cancel turret deconstruction
		lib.CancelDeconstruction(turret)

		if lib.IsGhost(entity)
		then
			BuildGhostInterface(entity, turret)

		else
			local interface = BuildInterface(entity, turret, player)
			if interface ~= nil
			then
				return self.New(interface, turret)
			end
		end

	-- is player building turret
	elseif lib.IsTurret(entity)
	or lib.IsGhostTurret(entity)
	then
		local interface = GetInterfaceAround(entity, player)
		if interface == nil
		then
			lib.AddGhostInterface(entity)
		else
			if not lib.IsValid(entity) then return nil end
			interface.teleport(lib.GetInterfacePosition(entity))
			if not lib.IsGhost(interface)
			then
				return self.New(interface, entity)
			end
		end
	end

    return nil
end

--
--- check if turret should be active
local function CheckActive(turret)
	if turret.entity.active
	then
		turret.entity.active = not turret.inventory.is_empty()
	end
end

--
--- remove ammo from turret
local function RemoveAmmo(self, ammoName, ammoCount)
	local magazines = { name = ammoName, count = ammoCount }
	if not self.interface.inventory.can_insert(magazines)
	then return false end

	magazines.count = self.interface.inventory.insert(magazines)
	return self.turret.inventory.remove(magazines) == magazines.count
end

--
--- insert ammo into turret
local function InsertAmmo(self, ammoName, ammoCount)
	local magazines = { name = ammoName, count = ammoCount }
	if not self.turret.inventory.can_insert(magazines)
	then return false end

	magazines.count = self.turret.inventory.insert(magazines)
	self.turret.entity.active = not self.turret.inventory.is_empty()
	return self.interface.inventory.remove(magazines) == magazines.count
end

--
--- reload turret
function LogisticGunClass:Reload()
	-- early cancel reload if turret has enough of any ammo.
	-- UPS more efficient but a bit less priority management.
	--local turretAmmo, turretAmmoQty = next(self.turret.inventory.get_contents())
	--if turretAmmo
	--and turretAmmoQty >= usrSettings.maxLoadedMagazine
	--then return end

	-- return if interface inventory is empty
	if self.interface.inventory.is_empty()
	then
		CheckActive(self.turret)
		return
	end

	-- update ammo storage repository
	local ammoStorage = self.interface.ammoStorage
	for _, ammo in pairs(ammoStorage)
	do
		ammo.qty = 0
	end
	local interfaceContent = self.interface.inventory.get_contents()
	for _, item in ipairs(interfaceContent)
	do
		if ammoStorage[item.name] ~= nil
		then
			ammoStorage[item.name].qty = item.count
		end
	end

	-- reloading
	local item = self.turret.inventory.get_contents()[1]
	if item ~= nil
	then
		-- turret has ammo inside
        local turretAmmoName = item.name
        local turretAmmoQty = item.count
		local stockedTurretAmmo = ammoStorage[turretAmmoName]

		if stockedTurretAmmo ~= nil
		then
			if stockedTurretAmmo.qty > 0
			then
				for ammoName, stock in pairs(ammoStorage)
				do
					if stock.qty > 0
					then
						if turretAmmoName == ammoName
						then
							-- same ammo type - refill ammo up to max required
							local count = usrSettings.maxLoadedMagazine - turretAmmoQty
							if count > 0
							then
								InsertAmmo(self, ammoName, count)
							end

						else
							-- change ammo type
							if RemoveAmmo(self, turretAmmoName, turretAmmoQty)
							then
								InsertAmmo(self, ammoName, usrSettings.maxLoadedMagazine)
							end
						end
						return
					end
				end

			else
				-- turret has ammo loaded but that ammo is no longer in stock
				for ammoName, stock in pairs(ammoStorage)
				do
					-- if no better ammo then exit - finish magazines
					if stock.slot >= stockedTurretAmmo.slot
					then return end

					if stock.qty > 0
					then
						-- replace with better ammo
						if RemoveAmmo(self, turretAmmoName, turretAmmoQty)
						then
							InsertAmmo(self, ammoName, usrSettings.maxLoadedMagazine)
						end
						return
					end
				end
			end

		else
			-- turret has ammo type that is not requested by interface - remove then reload
			for ammoName, stock in pairs(ammoStorage)
			do
				if stock.qty > 0
				then
					if RemoveAmmo(self, turretAmmoName, turretAmmoQty)
					then
						InsertAmmo(self, ammoName, usrSettings.maxLoadedMagazine)
					end
					return
				end
			end
			-- no requested ammo available - finish magazines
			return
		end

	else
		-- turret is empty - search for any best ammo
		for ammoName, stock in pairs(ammoStorage)
		do
			if stock.qty > 0
			then
				InsertAmmo(self, ammoName, stock.qty >= usrSettings.maxLoadedMagazine and usrSettings.maxLoadedMagazine or stock.qty)
				return
			end
		end

		-- turret could not be reloaded based on priority settings. Select first ammo found in interface.
		for _, item in ipairs(interfaceContent)
		do
			if InsertAmmo(self, item.name, item.count >= usrSettings.maxLoadedMagazine and usrSettings.maxLoadedMagazine or item.count)
			then
				return
			end
		end

		CheckActive(self.turret)
	end
end

--

return LogisticGunClass

--
