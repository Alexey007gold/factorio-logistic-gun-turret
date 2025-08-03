data:extend(
{
	{
		type = "recipe",
		name = "turret-interface",
		enabled = false,
		energy_required = 10,
		ingredients =
		{
			{ type="item", name="requester-chest", amount=1 },
			{ type="item", name="steel-plate", amount=18 },
			{ type="item", name="electronic-circuit", amount=6 },
			{ type="item", name="advanced-circuit", amount=1 }
		},
		results = {
            { type="item", name="turret-interface", amount = 1 }
        }
	},
	{
		type = "recipe",
		name = "turret-buffer",
		enabled = false,
		energy_required = 20,
		ingredients =
		{
			{ type="item", name="buffer-chest", amount=1 },
			{ type="item", name="steel-plate", amount=36 },
			{ type="item", name="electronic-circuit", amount=12 },
			{ type="item", name="advanced-circuit", amount=2 }
		},
        results = {
            { type="item", name="turret-buffer", amount = 1 }
        }
	}
})
