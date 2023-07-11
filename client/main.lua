local QBCore = exports['qbx-core']:GetCoreObject()
local apartmentZones = {}
local houseObj = {}
local poiOffsets = {}
local isOwned = false
local rangDoorbell = false
local currentOffset = 0
local currentApartment = nil
local currentApartmentId = nil
local currentEntrance = nil
local currentDoorBell = 0

-- Functions
local function openHouseAnim()
    lib.requestAnimDict('anim@heists@keycard@', 100)
    TaskPlayAnim(cache.ped, 'anim@heists@keycard@', 'exit', 5.0, 1.0, -1, 16, 0, false, false, false)
    Wait(400)
    StopAnimTask(cache.ped, 'anim@heists@keycard@', 'exit', 1.0)
end

local function showEntranceHeaderMenu(id)
    local headerMenu = {}

    lib.callback('apartments:IsOwner', false, function(result)
        isOwned = result
        
        if isOwned then
            headerMenu[#headerMenu + 1] = {
                title = Lang:t('text.enter'),
                event = 'apartments:client:EnterApartment',
                args = id
            }
        elseif not isOwned then
            headerMenu[#headerMenu + 1] = {
                title = Lang:t('text.move_here'),
                event = 'apartments:client:UpdateApartment',
                args = id
            }
        end

        headerMenu[#headerMenu + 1] = {
            title = Lang:t('text.ring_doorbell'),
            event = 'apartments:client:DoorbellMenu',
        }

        lib.registerContext({
            id = 'apartment_context_menu',
            title = Lang:t('text.menu_header'),
            options = headerMenu
        })

        lib.showContext('apartment_context_menu')
    end, id)
end

local function showExitHeaderMenu()
    lib.registerContext({
        id = 'apartment_exit_context_menu',
        title = Lang:t('text.menu_header'),
        options = {
            { title = Lang:t('text.open_door'), event = 'apartments:client:OpenDoor', },
            { title = Lang:t('text.leave'), event = 'apartments:client:LeaveApartment', },
        }
    })
    lib.showContext('apartment_exit_context_menu')
end

local function onEnter(self)
    lib.showTextUI(Lang:t('text.' .. self.typ))
    currentEntrance = self.aptId
end

local function onExit(self)
    lib.hideTextUI()
    currentEntrance = nil
end

local function isInside(self)
    if IsControlJustPressed(0, 38) then
        if self.typ == 'door_outside' then
            showEntranceHeaderMenu(self.aptId)
        elseif self.typ == 'door_inside' then
            showExitHeaderMenu()
        elseif self.typ == 'open_stash' then
            TriggerEvent('apartments:client:OpenStash', currentApartment)
        elseif self.typ == 'change_outfit' then
            TriggerEvent('apartments:client:ChangeOutfit')
        elseif self.typ == 'logout' then
            TriggerEvent('apartments:client:Logout')
        end
        lib.hideTextUI()
    end
end

local function createEntrances()
    for id, data in pairs(Apartments.Locations) do
        apartmentZones[id] = {}
        apartmentZones[id].enterance = lib.zones.sphere({
            coords = data.enter.xyz,
            radius = 1.5,
            debug = false,
            inside = isInside,
            onEnter = onEnter,
            onExit = onExit,
            typ = 'door_outside',
            aptId = id
        })
    end
end

local function removeEntrances()
    onExit()
    for id, _ in pairs(apartmentZones) do
        apartmentZones[id].enterance:remove()
    end
end

local function createInsidePoints(id, data)
    apartmentZones[id].exit = lib.zones.sphere({
        coords = vector3(Apartments.Locations[currentApartment].enter.x - data.exit.x, Apartments.Locations[currentApartment].enter.y - data.exit.y - 0.5, Apartments.Locations[currentApartment].enter.z - currentOffset + data.exit.z),
        radius = 1.0,
        debug = false,
        inside = isInside,
        onEnter = onEnter,
        onExit = onExit,
        typ = 'door_inside',
        aptId = id
    })

    apartmentZones[id].stash = lib.zones.sphere({
        coords = vector3(Apartments.Locations[currentApartment].enter.x - data.stash.x, Apartments.Locations[currentApartment].enter.y - data.stash.y, Apartments.Locations[currentApartment].enter.z - currentOffset + data.stash.z),
        radius = 1.0,
        debug = false,
        inside = isInside,
        onEnter = onEnter,
        onExit = onExit,
        typ = 'open_stash',
        aptId = id
    })

    apartmentZones[id].clothes = lib.zones.sphere({
        coords = vector3(Apartments.Locations[currentApartment].enter.x - data.clothes.x, Apartments.Locations[currentApartment].enter.y - data.clothes.y, Apartments.Locations[currentApartment].enter.z - currentOffset + data.clothes.z),
        radius = 1.0,
        debug = false,
        inside = isInside,
        onEnter = onEnter,
        onExit = onExit,
        typ = 'change_outfit',
        aptId = id
    })

    apartmentZones[id].logout = lib.zones.sphere({
        coords = vector3(Apartments.Locations[currentApartment].enter.x - data.logout.x, Apartments.Locations[currentApartment].enter.y + data.logout.y, Apartments.Locations[currentApartment].enter.z - currentOffset + data.logout.z),
        radius = 1.0,
        debug = false,
        inside = isInside,
        onEnter = onEnter,
        onExit = onExit,
        typ = 'logout',
        aptId = id
    })
end

local function removeInsidePoints(id)
    apartmentZones[id].exit:remove()
    apartmentZones[id].stash:remove()
    apartmentZones[id].clothes:remove()
    apartmentZones[id].logout:remove()
end

local function enterApartment(house, apartmentId, new)
    currentApartmentId = apartmentId
    currentApartment = house

    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
    openHouseAnim()
    local offset = lib.callback.await('apartments:GetApartmentOffset', false, apartmentId)
    if not offset or offset == 0 then
        lib.callback('apartments:GetApartmentOffsetNewOffset', false, function(newoffset)
            if newoffset > 230 then
                newoffset = 210
            end
            currentOffset = newoffset
            TriggerServerEvent("apartments:server:AddObject", apartmentId, house, currentOffset)
            local coords = Apartments.Locations[house].enter.xyz - vec3(0, 0, currentOffset)
            local data = exports['qbx-interior']:CreateApartmentFurnished(coords)
            Wait(100)
            houseObj = data[1]
            poiOffsets = data[2]
            rangDoorbell = false
            Wait(500)
            TriggerEvent('qb-weathersync:client:DisableSync')
            Wait(100)
            TriggerServerEvent('qb-apartments:server:SetInsideMeta', house, apartmentId, true, false)
            TriggerServerEvent("apartments:server:setCurrentApartment", apartmentId)
            createInsidePoints(house, poiOffsets)
        end, house)
    else
        if offset > 230 then
            offset = 210
        end
        currentOffset = offset
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
        TriggerServerEvent("apartments:server:AddObject", apartmentId, house, currentOffset)
        local coords = Apartments.Locations[house].enter.xyz - vec3(0, 0, currentOffset)
        local data = exports['qbx-interior']:CreateApartmentFurnished(coords)
        Wait(100)
        houseObj = data[1]
        poiOffsets = data[2]
        Wait(500)
        TriggerEvent('qb-weathersync:client:DisableSync')
        Wait(100)
        TriggerServerEvent('qb-apartments:server:SetInsideMeta', house, apartmentId, true, true)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
        TriggerServerEvent("apartments:server:setCurrentApartment", apartmentId)
        createInsidePoints(house, poiOffsets)
    end

    if new then
        SetTimeout(1250, function()
            TriggerEvent('qb-clothes:client:CreateFirstCharacter')
        end)
    end
end

local function menuOwners()
    local apartments = lib.callback.await('apartments:GetAvailableApartments', false, currentEntrance)
    if not next(apartments) then
        QBCore.Functions.Notify(Lang:t('error.nobody_home'), "error", 3500)
        lib.hideContext(false)
    else
        local aptsMenu = {}

        for k, v in pairs(apartments) do
            aptsMenu[#aptsMenu+1] = {
                title = v,
                event = 'apartments:client:RingMenu',
                args = { apartmentId = k }
            }
        end

        lib.registerContext({
            id = 'apartment_tennants_context_menu',
            title = Lang:t('text.tennants'),
            options = aptsMenu
        })

        lib.showContext('apartment_tennants_context_menu')
    end
end

local function exitApartment()
    -- Sound effect
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
    -- Screen anim
    openHouseAnim()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end
    -- Despawn Interior
    exports['qbx-interior']:DespawnInterior(houseObj, function()
        -- EnableSync
        TriggerEvent('qb-weathersync:client:EnableSync')
        -- Teleport PLayer outside
        local coord = Apartments.Locations[currentApartment].enter
        SetEntityCoords(cache.ped, coord.x, coord.y, coord.z, false, false, false, false)
        SetEntityHeading(cache.ped, coord.w - 178.9)
        Wait(1000)
        TriggerServerEvent("apartments:server:RemoveObject", currentApartmentId, currentApartment)
        TriggerServerEvent('qb-apartments:server:SetInsideMeta', currentApartmentId, false)
        currentOffset = 0
        DoScreenFadeIn(1000)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
        TriggerServerEvent("apartments:server:setCurrentApartment", nil)
        -- Remove Inside Points
        removeInsidePoints(currentApartment)
        -- Reset
        houseObj, poiOffsets = {}, {}
        currentApartment, currentApartmentId = nil, nil
    end)
end

local function loggedIn()
    createEntrances()
end

local function loggedOff()
    -- Remove Enterence Zones
    removeEntrances()
    -- If you are not in a apartment, then just return
    if not currentApartment then return end
    -- Remove Inside Points
    removeInsidePoints(currentApartment)
    -- Despawn Interior
    exports['qbx-interior']:DespawnInterior(houseObj, function()
    -- EnableSync
    TriggerEvent('qb-weathersync:client:EnableSync')
    -- Teleport PLayer outside
    local coord = Apartments.Locations[currentApartment].enter
    SetEntityCoords(cache.ped, coord.x, coord.y, coord.z, false, false, false, false)
    SetEntityHeading(cache.ped, coord.w)
    Wait(1000)
    TriggerServerEvent("apartments:server:RemoveObject", currentApartmentId, currentApartment)
    currentOffset = 0
    DoScreenFadeIn(1000)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
    TriggerServerEvent("apartments:server:setCurrentApartment", nil)
    houseObj, poiOffsets = {}, {}
    currentApartment, currentApartmentId = nil, nil
    end)
end

-- Events
RegisterNetEvent('apartments:client:EnterApartment', function(id)
    local result = lib.callback.await('apartments:GetOwnedApartment')
    if not result then return end
    enterApartment(id, result.name, false)
end)

RegisterNetEvent('apartments:client:UpdateApartment', function(id)
    TriggerServerEvent("apartments:server:UpdateApartment", id, Apartments.Locations[id].label)
    isOwned = true
end)

RegisterNetEvent('apartments:client:LeaveApartment', function()
    if not currentApartment then return end
    exitApartment()
end)

RegisterNetEvent('apartments:client:DoorbellMenu', function()
    menuOwners()
end)

RegisterNetEvent('apartments:client:RingMenu', function(data)
    rangDoorbell = currentEntrance
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
    TriggerServerEvent("apartments:server:RingDoor", data.apartmentId, currentEntrance)
end)

RegisterNetEvent('apartments:client:RingDoor', function(player, _)
    currentDoorBell = player
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
    QBCore.Functions.Notify(Lang:t('info.at_the_door'))
end)

RegisterNetEvent('apartments:client:OpenDoor', function()
    if currentDoorBell == 0 then
        QBCore.Functions.Notify(Lang:t('error.nobody_at_door'))
        return
    end
    TriggerServerEvent("apartments:server:OpenDoor", currentDoorBell, currentApartmentId, currentEntrance)
    currentDoorBell = 0
end)

RegisterNetEvent('apartments:client:SetHomeBlip', function(home)
    CreateThread(function()
        for name, _ in pairs(Apartments.Locations) do
            RemoveBlip(Apartments.Locations[name].blip)

            Apartments.Locations[name].blip = AddBlipForCoord(Apartments.Locations[name].enter.x, Apartments.Locations[name].enter.y, Apartments.Locations[name].enter.z)
            if (name == home) then
                SetBlipSprite(Apartments.Locations[name].blip, 475)
                SetBlipCategory(Apartments.Locations[name].blip, 11)
            else
                SetBlipSprite(Apartments.Locations[name].blip, 476)
                SetBlipCategory(Apartments.Locations[name].blip, 10)
            end
            SetBlipDisplay(Apartments.Locations[name].blip, 4)
            SetBlipScale(Apartments.Locations[name].blip, 0.65)
            SetBlipAsShortRange(Apartments.Locations[name].blip, true)
            SetBlipColour(Apartments.Locations[name].blip, 3)

            AddTextEntry(Apartments.Locations[name].label, Apartments.Locations[name].label)
            BeginTextCommandSetBlipName(Apartments.Locations[name].label)
            EndTextCommandSetBlipName(Apartments.Locations[name].blip)
        end
    end)
end)

RegisterNetEvent('apartments:client:ChangeOutfit', function()
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "Clothes1", 0.4)
    TriggerEvent('qb-clothing:client:openOutfitMenu')
end)

RegisterNetEvent('apartments:client:Logout', function()
    TriggerServerEvent('qb-houses:server:LogoutLocation')
end)

RegisterNetEvent('apartments:client:OpenStash', function(apId)
    exports.ox_inventory:openInventory('stash', apId)
end)

RegisterNetEvent('apartments:client:SpawnInApartment', function(apartmentId, apartment, ownerCid)
    local pos = GetEntityCoords(cache.ped)
    local new = true
    
    if rangDoorbell then
        new = false
        local doorbelldist = #(pos - Apartments.Locations[rangDoorbell].enter.xyz)
        if doorbelldist > 5 then
            QBCore.Functions.Notify(Lang:t('error.to_far_from_door'))
            return
        end
    end

    currentApartment = apartment
    currentApartmentId = apartmentId
    enterApartment(apartment, apartmentId, new)
    isOwned = true
end)

RegisterNetEvent('qb-apartments:client:LastLocationHouse', function(apartmentType, apartmentId)
    currentApartmentId = apartmentType
    currentApartment = apartmentType
    enterApartment(apartmentType, apartmentId, false)
end)

-- Handlers
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName or not LocalPlayer.state.isLoggedIn then return end
    loggedIn()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    removeEntrances()
    if next(houseObj) then
        exports['qbx-interior']:DespawnInterior(houseObj, function()
            TriggerEvent('qb-weathersync:client:EnableSync')
            TriggerServerEvent("qb-apartments:returnBucket")
            DoScreenFadeIn(500)
            DoScreenFadeIn(1000)
        end)

        local coord = Apartments.Locations[currentApartment].enter
        SetEntityCoords(cache.ped, coord.x, coord.y, coord.z, false, false, false, false)
        SetEntityHeading(cache.ped, coord.w)
        removeInsidePoints(currentApartment)
        houseObj, poiOffsets = {}, {}
        currentApartment, currentApartmentId = nil, nil
        currentOffset = 0
        TriggerServerEvent('qb-apartments:returnBucket')
    end
end)

AddStateBagChangeHandler('isLoggedIn', _, function(_bagName, _key, value, _reserved, _replicated)
    if value then loggedIn() else loggedOff() end
end)

-- QB Spawn
RegisterNetEvent('apartments:client:setupSpawnUI', function(cData)
    local result = lib.callback.await('apartments:GetOwnedApartment', false, cData.citizenid)
    if result then
        TriggerEvent('qb-spawn:client:setupSpawns', cData, false, nil)
        TriggerEvent("apartments:client:SetHomeBlip", result.type)
    elseif Apartments.Starting then
        TriggerEvent('qb-spawn:client:setupSpawns', cData, true, Apartments.Locations)
    else
        TriggerEvent('qb-spawn:client:setupSpawns', cData, false, nil)
    end
    TriggerEvent('qb-spawn:client:openUI', true)
end)