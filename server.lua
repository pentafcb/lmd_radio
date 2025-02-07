local frequencies = {
    { id = 1, name = "CENTRAL", value = "595.34", users = {} },
    { id = 2, name = "FRECUENCIA 1", value = "173.10", users = {} },
    { id = 3, name = "FRECUENCIA 2", value = "417.35", users = {} },
    { id = 4, name = "FRECUENCIA 3", value = "153.10", users = {} },
    { id = 5, name = "FRECUENCIA 4", value = "467.35", users = {} },
    { id = 6, name = "ESTACIÓN DE POLICÍA", value = "426.71", users = {} },
    { id = 7, name = "ESPERANDO ASIGNACIÓN", value = "578.21", users = {} }
}
-- iGNORE VALUES
ESX.RegisterServerCallback('lmd_radio:getFrequencies', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name ~= "police" then
        cb({ error = "No tienes permiso para usar esta radio." })
        return
    end
    for _, frequency in ipairs(frequencies) do
        for _, user in ipairs(frequency.users) do
            local targetPlayer = ESX.GetPlayerFromId(user.source)
            if targetPlayer then
                user.grade = targetPlayer.job.grade_label
            end
        end
    end
    cb({
        frequencies = frequencies,
        firstName = xPlayer.get('firstName'),
        lastName = xPlayer.get('lastName'),
        job = xPlayer.job.label,
        jobGrade = xPlayer.job.grade_label
    })
end)
RegisterServerEvent('lmd_radio:joinFrequency')
AddEventHandler('lmd_radio:joinFrequency', function(frequencyId, playerName, playerGrade)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local frequency = frequencies[frequencyId]
    for _, freq in ipairs(frequencies) do
        for i, user in ipairs(freq.users) do
            if user.name == playerName then
                table.remove(freq.users, i)
                break
            end
        end
    end
    if frequency then
        table.insert(frequency.users, {
            name = xPlayer.get("firstName") .. " " .. xPlayer.get("lastName"),
            source = src,
            grade = xPlayer.job.grade_label
        })
        TriggerClientEvent('lmd_radio:updateFrequencies', -1, frequencies)
        exports['pma-voice']:setPlayerRadio(src, frequencyId)
    end
end)
RegisterServerEvent('lmd_radio:leaveFrequency')
AddEventHandler('lmd_radio:leaveFrequency', function(playerName)
    local src = source
    for _, freq in ipairs(frequencies) do
        for i, user in ipairs(freq.users) do
            if user.name == playerName then
                table.remove(freq.users, i)
                break
            end
        end
    end
    TriggerClientEvent('lmd_radio:updateFrequencies', -1, frequencies)
    exports['pma-voice']:setPlayerRadio(src, 0)
end)
RegisterServerEvent('lmd_radio:kickUser')
AddEventHandler('lmd_radio:kickUser', function(targetSource)
    local src = source
    local xTarget = ESX.GetPlayerFromId(targetSource)
    if not xTarget then
        TriggerClientEvent('esx:showNotification', src, "No se pudo encontrar al jugador.")
        return
    end
    for _, freq in ipairs(frequencies) do
        for i, user in ipairs(freq.users) do
            if user.source == targetSource then
                table.remove(freq.users, i)
                break
            end
        end
    end
    TriggerClientEvent('esx:showNotification', targetSource, "Has sido expulsado de la frecuencia.")
    TriggerClientEvent('lmd_radio:updateFrequencies', -1, frequencies)
    exports['pma-voice']:setPlayerRadio(targetSource, 0)
end)
RegisterServerEvent('lmd_radio:moveUser')
AddEventHandler('lmd_radio:moveUser', function(targetSource, newFrequencyId)
    local src = source
    local targetPlayer = ESX.GetPlayerFromId(targetSource)
    local newFrequency = frequencies[newFrequencyId]
    if not newFrequency then
        TriggerClientEvent('esx:showNotification', src, "La frecuencia no es válida.")
        return
    end
    for _, freq in ipairs(frequencies) do
        for i, user in ipairs(freq.users) do
            if user.source == targetSource then
                table.remove(freq.users, i)
                break
            end
        end
    end
    if targetPlayer then
        table.insert(newFrequency.users, {
            name = targetPlayer.get("firstName") .. " " .. targetPlayer.get("lastName"),
            source = targetSource,
            grade = targetPlayer.job.grade_label
        })
        exports['pma-voice']:setPlayerRadio(targetSource, newFrequencyId)
        TriggerClientEvent('lmd_radio:updateFrequencies', -1, frequencies)
    else
        TriggerClientEvent('esx:showNotification', src, "No se pudo encontrar al jugador.")
    end
end)
AddEventHandler('playerDropped', function(reason)
    local src = source
    for _, freq in ipairs(frequencies) do
        for i, user in ipairs(freq.users) do
            if user.source == src then
                table.remove(freq.users, i)
                break
            end
        end
    end
    TriggerClientEvent('lmd_radio:updateFrequencies', -1, frequencies)
    exports['pma-voice']:setPlayerRadio(src, 0)
end)