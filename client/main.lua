local QBCore = exports['qb-core']:GetCoreObject()
local uiOpen = false
local currentContracts = {}
local cooldownEnd = 0
local laptopProp = nil
local activeContract = nil
local contractVehicle = nil
local contractNPC = nil
local blipChop = -1
local chopState = nil
local isBusy = false
local vehicleStolen = false

-- Predefined parking/garage spawn points
local SpawnPoints = {
    { x = -1136.5, y = -1489.2, z = 4.5 },
    { x = -1148.0, y = -1495.0, z = 4.5 },
    { x = -1090.0, y = -1450.0, z = 5.0 },
    { x = -750.0, y = -1250.0, z = 85.0 },
    { x = -780.0, y = -1300.0, z = 82.0 },
    { x = -730.0, y = -950.0, z = 92.0 },
    { x = -700.0, y = -980.0, z = 91.0 },
    { x = -750.0, y = -900.0, z = 30.0 },
    { x = -780.0, y = -870.0, z = 30.0 },
    { x = -780.0, y = -580.0, z = 32.0 },
    { x = -800.0, y = -600.0, z = 31.0 },
    { x = -720.0, y = -550.0, z = 32.0 },
    { x = -580.0, y = -550.0, z = 31.0 },
    { x = -600.0, y = -530.0, z = 31.0 },
    { x = -400.0, y = -750.0, z = 55.0 },
    { x = -380.0, y = -730.0, z = 54.0 },
    { x = 180.0, y = -1100.0, z = 55.0 },
    { x = 200.0, y = -1080.0, z = 54.0 },
    { x = 350.0, y = -1200.0, z = 40.0 },
    { x = 380.0, y = -1180.0, z = 39.0 },
    { x = 120.0, y = -680.0, z = 75.0 },
    { x = 140.0, y = -700.0, z = 74.0 },
    { x = -1200.0, y = -600.0, z = 28.0 },
    { x = -1180.0, y = -580.0, z = 28.0 },
    { x = -1100.0, y = -200.0, z = 35.0 },
    { x = -1080.0, y = -180.0, z = 34.0 },
    { x = 500.0, y = -1500.0, z = 20.0 },
    { x = 520.0, y = -1480.0, z = 19.0 },
    { x = 800.0, y = -1600.0, z = 30.0 },
    { x = 820.0, y = -1580.0, z = 29.0 },
    { x = 1200.0, y = 600.0, z = 250.0 },
    { x = 1220.0, y = 580.0, z = 249.0 },
    { x = 1800.0, y = 3700.0, z = 155.0 },
    { x = 1820.0, y = 3680.0, z = 154.0 },
    { x = 2500.0, y = 2800.0, z = 260.0 },
    { x = 2520.0, y = 2780.0, z = 259.0 },
    { x = -1400.0, y = -1200.0, z = 15.0 },
    { x = -1380.0, y = -1180.0, z = 14.0 },
    { x = -1300.0, y = -1500.0, z = 5.0 },
    { x = -1280.0, y = -1480.0, z = 5.0 },
}

local function getRandomSpawnPoint()
    local point = SpawnPoints[math.random(#SpawnPoints)]
    local offsetX = math.random(-3, 3)
    local offsetY = math.random(-3, 3)
    return vec3(point.x + offsetX, point.y + offsetY, point.z)
end

local function spawnLaptop()
    local model = joaat(Config.LaptopModel)
    lib.requestModel(model, 10000)
    laptopProp = CreateObjectNoOffset(model, Config.LaptopLocation.x, Config.LaptopLocation.y, Config.LaptopLocation.z)
    SetEntityInvincible(laptopProp, true)
    FreezeEntityPosition(laptopProp, true)
    SetModelAsNoLongerNeeded(model)
end

local function removeLaptop()
    if laptopProp and DoesEntityExist(laptopProp) then
        SetEntityAsMissionEntity(laptopProp, true, true)
        DeleteEntity(laptopProp)
        laptopProp = nil
    end
end

local function removeBlips()
    if blipChop ~= -1 then
        RemoveBlip(blipChop)
        blipChop = -1
    end
end

local function spawnAngryNPC(vehicle)
    if contractNPC and DoesEntityExist(contractNPC) then return end

    local vehCoords = GetEntityCoords(vehicle)
    local playerCoords = GetEntityCoords(cache.ped)

    local angle = math.atan2(playerCoords.x - vehCoords.x, playerCoords.y - vehCoords.y)
    local npcX = vehCoords.x + math.sin(angle) * 20
    local npcY = vehCoords.y + math.cos(angle) * 20
    local npcZ = vehCoords.z

    local pedHash = joaat(Config.NPCModel)
    lib.requestModel(pedHash, 10000)

    if not HasModelLoaded(pedHash) then
        print('[qb-chopshop] Failed to load NPC model: ' .. Config.NPCModel)
        return
    end

    local ped = CreatePed(26, pedHash, npcX, npcY, npcZ, angle, true, false)
    SetEntityHealth(ped, 200)
    SetPedFleeAttributes(ped, 0, false)

    local weapon = Config.NPCWeapons[math.random(#Config.NPCWeapons)]
    GiveWeaponToPed(ped, joaat(weapon), 1, false, true)
    SetPedCombatAttributes(ped, 46, true)
    TaskCombatPed(ped, cache.ped, 20000, 16)

    SetModelAsNoLongerNeeded(pedHash)
    contractNPC = ped
    print(('[qb-chopshop] NPC spawned at %.1f, %.1f, %.1f'):format(npcX, npcY, npcZ))
end

local function cleanupContract()
    if contractVehicle and DoesEntityExist(contractVehicle) then
        SetEntityAsMissionEntity(contractVehicle, true, true)
        DeleteEntity(contractVehicle)
        contractVehicle = nil
    end
    if contractNPC and DoesEntityExist(contractNPC) then
        SetEntityAsMissionEntity(contractNPC, true, true)
        DeleteEntity(contractNPC)
        contractNPC = nil
    end
    removeBlips()
    chopState = nil
    activeContract = nil
    vehicleStolen = false
end

local function isAtChopshop()
    if not IsPedInAnyVehicle(cache.ped, false) then return false end
    local veh = GetVehiclePedIsIn(cache.ped, false)
    local coords = GetEntityCoords(veh)
    local dist = #(coords - Config.ChopshopLocation)
    return dist <= Config.ChopInteractDistance
end

local function chopPart(partIndex)
    if not chopState then return end
    if chopState.partsRemoved >= #Config.CarParams then return end

    local part = Config.CarParams[partIndex]
    isBusy = true

    lib.progressBar({
        duration = Config.PartChopDuration,
        label = ('Removing %s...'):format(part.label),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, mouse = true, combat = true },
        anim = { dict = 'mini@repair', clip = 'fixing' },
        onSuccess = function()
            isBusy = false
            chopState.partsRemoved = partIndex
            TriggerServerEvent('qb-chopshop:server:givePart', part.item)
            lib.notify({
                title = 'Part Removed',
                description = ('%s removed. (%d/%d)'):format(part.label, partIndex, #Config.CarParams),
                type = 'success'
            })
            if chopState.partsRemoved >= #Config.CarParams then
                completeJob()
            end
        end,
        onFail = function()
            isBusy = false
            lib.notify({ title = 'Chop Interrupted', description = 'You can try again.', type = 'error' })
        end
    })
end

local function completeJob()
    local reward = activeContract.reward
    local vehicle = activeContract.vehicle
    cleanupContract()
    TriggerServerEvent('qb-chopshop:server:collectReward', reward, vehicle)
    lib.notify({ title = 'Chop Complete!', description = ('Earned $%d'):format(reward), type = 'success' })
end

local function lockpickVehicle()
    if not contractVehicle or not DoesEntityExist(contractVehicle) then return end

    local dist = #(GetEntityCoords(cache.ped) - GetEntityCoords(contractVehicle))
    if dist > 5.0 then return end

    if not contractNPC or not DoesEntityExist(contractNPC) then
        spawnAngryNPC(contractVehicle)
    end

    lib.callback('qb-chopshop:server:tryLockpick', function(success)
        if not success then return end

        isBusy = true
        lib.progressBar({
            duration = 4000,
            label = 'Lockpicking vehicle...',
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, mouse = true, combat = true },
            anim = { dict = 'mini@repair', clip = 'fixing' },
            onSuccess = function()
                isBusy = false
                vehicleStolen = true
                lib.notify({
                    title = 'Vehicle Stolen',
                    description = 'Drive it to the Chopshop (blue blip).',
                    type = 'success'
                })
            end,
            onFail = function()
                isBusy = false
                lib.notify({ title = 'Failed', description = 'Lockpick failed. Try again.', type = 'error' })
            end
        })
    end)
end

local function generateContracts()
    local contracts = {}
    for i = 1, Config.ContractCount do
        local model = Config.VehicleModels[math.random(#Config.VehicleModels)]
        local reward = math.random(Config.MinReward, Config.MaxReward)
        table.insert(contracts, { id = i, vehicle = model, reward = reward, accepted = false })
    end
    return contracts
end

local function openUI(contracts)
    currentContracts = contracts
    uiOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'open',
        contracts = contracts,
        title = 'Chopshop Contracts',
        onCooldown = GetGameTimer() < cooldownEnd,
        parts = {}
    })

    lib.callback('qb-chopshop:server:getParts', function(parts)
        if uiOpen then
            SendNUIMessage({ action = 'updateParts', parts = parts })
        end
    end)
end

local function closeUI()
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function registerLaptopTarget()
    if not laptopProp or not DoesEntityExist(laptopProp) then return end
    exports.ox_target:addLocalEntity(laptopProp, {
        {
            name = 'chopshop_laptop',
            icon = 'fas fa-laptop',
            label = 'Open Chopshop',
            distance = 2.5,
            onSelect = function()
                if not uiOpen and not isBusy then
                    local contracts = generateContracts()
                    openUI(contracts)
                end
            end
        }
    })
end

local function registerVehicleTarget()
    if not contractVehicle or not DoesEntityExist(contractVehicle) then return end
    if vehicleStolen then return end

    exports.ox_target:addLocalEntity(contractVehicle, {
        {
            name = 'chopshop_lockpick',
            icon = 'fas fa-key',
            label = 'Lockpick Vehicle',
            distance = 5.0,
            canInteract = function()
                return not IsPedInAnyVehicle(cache.ped, false) and not isBusy
            end,
            onSelect = function()
                if not isBusy then
                    lockpickVehicle()
                end
            end
        }
    })
end

local function registerChopTarget()
    if not contractVehicle or not DoesEntityExist(contractVehicle) then return end
    if not vehicleStolen then return end

    exports.ox_target:addLocalEntity(contractVehicle, {
        {
            name = 'chopshop_remove_part',
            icon = 'fas fa-wrench',
            label = 'Remove Parts',
            distance = Config.ChopInteractDistance,
            canInteract = function()
                return isAtChopshop() and not isBusy and chopState
            end,
            onSelect = function()
                if chopState and chopState.partsRemoved < #Config.CarParams then
                    chopPart(chopState.partsRemoved + 1)
                end
            end
        }
    })
end

RegisterNUICallback('close', function(data, cb)
    closeUI()
    cb('ok')
end)

RegisterNUICallback('minimize', function(data, cb)
    closeUI()
    cb('ok')
end)

RegisterNUICallback('accept', function(data, cb)
    local contractId = data.contractId
    local contract = currentContracts[contractId]
    if not contract then cb('ok') return end

    if activeContract then
        lib.notify({ title = 'Already Active', description = 'Finish your current contract first.', type = 'error' })
        cb('ok')
        return
    end

    activeContract = contract
    contract.accepted = true
    vehicleStolen = false

    local coords = getRandomSpawnPoint()
    local hash = joaat(contract.vehicle)
    lib.requestModel(hash, 10000)
    contractVehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, 0.0, true, false)
    SetVehicleEngineOn(contractVehicle, true, true, false)
    SetVehicleOnGroundProperly(contractVehicle)
    SetModelAsNoLongerNeeded(hash)

    SetNewWaypoint(coords.x, coords.y)

    blipChop = AddBlipForCoord(Config.ChopshopLocation.x, Config.ChopshopLocation.y, Config.ChopshopLocation.z)
    SetBlipSprite(blipChop, Config.Blip.chopSprite)
    SetBlipColour(blipChop, Config.Blip.chopColour)
    SetBlipScale(blipChop, 0.8)
    SetBlipAsShortRange(blipChop, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Chopshop')
    EndTextCommandSetBlipName(blipChop)

    chopState = { partsRemoved = 0, vehicle = contractVehicle }
    closeUI()

    lib.notify({
        title = 'Contract Accepted',
        description = 'Follow the waypoint to the car, lockpick it, then bring it to the chopshop.',
        type = 'inform'
    })

    CreateThread(function()
        Wait(2000)
        if contractVehicle and DoesEntityExist(contractVehicle) then
            registerVehicleTarget()
        end
    end)

    cb('ok')
end)

RegisterNUICallback('refresh', function(data, cb)
    local now = GetGameTimer()
    if now < cooldownEnd then cb('ok') return end
    cooldownEnd = now + (Config.RefreshCooldown * 1000)
    local contracts = generateContracts()
    currentContracts = contracts
    SendNUIMessage({ action = 'updateContracts', contracts = contracts })
    cb('ok')
end)

RegisterNUICallback('sellParts', function(data, cb)
    lib.callback('qb-chopshop:server:sellParts', data.items, function(result)
        if result.success then
            lib.notify({ title = 'Parts Sold', description = ('Earned $%d'):format(result.earned), type = 'success' })
            lib.callback('qb-chopshop:server:getParts', function(parts)
                SendNUIMessage({ action = 'updateParts', parts = parts })
            end)
        else
            lib.notify({ title = 'Error', description = result.message, type = 'error' })
        end
    end)
    cb('ok')
end)

CreateThread(function()
    while true do
        Wait(1000)
        if uiOpen then
            local now = GetGameTimer()
            SendNUIMessage({
                action = 'cooldownTick',
                onCooldown = now < cooldownEnd,
                remaining = math.max(0, math.ceil((cooldownEnd - now) / 1000))
            })
        end
    end
end)

CreateThread(function()
    while true do
        Wait(2000)
        if vehicleStolen and contractVehicle and DoesEntityExist(contractVehicle) then
            if isAtChopshop() then
                registerChopTarget()
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(3000)
        if activeContract then
            if not contractVehicle or not DoesEntityExist(contractVehicle) then
                cleanupContract()
            end
        end
    end
end)

RegisterCommand('resetchop', function()
    cleanupContract()
    lib.notify({ title = 'Chopshop', description = 'State reset.', type = 'inform' })
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        removeLaptop()
        cleanupContract()
        closeUI()
    end
end)

-- Phone app
CreateThread(function()
    Wait(10000)
    TriggerEvent('qb-phone:client:addApp', -1, {
        app = 'chopshop',
        color = '#6366f1',
        icon = 'fas fa-car-burst',
        name = 'Chopshop',
        tooltipText = 'Chopshop Contracts',
        job = nil,
        blockedjobs = {},
        slot = 15,
        Alerts = 0,
        onOpen = function()
            if not isBusy then
                local contracts = generateContracts()
                openUI(contracts)
            end
        end
    })
end)

-- Init
CreateThread(function()
    Wait(5000)
    spawnLaptop()
    while not laptopProp or not DoesEntityExist(laptopProp) do Wait(500) end
    registerLaptopTarget()
    print('QB-CHOPSHOP: ready')
end)