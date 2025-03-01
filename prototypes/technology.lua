data:extend(
{
	{
		type = "technology",
		name = "logistic-turrets",
		icon = "__Logistic-Gun-Turret__/graphics/turrets.png",
		icon_size = 128,
		effects =
		{
			{ type = "unlock-recipe", recipe = "turret-interface" },
			{ type = "unlock-recipe", recipe = "turret-buffer" }
		},
		prerequisites = { "gun-turret", "logistic-robotics" },
		unit =
		{
			count = 100,
			ingredients =
			{
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "production-science-pack", 1 }
			},
			time = 10
		},
		order = "a-j-b"
	}
})
