--
--- migration 1.0.5

if storage.highPrioCheckGuns == nil then
    storage.highPrioCheckGuns = { }
    storage.lgByTurretUnitNumber = { }
end

game.print("Logistic Gun Turret mod migrated to 1.0.5 data pattern.")
