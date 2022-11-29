local QBCore = exports['qb-core']:GetCoreObject()
local ApartmentObjects = {}

-- Functions
local function CreateApartmentId(apartementType)
    local UniqueFound = false
	local AparmentId = nil

	while not UniqueFound do
		AparmentId = tostring(math.random(1, 9999))

        local result = MySQL.single.await('SELECT COUNT(1) as count FROM apartments WHERE name = ?', {
            tostring(apartementType .. AparmentId)
        })

        if result.count == 0 then
            UniqueFound = true
        end
	end

	return AparmentId
end

local function GetApartmentInfo(apartmentId)
    local retval = nil
    local result = MySQL.single.await('SELECT * FROM apartments WHERE name = ?', {
        apartmentId
    })

    if result then
        retval = result
    end

    return retval
end

-- Events
RegisterNetEvent('qb-apartments:server:SetInsideMeta', function(house, insideId, bool, isVisiting)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local insideMeta = Player.PlayerData.metadata.inside

    if bool then
        local routeId = insideId:gsub("[^%-%d]", "")

        if not isVisiting then
            insideMeta.apartment.apartmentType = house
            insideMeta.apartment.apartmentId = insideId
            insideMeta.house = nil

            Player.Functions.SetMetaData("inside", insideMeta)
        end

        QBCore.Functions.SetPlayerBucket(src, tonumber(routeId))
    else
        insideMeta.apartment.apartmentType = nil
        insideMeta.apartment.apartmentId = nil
        insideMeta.house = nil

        Player.Functions.SetMetaData("inside", insideMeta)
        QBCore.Functions.SetPlayerBucket(src, 0)
    end
end)

RegisterNetEvent('qb-apartments:returnBucket', function()
    local src = source

    SetPlayerRoutingBucket(src, 0)
end)

RegisterNetEvent('apartments:server:CreateApartment', function(type, label)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local num = CreateApartmentId(type)
    local apartmentId = tostring(type .. num)

    label = tostring(label .. " " .. num)

    MySQL.insert('INSERT INTO apartments (name, type, label, citizenid) VALUES (?, ?, ?, ?)', {
        apartmentId,
        type,
        label,
        Player.PlayerData.citizenid
    })

    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.receive_apart') .. " (" .. label .. ")")
    TriggerClientEvent("apartments:client:SpawnInApartment", src, apartmentId, type)
    TriggerClientEvent("apartments:client:SetHomeBlip", src, type)
end)

RegisterNetEvent('apartments:server:UpdateApartment', function(type, label)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    MySQL.update('UPDATE apartments SET type = ?, label = ? WHERE citizenid = ?', {
        type,
        label,
        Player.PlayerData.citizenid
    })

    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.changed_apart'))
    TriggerClientEvent("apartments:client:SetHomeBlip", src, type)
end)

RegisterNetEvent('apartments:server:RingDoor', function(apartmentId, apartment)
    local src = source

    if ApartmentObjects[apartment].apartments[apartmentId] and next(ApartmentObjects[apartment].apartments[apartmentId].players) then
        for k, _ in pairs(ApartmentObjects[apartment].apartments[apartmentId].players) do
            TriggerClientEvent('apartments:client:RingDoor', k, src)
        end
    end
end)

RegisterNetEvent('apartments:server:OpenDoor', function(target, apartmentId, apartment)
    local src = source
    local OtherPlayer = QBCore.Functions.GetPlayer(target)
    local OwnerPlayer = QBCore.Functions.GetPlayer(src)

    if OtherPlayer then
        TriggerClientEvent('apartments:client:SpawnInApartment', OtherPlayer.PlayerData.source, apartmentId, apartment, OwnerPlayer.PlayerData.citizenid)
    end
end)

RegisterNetEvent('apartments:server:AddObject', function(apartmentId, apartment, offset)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if ApartmentObjects[apartment] and ApartmentObjects[apartment].apartments and ApartmentObjects[apartment].apartments[apartmentId] then
        ApartmentObjects[apartment].apartments[apartmentId].players[src] = Player.PlayerData.citizenid
    else
        if ApartmentObjects[apartment] and ApartmentObjects[apartment].apartments then
            ApartmentObjects[apartment].apartments[apartmentId] = {}
            ApartmentObjects[apartment].apartments[apartmentId].offset = offset
            ApartmentObjects[apartment].apartments[apartmentId].players = {}
            ApartmentObjects[apartment].apartments[apartmentId].players[src] = Player.PlayerData.citizenid
        else
            ApartmentObjects[apartment] = {}
            ApartmentObjects[apartment].apartments = {}
            ApartmentObjects[apartment].apartments[apartmentId] = {}
            ApartmentObjects[apartment].apartments[apartmentId].offset = offset
            ApartmentObjects[apartment].apartments[apartmentId].players = {}
            ApartmentObjects[apartment].apartments[apartmentId].players[src] = Player.PlayerData.citizenid
        end
    end
end)

RegisterNetEvent('apartments:server:RemoveObject', function(apartmentId, apartment)
    local src = source

    if ApartmentObjects[apartment].apartments[apartmentId].players then
        ApartmentObjects[apartment].apartments[apartmentId].players[src] = nil

        if not next(ApartmentObjects[apartment].apartments[apartmentId].players) then
            ApartmentObjects[apartment].apartments[apartmentId] = nil
        end
    end
end)

RegisterNetEvent('apartments:server:setCurrentApartment', function(ap)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        return
    end

    Player.Functions.SetMetaData('currentapartment', ap)
end)

-- Callbacks
QBCore.Functions.CreateCallback('apartments:GetAvailableApartments', function(_, cb, apartment)
    local apartments = {}

    if ApartmentObjects and ApartmentObjects[apartment] and ApartmentObjects[apartment].apartments then
        for k, _ in pairs(ApartmentObjects[apartment].apartments) do
            if ApartmentObjects[apartment].apartments[k] and next(ApartmentObjects[apartment].apartments[k].players) then
                local apartmentInfo = GetApartmentInfo(k)

                apartments[k] = apartmentInfo.label
            end
        end
    end

    cb(apartments)
end)

QBCore.Functions.CreateCallback('apartments:GetApartmentOffset', function(_, cb, apartmentId)
    local retval = 0

    if ApartmentObjects then
        for k, _ in pairs(ApartmentObjects) do
            if (ApartmentObjects[k].apartments[apartmentId] and tonumber(ApartmentObjects[k].apartments[apartmentId].offset) ~= 0) then
                retval = tonumber(ApartmentObjects[k].apartments[apartmentId].offset)
            end
        end
    end

    cb(retval)
end)

QBCore.Functions.CreateCallback('apartments:GetApartmentOffsetNewOffset', function(_, cb, apartment)
    local retval = Config.ApartmentsSpawnOffset

    if ApartmentObjects and ApartmentObjects[apartment] and ApartmentObjects[apartment].apartments then
        for k, _ in pairs(ApartmentObjects[apartment].apartments) do
            if ApartmentObjects[apartment].apartments[k] then
                retval = ApartmentObjects[apartment].apartments[k].offset + Config.ApartmentsSpawnOffset
            end
        end
    end

    cb(retval)
end)

QBCore.Functions.CreateCallback('apartments:GetOwnedApartment', function(source, cb, cid)
    if cid then
        local result = MySQL.single.await('SELECT * FROM apartments WHERE citizenid = ?', {
            cid
        })

        if result then
            return cb(result, cid)
        end

        return cb(nil)
    else
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        local result = MySQL.single.await('SELECT * FROM apartments WHERE citizenid = ?', {
            Player.PlayerData.citizenid
        })

        if result then
            return cb(result, Player.PlayerData.citizenid)
        end

        return cb(nil)
    end
end)

QBCore.Functions.CreateCallback('apartments:IsOwner', function(source, cb, apartment)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        return
    end

    local result = MySQL.query.await('SELECT * FROM apartments WHERE citizenid = ?', {
        Player.PlayerData.citizenid
    })

    if result[1] then
        if result[1].type == apartment then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('apartments:GetOutfits', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local result = MySQL.query.await('SELECT * FROM player_outfits WHERE citizenid = ?', {
            Player.PlayerData.citizenid
        })

        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end
end)

-- RegisterStash
AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        for k, v in pairs(Config.Apartments) do
            exports.ox_inventory:RegisterStash(k, v.label, Config.ApartmentsSlot, Config.ApartmentsWeight * 1000, true)
        end
    end
end)