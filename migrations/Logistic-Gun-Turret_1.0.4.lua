--
--- migration 1.0.4

--
-- rebuild turret buffer repository
global.turretBuffers = { }

if global.buffers
then
    -- remove duplicates if any
    local hash = { }
    local res = { }
    for _, entity in pairs(global.buffers) do
        if not hash[entity] then
            table.insert(res, entity)
            hash[entity] = true
        end
    end
    global.buffers = res

    for _, entity in pairs(global.buffers)
    do
        local turretBuffer =
        {
            entity = entity,
            unitNumber = entity.unit_number
        }
        table.insert(global.turretBuffers, turretBuffer)
    end
    global.buffers = nil
end

--
--- remove duplicates LGTs if any
local hash = { }
local res = { }
for _, lg in pairs(global.logisticGuns) do
    if not hash[lg] then
        table.insert(res, lg)
        hash[lg] = true
    end
end
global.logisticGuns = res

game.print("Logistic Gun Turret mod migrated to 1.0.4 data pattern.")
