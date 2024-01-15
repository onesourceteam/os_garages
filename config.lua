
Config = {}

Config.Garages = {
    [1] = { 
        ['coords'] = vec3(-340.75,266.64,85.68), 
        ['name'] = "Garagem",
        ['slots'] = {
            vec4(-329.74,274.20,85.44,93.80),
            vec4(-329.88,277.63,85.43,93.80)
        }
    },
    [2] = { 
        ['coords'] = vec3(458.72,-1007.92,28.27), 
        ['name'] = "Policia", 
        ['perm'] = "policia.permissao",
        ['slots'] = {
            vec4(446.13,-1026.26,28.65,10.2),
            vec4(442.41,-1027.45,28.73,10.2)
        }
    }
}

Config.Vehicles = {
    ["Policia"] = {
        "t20",
        "zentorno",
        "nero"
    }
}