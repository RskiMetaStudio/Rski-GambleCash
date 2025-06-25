local QBCore = exports['qb-core']:GetCoreObject()

local canInteract = true
local cooldownTime = 10000 -- 10 seconds cooldown

local ped = nil
CreateThread(function()
    local model = GetHashKey(Config.NPC.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local c = Config.NPC.coords
    ped = CreatePed(0, model, c.x, c.y, c.z, c.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, Config.NPC.scenario, 0, true)

    while not exports['ox_target'] do Wait(100) end
    exports.ox_target:addLocalEntity(ped, {{
        name     = 'gamble_npc',
        label    = 'Gamble Cash',
        icon     = 'fas fa-dice',
        distance = 2.5,
        onSelect = function()
            if canInteract then
                canInteract = false
                TriggerServerEvent('qb-gamble:attempt')
                QBCore.Functions.Notify('You started gambling. Please wait...', 'info')
                CreateThread(function()
                    Wait(cooldownTime)
                    canInteract = true
                    QBCore.Functions.Notify('You can gamble again.', 'success')
                end)
            else
                QBCore.Functions.Notify('Please wait before gambling again.', 'error')
            end
        end
    }})
end)

RegisterNetEvent('qb-gamble:result', function(amount)
    if amount > 0 then
        QBCore.Functions.Notify('You won $'..amount, 'success')
    elseif amount < 0 then
        QBCore.Functions.Notify('You lost $'..math.abs(amount), 'error')
    else
        QBCore.Functions.Notify('No gain or loss.', 'info')
    end
end)
