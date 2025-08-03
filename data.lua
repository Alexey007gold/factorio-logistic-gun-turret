require("prototypes.entity")
require("prototypes.item")
require("prototypes.recipe")
require("prototypes.technology")

--
--- data
local earlyAvailable = settings.startup["lgt-early-available"].value

if earlyAvailable
then
    data.raw.recipe["turret-interface"].ingredients =
    {
        { "electronic-circuit", 3 },
        { "requester-chest", 1 },
        { "iron-plate", 5 }
    }

    data.raw.recipe["turret-buffer"].ingredients =
    {
        { "electronic-circuit", 6 },
        { "buffer-chest", 1 },
        { "iron-plate", 10 }
    }

    data.raw.technology["logistic-turrets"].prerequisites = { "gun-turret" }
    data.raw.technology["logistic-turrets"].unit =
    {
        count = 100,
        ingredients = { { "automation-science-pack", 1 } },
        time = 1
    }
end
