Config = {}

-- Chopshop location (where player brings the car to chop)
Config.ChopshopLocation = vec3(-442.04, -2179.74, 9.72)

-- Laptop prop spawn location
Config.LaptopLocation = vec3(-200.1845, -1318.631, 31.0917)
Config.LaptopModel = 'sf_prop_sf_laptop_01b'

-- Number of contracts
Config.ContractCount = 6

-- Cooldown for refresh (seconds)
Config.RefreshCooldown = 120

-- Random car spawn: min/max distance from city center (meters)
Config.CarSpawnMinDist = 500
Config.CarSpawnMaxDist = 2000

-- Chop duration per part (ms)
Config.PartChopDuration = 5000

-- Reward range
Config.MinReward = 650
Config.MaxReward = 3000

-- Parts to remove from the car (in order)
Config.CarParams = {
    { item = 'car_door', label = 'Car Door' },
    { item = 'car_hood', label = 'Car Hood' },
    { item = 'car_battery', label = 'Car Battery' },
    { item = 'catalytic_converter', label = 'Catalytic Converter' },
    { item = 'car_panel', label = 'Car Panel' },
}

-- Required item to lockpick the car
Config.LockpickItem = 'lockpick'

-- Vehicle models for contracts
-- Vehicle models for contracts (all automobiles only)
Config.VehicleModels = {
    -- Compacts
    'asbo', 'blista', 'brioso', 'club', 'dilettante', 'dilettante2',
    'kanjo', 'issi2', 'issi3', 'issi4', 'issi5', 'issi6', 'panto',
    'prairie', 'rhapsody', 'brioso2', 'weevil', 'issi7', 'blista2',
    'blista3', 'brioso3', 'boor',
    -- Sedans
    'asea', 'asterope', 'cog55', 'cognoscenti', 'emperor', 'fugitive',
    'glendale', 'glendale2', 'ingot', 'intruder', 'premier', 'primo',
    'primo2', 'regina', 'stafford', 'stanier', 'stratum', 'stretch',
    'superd', 'surge', 'tailgater', 'warrener', 'washington', 'tailgater2',
    'cinquemila', 'iwagen', 'astron', 'baller7', 'comet7', 'deity',
    'jubilee', 'oracle', 'schafter2', 'warrener2', 'rhinehart', 'eudora',
    'asterope2', 'impaler5',
    -- SUVs
    'baller', 'baller2', 'baller3', 'baller4', 'baller5', 'baller6',
    'bjxl', 'cavalcade', 'cavalcade2', 'contender', 'dubsta', 'dubsta2',
    'fq2', 'granger', 'gresley', 'habanero', 'huntley', 'landstalker',
    'landstalker2', 'novak', 'patriot', 'patriot2', 'radi', 'rebla',
    'rocoto', 'seminole', 'seminole2', 'serrano', 'toros', 'xls',
    'granger2', 'patriot3', 'aleutian', 'baller8', 'cavalcade3',
    'dorado', 'vivanite', 'castigator',
    -- Coupes
    'cogcabrio', 'exemplar', 'f620', 'felon', 'felon2', 'jackal',
    'oracle2', 'sentinel', 'sentinel2', 'windsor', 'windsor2', 'zion',
    'zion2', 'previon', 'champion', 'futo', 'sentinel3', 'kanjosj',
    'postlude', 'tahoma', 'broadway', 'fr36',
    -- Muscle
    'blade', 'buccaneer', 'buccaneer2', 'chino', 'chino2', 'clique',
    'coquette3', 'deviant', 'dominator', 'dominator2', 'dominator3',
    'dominator4', 'dominator7', 'dominator8', 'dukes', 'dukes2',
    'dukes3', 'faction', 'faction2', 'faction3', 'ellie', 'gauntlet',
    'gauntlet2', 'gauntlet3', 'gauntlet4', 'gauntlet5', 'hermes',
    'hotknife', 'hustler', 'impaler', 'impaler2', 'impaler3', 'impaler4',
    'imperator', 'imperator2', 'imperator3', 'lurcher', 'nightshade',
    'phoenix', 'picador', 'ratloader2', 'ruiner', 'ruiner2', 'sabregt',
    'sabregt2', 'slamvan', 'slamvan2', 'slamvan3', 'stalion', 'stalion2',
    'tampa', 'tampa3', 'vigero', 'virgo', 'virgo2', 'virgo3', 'voodoo',
    'voodoo2', 'yosemite', 'hellion', 'greenwood', 'ruiner4', 'vigero2',
    'broadway2', 'hotring3', 'buffalo4', 'buffalo5', 'dominator9',
    'impaler6', 'yosemite3',
}   

-- NPC model
Config.NPCModel = 'a_m_m_business_01'

-- NPC weapons (randomized)
Config.NPCWeapons = {
    'WEAPON_KNIFE', 'WEAPON_BAT', 'WEAPON_CROWBAR',
    'WEAPON_GOLFCLUB', 'WEAPON_HAMMER', 'WEAPON_MOLTOV',
    'WEAPON_PISTOL', 'WEAPON_PISTOL_MK2', 'WEAPON_COMBATPISTOL',
    'WEAPON_APPISTOL', 'WEAPON_MICROSMG', 'WEAPON_SMG',
    'WEAPON_ASSAULTSMG', 'WEAPON_COMBATMG', 'WEAPON_MG',
    'WEAPON_PUMPSHOTGUN', 'WEAPON_SAWNOFF'
}

-- Blip settings
Config.Blip = {
    sprite = 617,       -- wrench icon
    colour = 2,         -- red
    scale = 0.8,
    chopSprite = 435,   -- chopshop icon
    chopColour = 3,     -- blue
}

-- Max distance to interact with car at chopshop
Config.ChopInteractDistance = 5.0   