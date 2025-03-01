--
--- Turret Class
local TurretClass = { }
TurretClass.__index = TurretClass

--
--- constructor
function TurretClass.New(entity)
	local self = setmetatable({ }, TurretClass)

    self.entity = entity
    self.inventory = entity.get_inventory(1)

    return self
end

--
--- validate turret
function TurretClass:IsValid()
	return self.entity ~= nil
	and self.inventory ~= nil
	and self.entity.valid
	and self.inventory.valid
end

--

return TurretClass

--
