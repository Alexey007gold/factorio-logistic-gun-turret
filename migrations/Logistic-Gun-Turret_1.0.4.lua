--
--- migration 1.0.4

--
-- rebuild turret buffer repository
storage.turretBuffers = { }

if storage.buffers
then
    -- remove duplicates if any
    local hash = { }
    local res = { }
    for _, entity in pairs(storage.buffers) do
        if not hash[entity] then
            table.insert(res, entity)
            hash[entity] = true
        end
    end
    storage.buffers = res

    for _, entity in pairs(storage.buffers)
    do
        local turretBuffer =
        {
            entity = entity,
            unitNumber = entity.unit_number
        }
        table.insert(storage.turretBuffers, turretBuffer)
    end
    storage.buffers = nil
end

--
--- remove duplicates LGTs if any
local hash = { }
local res = { }
for _, lg in pairs(storage.logisticGuns) do
    if not hash[lg] then
        table.insert(res, lg)
        hash[lg] = true
    end
end
storage.logisticGuns = res

game.print("Logistic Gun Turret mod migrated to 1.0.4 data pattern.")
