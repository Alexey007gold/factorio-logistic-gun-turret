--
--- includes
local consts = require("consts")

--
--- User Settings
local usrSettings =
{
    requestFromBuffers		= consts.REQUEST_FROM_BUFFERS,
    maxLoadedMagazine     	= consts.MAX_LOADED_MAGAZINES,
    autoInterface         	= consts.AUTO_INTERFACE,
    broadcastRequestSlots 	= consts.BROADCAST_REQUEST_SLOTS,
    reloadingPeriod         = consts.RELOADING_PERIOD
}

--
--- get user settings
function usrSettings.GetSettings()
    usrSettings.requestFromBuffers		= settings.startup[consts.LGT_REQUEST_FROM_BUFFERS].value or consts.REQUEST_FROM_BUFFERS
    usrSettings.maxLoadedMagazine     	= settings.startup[consts.LGT_LOADED_MAGAZINES].value or consts.MAX_LOADED_MAGAZINES
    usrSettings.autoInterface         	= settings.startup[consts.LGT_AUTO_INTERFACE].value or consts.AUTO_INTERFACE
    usrSettings.broadcastRequestSlots 	= settings.startup[consts.LGT_BROADCAST_REQUEST_SLOTS].value or consts.BROADCAST_REQUEST_SLOTS
    usrSettings.reloadingPeriod      	= settings.startup[consts.LGT_RELOADING_PERIOD].value or consts.RELOADING_PERIOD
end

--

return usrSettings

--
