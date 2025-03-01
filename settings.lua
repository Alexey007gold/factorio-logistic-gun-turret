--
--- settings
data:extend(
{
    {
        name = "lgt-early-available",
        type = "bool-setting",
        setting_type = "startup",
        default_value = false,
        order = "a"
    },
    {
        name = "lgt-auto-interface",
        type = "bool-setting",
        setting_type = "startup",
        default_value = true,
        order = "b"
    },
    {
        name = "lgt-reloading-period",
        type = "int-setting",
        setting_type = "startup",
        default_value = 150,
        minimum_value = 60,
        maximum_value = 300,
        order = "c"
    },
    {
        name = "lgt-loaded-magazines",
        type = "int-setting",
        setting_type = "startup",
        default_value = 3,
        minimum_value = 1,
        maximum_value = 10,
        order = "d"
    },
    {
        name = "lgt-broadcast--request-slots",
        type = "bool-setting",
        setting_type = "startup",
        default_value = false,
        order = "e"
    },
    {
        name = "lgt-request-from-buffers",
        type = "bool-setting",
        setting_type = "startup",
        default_value = false,
        order = "f"
    }
})
