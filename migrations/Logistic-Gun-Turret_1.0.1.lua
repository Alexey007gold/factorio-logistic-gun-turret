--
--- migration 1.0.1

-- purge old vars
storage.lgts = nil
storage.earlyAvailable = nil
storage.defaultRequestedItems = nil
storage.maxLoadedMagazine = nil
storage.autoInterface = nil
storage.usrSettings = nil

--
--- rebuild clean class oriented repository
storage.logisticGuns = { }
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
                table.insert(storage.logisticGuns, lg)
                turretFoundCount = turretFoundCount + 1
            end
        end
    end
end

--
-- rebuild ammo Storage
local errorCount = 0
local ammoStorageCount = 0
for key, lg in pairs(storage.logisticGuns)
do
    if lg.interface
    and lg.interface.entity
    and lg.interface.entity.valid
	then
		lg.interface.ammoStorage = { }
		local point = lg.interface.entity.get_requester_point()
        for i = 1, point.sections_count
		do
            local section = point.get_section(i)
            for j = 1, section.filters_count do
                local current_filter = section.get_slot(j)
                if current_filter.name ~= nil
                then
                    if section.count > 100
                    then
                        lg.interface.entity.set_slot(j, {value = current_filter.value,
                                                         min = 100,
                                                         max = current_filter.max })
                    end

                    lg.interface.ammoStorage[current_filter.value.name] = { slot = i, qty = 0 }
                end
            end
        end
        ammoStorageCount = ammoStorageCount + 1
    else
		errorCount = errorCount + 1
		table.remove(storage.logisticGuns, key)
	end
end

-- eventually add repository for buffers
if not storage.buffers
then
    storage.buffers = { }
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
