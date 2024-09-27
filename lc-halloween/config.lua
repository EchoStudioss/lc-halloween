Config = {
    LootPool = {
        { item = "candy_corn", min = 1, max = 3, chance = 70 },
        { item = "chocolate_bar", min = 1, max = 2, chance = 50 },
        { item = "lacedcandy", chance = 30 }
    },
    TrickOrTreatLocations = {
        { coords = vector3(-834.22, -1107.65, 9.07), heading = 298.28 },
        { coords = vector3(168.49, -1007.48, 29.2), heading = 118.85 }
        -- Add more door locations as needed
    },
    GroupPed = {
        model = 'a_m_m_hillbilly_01',
        coords = vector3(165.74, -1005.63, 29.36), 
        heading = 325.59,
    },
    GroupRadius = 10.0 -- Radius in which group members must be present to share loot
}
