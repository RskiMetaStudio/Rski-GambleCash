local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('qb-gamble:attempt', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cashAmount = 100  -- Set the amount to gamble

    if Player.Functions.GetItemByName('cash') and Player.Functions.GetItemByName('cash').amount >= cashAmount then
        -- Deduct cash from player's inventory
        Player.Functions.RemoveItem('cash', cashAmount)

        -- Simulate a gamble result (positive for win, negative for loss)
        local result = math.random(-cashAmount, cashAmount)

        -- Add cash to player's inventory based on result
        if result > 0 then
            Player.Functions.AddItem('cash', result)
        end

        -- Trigger client event with the result
        TriggerClientEvent('qb-gamble:result', src, result)
    else
        -- Notify player if they don't have enough cash
        TriggerClientEvent('QBCore:Notify', src, 'You do not have enough cash to gamble.', 'error')
    end
end)
