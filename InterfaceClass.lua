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
	for slot = 1, self.entity.request_slot_count
	do
		local requestSlot = self.entity.get_request_slot(slot)
		if requestSlot ~= nil
		then
			local requestedItem = game.item_prototypes[requestSlot.name]
			if requestedItem ~= nil
			and requestedItem.type ~= nil
			and requestedItem.type == consts.AMMO_TYPE
			then
				if requestSlot.count > consts.MAX_REQUESTED_ITEMS
				then
					self.entity.set_request_slot({ name = requestSlot.name, count = consts.MAX_REQUESTED_ITEMS }, slot)
				end

			else
				self.entity.clear_request_slot(slot)
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

--
--- build ammoStorage repository
function InterfaceClass:BuildAmmoStorage()
	self.ammoStorage = { }

	if not lib.IsValid(self.entity)
	then return end

	local requestSlot = { }
	for slot = 1, self.entity.request_slot_count
	do
		requestSlot = self.entity.get_request_slot(slot)
		if requestSlot ~= nil
		then
			self.ammoStorage[requestSlot.name] = { slot = slot, qty = 0 }
		end
	end
end

--

return InterfaceClass

--
