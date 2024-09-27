local groupPed = nil
local trickOrTreatPeds = {}

function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

Citizen.CreateThread(function()
    local pedModel = GetHashKey(Config.GroupPed.model)

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(100)
    end

    groupPed = CreatePed(4, pedModel, Config.GroupPed.coords.x, Config.GroupPed.coords.y, Config.GroupPed.coords.z, Config.GroupPed.heading, false, true)
    
    if DoesEntityExist(groupPed) then
        print("Ped created successfully!")

        FreezeEntityPosition(groupPed, true)
        SetEntityInvincible(groupPed, true)
        SetBlockingOfNonTemporaryEvents(groupPed, true)

        NetworkRegisterEntityAsNetworked(groupPed)
        pedNetId = NetworkGetNetworkIdFromEntity(groupPed)

        exports.ox_target:addEntity(pedNetId, {
            {
                name = 'groupmenu',
                label = 'Group Menu',
                icon = 'fas fa-users',
                event = 'showGroupMenu',
                distance = 2.0,
            }
        })
    else
        print("Failed to create ped!")
    end
end)

RegisterNetEvent('showGroupMenu', function()
    lib.showContext('group_context')
end)

lib.registerContext({
    id = 'group_context',
    title = 'Group Menu',
    options = {
        {
            title = 'Start a Trick or Treating Group',
            icon = 'users',
            onSelect = function()
                print("Creating group...")
                TriggerServerEvent('trickortreat:createGroup')
            end
        },
        {
            title = 'Invite a Player',
            icon = 'user-plus',
            onSelect = function()
                lib.hideContext()

                local input = lib.inputDialog('Invite Player', {
                    { type = 'input', label = 'Enter Player Server ID', placeholder = 'e.g., 1', required = true, icon = 'user' }
                })

                if input and tonumber(input[1]) then
                    local serverId = tonumber(input[1])
                    print("Inviting player " .. serverId)
                    TriggerServerEvent('trickortreat:invitePlayer', serverId)
                else
                    print("Invalid Server ID.")
                end
            end
        },
        {
            title = 'Disband Group',
            icon = 'trash',
            onSelect = function()
                TriggerServerEvent('trickortreat:disbandGroup')
            end
        },
        {
            title = 'View Group Members',
            icon = 'list',
            onSelect = function()
                TriggerServerEvent('trickortreat:getGroupMembers')
            end
        }
    }
})

RegisterNetEvent('client:notify')
AddEventHandler('client:notify', function(message, type)
    lib.notify({
        title = '🎃 Trick or Treat',
        description = message,
        type = type,
        duration = 5000
    })
end)

RegisterNetEvent('trickortreat:showGroupMembers', function(members)
    local options = {}

    for _, member in ipairs(members) do
        table.insert(options, {
            title = "Kick Player " .. member,
            icon = 'user-minus',
            onSelect = function()
                TriggerServerEvent('trickortreat:kickMember', member)
            end
        })
    end

    lib.registerContext({
        id = 'members_context',
        title = 'Group Members',
        menu = 'group_context',
        options = options
    })

    lib.showContext('members_context')
end)

function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

Citizen.CreateThread(function()
    if Config.TrickOrTreatLocations and type(Config.TrickOrTreatLocations) == "table" then
        for _, location in pairs(Config.TrickOrTreatLocations) do
            exports.ox_target:addBoxZone({
                coords = location.coords,
                size = vec3(1.0, 1.0, 1.0),
                rotation = location.heading,
                options = {
                    {
                        name = 'knockdoor',
                        label = 'Knock on Door',
                        icon = 'fas fa-hand',
                        event = 'trickortreat:knockDoor',
                        distance = 2.0,
                        doorLocation = location.coords
                    }
                }
            })
        end
    else
    end
end)


RegisterNetEvent('trickortreat:knockDoor')
AddEventHandler('trickortreat:knockDoor', function(data)
    local playerPed = PlayerPedId()
    LoadAnimDict("timetable@jimmy@doorknock@")
    TaskPlayAnim(playerPed, "timetable@jimmy@doorknock@", "knockdoor_idle", 8.0, 1.0, -1, 17, 0, 0, 0, 0)
    Wait(3000)
    TriggerServerEvent('trickortreat:spawnNPCAndLoot', data.doorLocation)
end)

RegisterNetEvent('trickortreat:spawnNPCAndLootClient')
AddEventHandler('trickortreat:spawnNPCAndLootClient', function(npcModel, npcCoords, npcHeading)
    local pedModel = GetHashKey(npcModel)
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(100)
    end
    local foundGround, groundZ = GetGroundZFor_3dCoord(npcCoords.x, npcCoords.y, npcCoords.z, false)
    if not foundGround then
        groundZ = npcCoords.z
    end
    local ped = CreatePed(4, pedModel, npcCoords.x, npcCoords.y, groundZ, npcHeading, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true) 
    trickOrTreatPeds[#trickOrTreatPeds+1] = ped
    LoadAnimDict("mp_safehouselost@")
    TaskPlayAnim(ped, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
    local playerPed = PlayerPedId()
    TaskPlayAnim(playerPed, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
    Wait(4000)
    DeleteEntity(ped)
end)

