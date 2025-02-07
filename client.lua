local playerFirstName = nil
local playerLastName = nil
local playerJob = nil
local playerJobGrade = nil

Citizen.CreateThread(function()
    while ESX.GetPlayerData().firstName == nil do
        Citizen.Wait(100)
    end
    local playerData = ESX.GetPlayerData()
    playerFirstName = playerData.firstName
    playerLastName = playerData.lastName
    playerJob = playerData.job.label
    playerJobGrade = playerData.job.grade_label
end)

RegisterCommand('radiop', function()
    ESX.TriggerServerCallback('lmd_radio:getFrequencies', function(data)
        if data.error then
            ESX.ShowNotification(data.error)
        else
            SetNuiFocus(true, true)
            SendNUIMessage({
                type = "openRadio",
                frequencies = data.frequencies,
                playerName = data.firstName .. " " .. data.lastName,
                job = data.job,
                jobGrade = data.jobGrade
            })
        end
    end)
end, false)
RegisterKeyMapping('radiop', 'Radio policial', 'keyboard', 'F7')

RegisterNUICallback('joinFrequency', function(data, cb)
    local frequencyId = tonumber(data.frequency)
    if frequencyId then
        local playerGrade = playerJobGrade
        TriggerServerEvent('lmd_radio:joinFrequency', frequencyId, playerFirstName .. " " .. playerLastName, playerGrade)
        exports['pma-voice']:setRadioChannel(frequencyId)
        cb({ success = true })
    else
        cb({ success = false, error = "Invalid frequency" })
    end
end)
RegisterNUICallback('leaveFrequency', function(data, cb)
    TriggerServerEvent('lmd_radio:leaveFrequency', playerFirstName .. " " .. playerLastName)
    exports['pma-voice']:setRadioChannel(0)
    cb({ success = true })
end)
RegisterNUICallback('closeRadio', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('kickUser', function(data, cb)
    local targetSource = tonumber(data.source)
    if targetSource then
        TriggerServerEvent('lmd_radio:kickUser', targetSource)
        cb({ success = true })
    else
        cb({ success = false, error = "Invalid user" })
    end
end)

RegisterNUICallback('moveUser', function(data, cb)
    local targetSource = tonumber(data.source)
    local targetFrequency = tonumber(data.frequency)

    if targetSource and targetFrequency then
        TriggerServerEvent('lmd_radio:moveUser', targetSource, targetFrequency)
        cb({ success = true })
    else
        cb({ success = false, error = "Invalid data" })
    end
end)
RegisterNetEvent('lmd_radio:updateFrequencies')
AddEventHandler('lmd_radio:updateFrequencies', function(updatedFrequencies)
    SendNUIMessage({
        type = "updateFrequencies",
        frequencies = updatedFrequencies
    })
end)
