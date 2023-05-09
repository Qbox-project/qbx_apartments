local ApartmentObjects = {}
local QBCore = exports['qbx-core']:GetCoreObject()

-- Functions
local function createApartmentId(type)
	local aparmentId = nil
	repeat
		aparmentId = tostring(math.random(1, 9999))
        local result = MySQL.query.await('SELECT * FROM apartments WHERE name = ?', { type .. aparmentId })
    until result == nil
	return aparmentId
end

local function getApartmentInfo(apartmentId)
    local result = MySQL.query.await('SELECT * FROM apartments WHERE name = ?', { apartmentId })
    return result[1]
end

-- Events

RegisterNetEvent('qb-apartments:server:SetInsideMeta', function(house, insideId, bool, isVisiting)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local insideMeta = player.PlayerData.metadata.inside

    if bool then
        local routeId = insideId:gsub("[^%-%d]", "")
        if not isVisiting then
            insideMeta.apartment.apartmentType = house
            insideMeta.apartment.apartmentId = insideId
            insideMeta.house = nil
            player.Functions.SetMetaData("inside", insideMeta)
        end
        QBCore.Functions.SetPlayerBucket(src, tonumber(routeId))
    else
        insideMeta.apartment.apartmentType = nil
        insideMeta.apartment.apartmentId = nil
        insideMeta.house = nil

        player.Functions.SetMetaData("inside", insideMeta)
        QBCore.Functions.SetPlayerBucket(src, 0)
    end
end)

RegisterNetEvent('qb-apartments:returnBucket', function()
    SetPlayerRoutingBucket(source, 0)
end)

RegisterNetEvent('apartments:server:CreateApartment', function(type, label)
    local player = QBCore.Functions.GetPlayer(source)
    local num = createApartmentId(type)
    local apartmentId = type .. num
    label = label .. " " .. num
    MySQL.insert('INSERT INTO apartments (name, type, label, citizenid) VALUES (?, ?, ?, ?)', {
        apartmentId,
        type,
        label,
        player.PlayerData.citizenid
    })
    TriggerClientEvent('QBCore:Notify', source, Lang:t('success.receive_apart').." ("..label..")")
    TriggerClientEvent("apartments:client:SpawnInApartment", source, apartmentId, type)
    TriggerClientEvent("apartments:client:SetHomeBlip", source, type)
end)

RegisterNetEvent('apartments:server:UpdateApartment', function(type, label)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    MySQL.update('UPDATE apartments SET type = ?, label = ? WHERE citizenid = ?', { type, label, player.PlayerData.citizenid })
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.changed_apart'))
    TriggerClientEvent("apartments:client:SetHomeBlip", src, type)
end)

RegisterNetEvent('apartments:server:RingDoor', function(apartmentId, apartment)
    local src = source
    local apartmentObj = ApartmentObjects[apartment].apartments[apartmentId]
    if apartmentObj and next(apartmentObj.players) then
        for k, _ in pairs(apartmentObj.players) do
            TriggerClientEvent('apartments:client:RingDoor', k, src)
        end
    end
end)

RegisterNetEvent('apartments:server:OpenDoor', function(target, apartmentId, apartment)
    local otherPlayer = QBCore.Functions.GetPlayer(target)
    local ownerPlayer = QBCore.Functions.GetPlayer(source) -- Aki be enged
    if otherPlayer then
        TriggerClientEvent('apartments:client:SpawnInApartment', otherPlayer.PlayerData.source, apartmentId, apartment, ownerPlayer.PlayerData.citizenid)
    end
end)

RegisterNetEvent('apartments:server:AddObject', function(apartmentId, apartment, offset)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local apartmentObj = ApartmentObjects[apartment]
    
    if not apartmentObj then
        ApartmentObjects[apartment] = {}
        apartmentObj = ApartmentObjects[apartment]
    end

    if not apartmentObj.apartments then
        apartmentObj.apartments = {}
    end

    if not apartmentObj.apartments[apartmentId] then
        apartmentObj.apartments[apartmentId] = {}
        apartmentObj.apartments[apartmentId].offset = offset
        apartmentObj.apartments[apartmentId].players = {}
    end

    apartmentObj.apartments[apartmentId].players[src] = player.PlayerData.citizenid
end)

RegisterNetEvent('apartments:server:RemoveObject', function(apartmentId, apartment)
    local src = source
    local apartmentObj = ApartmentObjects[apartment]
    if not apartmentObj.apartments[apartmentId].players then return end
    
    apartmentObj.apartments[apartmentId].players[src] = nil
    if not next(apartmentObj.apartments[apartmentId].players) then
        apartmentObj.apartments[apartmentId] = nil
    end
end)

RegisterNetEvent('apartments:server:setCurrentApartment', function(ap)
    local player = QBCore.Functions.GetPlayer(source)

    if not player then return end
    player.Functions.SetMetaData('currentapartment', ap)
end)

-- Callbacks

QBCore.Functions.CreateCallback('apartments:GetAvailableApartments', function(_, cb, apartment)
    local apartments = {}
    if not ApartmentObjects or not ApartmentObjects[apartment] or not ApartmentObjects[apartment].apartments then
        cb(apartments)
        return
    end
    for apartmentId, apartmentVal in pairs(ApartmentObjects[apartment].apartments) do
        if next(apartmentVal.players) then
            local apartmentInfo = getApartmentInfo(apartmentId)
            apartments[apartmentId] = apartmentInfo.label
        end
    end

    cb(apartments)
end)

QBCore.Functions.CreateCallback('apartments:GetApartmentOffset', function(_, cb, apartmentId)
    local retval = 0
    if not ApartmentObjects then
        cb(retval)
        return
    end
    for _, v in pairs(ApartmentObjects) do
        if (v.apartments[apartmentId] and tonumber(v.apartments[apartmentId].offset) ~= 0) then
            retval = tonumber(v.apartments[apartmentId].offset)
        end
    end
    cb(retval)
end)

QBCore.Functions.CreateCallback('apartments:GetApartmentOffsetNewOffset', function(_, cb, apartment)
    local retval = Apartments.SpawnOffset
    if not ApartmentObjects or not ApartmentObjects[apartment] or not ApartmentObjects[apartment].apartments then
        cb(retval)
        return
    end
    local apartments = ApartmentObjects[apartment].apartments
    for _, v in pairs(apartments) do
        retval = v.offset + Apartments.SpawnOffset
    end
    cb(retval)
end)

QBCore.Functions.CreateCallback('apartments:GetOwnedApartment', function(source, cb, cid)
    if not cid then
        local player = QBCore.Functions.GetPlayer(source)
        cid = player.PlayerData.citizenid
    end

    local result = MySQL.query.await('SELECT * FROM apartments WHERE citizenid = ?', { cid })
    if result[1] then
        return cb(result[1], cid)
    end
    return cb(nil)
end)

QBCore.Functions.CreateCallback('apartments:IsOwner', function(source, cb, apartment)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end

    local result = MySQL.query.await('SELECT * FROM apartments WHERE citizenid = ?', { player.PlayerData.citizenid })
    if result[1] then
        cb(result[1].type == apartment)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('apartments:GetOutfits', function(source, cb)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end

    local result = MySQL.query.await('SELECT * FROM player_outfits WHERE citizenid = ?', { player.PlayerData.citizenid })
    if result[1] then
        cb(result)
    else
        cb(nil)
    end
end)

-- RegisterStash
AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        for k, v in pairs(Apartments.Locations) do
            exports.ox_inventory:RegisterStash(k, v.label, Apartments.Slot, Apartments.Weight * 1000, true)
        end
    end
end)