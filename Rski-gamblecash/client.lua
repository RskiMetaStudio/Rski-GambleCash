local QBCore = exports['qb-core']:GetCoreObject()

local canInteract = true
local cooldownTime = 10000 -- 10 seconds cooldown 

local ped = nil

CreateThread(function()

    local model = GetHashKey(Config.NPC.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local coords = Config.NPC.coords
    ped = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, Config.NPC.scenario, 0, true)

    -- Wait for ox_target resource to be ready
    while not exports['ox_target'] do Wait(100) end

    exports.ox_target:addLocalEntity(ped, {{
        name     = 'gamble_npc',
        label    = 'Gamble Cash',
        icon     = 'fas fa-dice',
        distance = 2.5,
        onSelect = function()
            if canInteract then
                -- Start gambling action
                canInteract = false
                TriggerServerEvent('qb-gamble:attempt')

                -- Using ox_lib to notify the user
                exports.ox_lib:notify({title = 'Gambling', description = 'You started gambling. Please wait...', type = 'info'})

                -- Set cooldown before interaction is allowed again
                CreateThread(function()
                    Wait(cooldownTime)
                    canInteract = true
                    exports.ox_lib:notify({title = 'Gambling', description = 'You can gamble again.', type = 'success'})
                end)
            else
                exports.ox_lib:notify({title = 'Gambling', description = 'Please wait before gambling again.', type = 'error'})
            end
        end
    }})
end)

RegisterNetEvent('qb-gamble:result', function(amount)
    if amount > 0 then
        exports.ox_lib:notify({title = 'Gambling', description = 'You won $' .. amount, type = 'success'})
    elseif amount < 0 then
        exports.ox_lib:notify({title = 'Gambling', description = 'You lost $' .. math.abs(amount), type = 'error'})
    else
        exports.ox_lib:notify({title = 'Gambling', description = 'No gain or loss.', type = 'info'})
    end
end)
