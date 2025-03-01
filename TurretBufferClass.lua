--
--- Turret Buffer Class
local TurretBufferClass = { }
TurretBufferClass.__index = TurretBufferClass

--
--- constructor
function TurretBufferClass.New(entity)
	local self = setmetatable({ }, TurretBufferClass)

	self.entity = entity
	self.unitNumber = entity.unit_number

    return self
end

--
--- validate buffer
function TurretBufferClass:IsValid()
	return self.entity ~= nil
	and self.entity.valid
end

--

return TurretBufferClass

--
