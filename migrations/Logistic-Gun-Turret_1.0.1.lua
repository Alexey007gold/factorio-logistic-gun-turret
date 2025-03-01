--
--- migration 1.0.1

-- purge old vars
global.lgts = nil
global.earlyAvailable = nil
global.defaultRequestedItems = nil
global.maxLoadedMagazine = nil
global.autoInterface = nil
global.usrSettings = nil

--
--- rebuild clean class oriented repository
global.logisticGuns = { }
local turretFoundCount = 0
for _, surface in pairs(game.surfaces)
do
    for _, interface in pairs(surface.find_entities_filtered{ name = "turret-interface" })
    do
        if interface
        and interface.valid
        then
            local turret = interface.surface.find_entities_filtered{ type = { "ammo-turret", "artillery-turret" }, position = interface.position }[1]
            if turret
            and turret.valid
            then
                local i =
                {
                    entity = interface,
                    unitNumber = interface.unit_number,
                    inventory = interface.get_inventory(1),
                    ammoStorage = { }
                }

                local t =
                {
                    entity = turret,
                    inventory = turret.get_inventory(1)
                }

                local lg =
                {
                    interface = i,
                    turret = t,
                    invalidCount = 0
                }
                table.insert(global.logisticGuns, lg)
                turretFoundCount = turretFoundCount + 1
            end
        end
    end
end

--
-- rebuild ammo Storage
local errorCount = 0
local ammoStorageCount = 0
for key, lg in pairs(global.logisticGuns)
do
    if lg.interface
    and lg.interface.entity
    and lg.interface.entity.valid
	then
		lg.interface.ammoStorage = { }
		for slot = 1, lg.interface.entity.request_slot_count
		do
            local requestSlot = lg.interface.entity.get_request_slot(slot)
			if requestSlot
			then
                if requestSlot.count > 100
                then
                    lg.interface.entity.set_request_slot({ name = requestSlot.name, count = 100 }, slot)
                end

                lg.interface.ammoStorage[requestSlot.name] = { slot = slot, qty = 0 }
			end
        end
        ammoStorageCount = ammoStorageCount + 1
    else
		errorCount = errorCount + 1
		table.remove(global.logisticGuns, key)
	end
end

-- eventually add repository for buffers
if not global.buffers
then
    global.buffers = { }
end

game.print("Logistic Gun Turret mod migrated to 1.0.1 data pattern.")
game.print(turretFoundCount .. " Logistic Gun Turrets found.")
game.print(ammoStorageCount .. " Logistic Gun Turrets successfully configured.")

if errorCount > 0
then
    game.print(errorCount .. " invalid Logistic Gun Turrets have been deactivated.")
else
    game.print("No invalid Logistic Gun Turrets found.")
end
