Config = {}

Config.BankName = 'FLEECA // BSRP'
Config.Subtitle = 'SECURE LEDGER'
Config.InteractKey = 38 -- E
Config.InteractDistance = 1.8
Config.MarkerDistance = 18.0
Config.DrawMarker = true
Config.HistoryLimit = 30

Config.Blip = {
    bank = { enabled = true, sprite = 108, color = 2, scale = 0.75, label = 'Fleeca Bank' },
    atm = { enabled = false, sprite = 277, color = 2, scale = 0.5, label = 'ATM' },
}

Config.Marker = {
    type = 27,
    scale = vector3(0.9, 0.9, 0.4),
    color = { r = 0, g = 229, b = 255, a = 130 },
    bob = false,
    rotate = true,
}

-- Full banks (teller / vault UI)
Config.Banks = {
    { label = 'Legion Square', coords = vector3(149.9, -1040.5, 29.4) },
    { label = 'Hawick Ave', coords = vector3(314.2, -279.0, 54.2) },
    { label = 'Boulevard Del Perro', coords = vector3(-1212.7, -330.6, 37.8) },
    { label = 'Great Ocean Hwy', coords = vector3(-2962.6, 482.9, 15.7) },
    { label = 'Route 68', coords = vector3(1175.0, 2706.8, 38.1) },
    { label = 'Paleto Bay', coords = vector3(-112.2, 6469.3, 31.6) },
}

-- ATM models (auto targets near player)
Config.AtmModels = {
    `prop_atm_01`,
    `prop_atm_02`,
    `prop_atm_03`,
    `prop_fleeca_atm`,
}

Config.QuickAmounts = { 100, 500, 1000, 5000, 10000 }
