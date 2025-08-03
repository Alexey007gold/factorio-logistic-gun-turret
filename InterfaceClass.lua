--
--- includes
local consts = require("consts")
local usrSettings = require("usrSettings")
local lib = require("lib")

--
--- Interface Class
local InterfaceClass = { }
InterfaceClass.__index = InterfaceClass

--
--- constructor
function InterfaceClass.New(entity)
	local self = setmetatable({ }, InterfaceClass)

	entity.request_from_buffers = usrSettings.requestFromBuffers

	self.entity = entity
	self.unitNumber = entity.unit_number
	self.inventory = entity.get_inventory(1)
	self.ammoStorage = { }

    return self
end

--
--- validate interface
function InterfaceClass:IsValid()
	return self.entity ~= nil
	and self.inventory ~= nil
	and self.entity.valid
	and self.inventory.valid
end

--
--- check requester setup
function InterfaceClass:CheckRequesterSetup(player)
	-- check & eventually clamp request slot counts
	local point = self.entity.get_requester_point()
    for i = 1, point.sections_count
    do
        local section = point.get_section(i)
        for j = 1, section.filters_count do
            local current_filter = section.get_slot(j)
            if current_filter.value ~= nil
            then
                local requestedItem = prototypes.item[current_filter.value.name]
                if requestedItem ~= nil
                and requestedItem.type ~= nil
                and requestedItem.type == consts.AMMO_TYPE
                then
                    if current_filter.min > consts.MAX_REQUESTED_ITEMS
                    then
                        section.set_slot(j, {value = current_filter.value,
                                             min = consts.MAX_REQUESTED_ITEMS,
                                             max = current_filter.max })
                    end

                else
                    section.clear_slot(j)
                    local msg =
                    {
                        "",
                        "Logistic Gun Turret warning:\n",
                        "'",
                        requestedItem.localised_name,
                        "' not supported ('ammo' type required).\n",
                        "Request slot cleared."
                    }
                    lib.PrintMsg(player, msg)
                    return
                end
            end
        end
	end
end

--
--- build ammoStorage repository
function InterfaceClass:BuildAmmoStorage()
	self.ammoStorage = { }

	if not lib.IsValid(self.entity)
	then return end

	local point = self.entity.get_requester_point()
    for i = 1, point.sections_count
    do
        local section = point.get_section(i)
        for j = 1, section.filters_count do
            local current_filter = section.get_slot(j)
            if current_filter.value ~= nil
            then
                self.ammoStorage[current_filter.value.name] = { slot = i * j, qty = 0 }
            end
        end
    end
end

--

return InterfaceClass

--
