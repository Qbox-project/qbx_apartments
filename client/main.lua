local QBCore = exports['qb-core']:GetCoreObject()
local ApartmentZones, HouseObj, POIOffsets = {}, {}, {}
local isOwned, RangDoorbell, currentOffset, currentApartment, currentApartmentId, currentEntrance, currentDoorBell = false, false, 0, nil, nil, nil, 0

-- Functions
local function OpenHouseAnim()
    lib.requestAnimDict('anim@heists@keycard@', 100)

    TaskPlayAnim(cache.ped, 'anim@heists@keycard@', 'exit', 5.0, 1.0, -1, 16, 0, false, false, false)
    RemoveAnimDict('anim@heists@keycard@')

    Wait(400)

    StopAnimTask(cache.ped, 'anim@heists@keycard@', 'exit', 1.0)
end

local function ShowEntranceHeaderMenu(id)
    local headerMenu = {}

    QBCore.Functions.TriggerCallback('apartments:IsOwner', function(result)
        isOwned = result

        if isOwned then
            headerMenu[#headerMenu + 1] = {
                title = Lang:t('text.enter'),
                icon = "fa-solid fa-door-open",
                event = 'apartments:client:EnterApartment',
                args = id
            }
        elseif not isOwned then
            headerMenu[#headerMenu + 1] = {
                title = Lang:t('text.move_here'),
                icon = "fa-solid fa-suitcase-rolling",
                event = 'apartments:client:UpdateApartment',
                args = id
            }
        end

        headerMenu[#headerMenu + 1] = {
            title = Lang:t('text.ring_doorbell'),
            icon = "fa-solid fa-bell",
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

local function ShowExitHeaderMenu()
    lib.registerContext({
        id = 'apartment_exit_context_menu',
        title = Lang:t('text.menu_header'),
        options = {
            {
                title = Lang:t('text.open_door'),
                icon = "fa-solid fa-lock",
                event = 'apartments:client:OpenDoor'
            },
            {
                title = Lang:t('text.leave'),
                icon = "fa-solid fa-door-open",
                event = 'apartments:client:LeaveApartment'
            }
        }
    })
    lib.showContext('apartment_exit_context_menu')
end

local function onEnter(self)
    lib.showTextUI("[E] - " .. Lang:t('text.' .. self.typ))

    currentEntrance = self.aptId
end

local function onExit(_)
    lib.hideTextUI()

    currentEntrance = nil
end

local function isInside(self)
    if IsControlJustPressed(0, 38) then
        if self.typ == 'enter' then
            ShowEntranceHeaderMenu(self.aptId)
        elseif self.typ == 'leave' then
            ShowExitHeaderMenu()
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

local function CreateEnterances()
    for id, data in pairs(Config.Apartments) do
        ApartmentZones[id] = {}
        ApartmentZones[id].enterance = lib.zones.sphere({
            coords = data.enter.xyz,
            radius = 1.5,
            debug = false,
            inside = isInside,
            onEnter = onEnter,
            onExit = onExit,
            typ = 'enter',
            aptId = id
        })
    end
end

local function RemoveEnterances()
    onExit()

    for id, _ in pairs(ApartmentZones) do
        ApartmentZones[id].enterance:remove()
    end
end

local function CreateInsidePoints(id, data)
    ApartmentZones[id].exit = lib.zones.sphere({
        coords = vec3(Config.Apartments[currentApartment].enter.x - data.exit.x, Config.Apartments[currentApartment].enter.y - data.exit.y - 0.5, Config.Apartments[currentApartment].enter.z - currentOffset + data.exit.z),
        radius = 1.0,
        debug = false,
        inside = isInside,
        onEnter = onEnter,
        onExit = onExit,
        typ = 'leave',
        aptId = id
    })
    ApartmentZones[id].stash = lib.zones.sphere({
        coords = vec3(Config.Apartments[currentApartment].enter.x - data.stash.x, Config.Apartments[currentApartment].enter.y - data.stash.y, Config.Apartments[currentApartment].enter.z - currentOffset + data.stash.z),
        radius = 1.0,
        debug = false,
        inside = isInside,
        onEnter = onEnter,
        onExit = onExit,
        typ = 'open_stash',
        aptId = id
    })
    ApartmentZones[id].clothes = lib.zones.sphere({
        coords = vec3(Config.Apartments[currentApartment].enter.x - data.clothes.x, Config.Apartments[currentApartment].enter.y - data.clothes.y, Config.Apartments[currentApartment].enter.z - currentOffset + data.clothes.z),
        radius = 1.0,
        debug = false,
        inside = isInside,
        onEnter = onEnter,
        onExit = onExit,
        typ = 'change_outfit',
        aptId = id
    })
    ApartmentZones[id].logout = lib.zones.sphere({
        coords = vec3(Config.Apartments[currentApartment].enter.x - data.logout.x, Config.Apartments[currentApartment].enter.y + data.logout.y, Config.Apartments[currentApartment].enter.z - currentOffset + data.logout.z),
        radius = 1.0,
        debug = false,
        inside = isInside,
        onEnter = onEnter,
        onExit = onExit,
        typ = 'logout',
        aptId = id
    })
end

local function RemoveInsidePoints(id)
    ApartmentZones[id].exit:remove()
    ApartmentZones[id].stash:remove()
    ApartmentZones[id].clothes:remove()
    ApartmentZones[id].logout:remove()
end

local function EnterApartment(house, apartmentId, new)
    currentApartmentId = apartmentId
    currentApartment = house

    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)

    OpenHouseAnim()

    QBCore.Functions.TriggerCallback('apartments:GetApartmentOffset', function(offset)
        if not offset then
            QBCore.Functions.TriggerCallback('apartments:GetApartmentOffsetNewOffset', function(newoffset)
                if newoffset > 230 then
                    newoffset = 210
                end

                currentOffset = newoffset

                TriggerServerEvent("apartments:server:AddObject", apartmentId, house, currentOffset)

                local coords = Config.Apartments[house].enter.xyz - vec3(0, 0, currentOffset)
                local data = exports['qb-interior']:CreateApartmentFurnished(coords)

                Wait(100)

                HouseObj = data[1]
                POIOffsets = data[2]
                RangDoorbell = false

                Wait(500)

                TriggerEvent('qb-weathersync:client:DisableSync')

                Wait(100)

                TriggerServerEvent('qb-apartments:server:SetInsideMeta', house, apartmentId, true, false)
                TriggerServerEvent("apartments:server:setCurrentApartment", apartmentId)

                CreateInsidePoints(house, POIOffsets)
            end, house)
        else
            if offset > 230 then
                offset = 210
            end

            currentOffset = offset

            TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
            TriggerServerEvent("apartments:server:AddObject", apartmentId, house, currentOffset)

            local coords = Config.Apartments[house].enter.xyz - vec3(0, 0, currentOffset)
            local data = exports['qb-interior']:CreateApartmentFurnished(coords)

            Wait(100)

            HouseObj = data[1]
            POIOffsets = data[2]

            Wait(500)

            TriggerEvent('qb-weathersync:client:DisableSync')

            Wait(100)

            TriggerServerEvent('qb-apartments:server:SetInsideMeta', house, apartmentId, true, true)
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
            TriggerServerEvent("apartments:server:setCurrentApartment", apartmentId)

            CreateInsidePoints(house, POIOffsets)
        end

        if new then
            SetTimeout(1250, function()
                TriggerEvent('qb-clothes:client:CreateFirstCharacter')
            end)
        end
    end, apartmentId)
end

local function MenuOwners()
    QBCore.Functions.TriggerCallback('apartments:GetAvailableApartments', function(apartments)
        if not next(apartments) then
            lib.notify({
                title = Lang:t('error.nobody_home'),
                duration = 3500,
                type = 'error'
            })
            lib.hideContext(false)
        else
            local aptsMenu = {}

            for k, v in pairs(apartments) do
                aptsMenu[#aptsMenu + 1] = {
                    title = v,
                    event = 'apartments:client:RingMenu',
                    args = {
                        apartmentId = k
                    }
                }
            end

            lib.registerContext({
                id = 'apartment_tennants_context_menu',
                title = Lang:t('text.tennants'),
                options = aptsMenu
            })
            lib.showContext('apartment_tennants_context_menu')
        end
    end, currentEntrance)
end

local function ExitApartment()
    -- Sound effect
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)

    -- Screen anim
    OpenHouseAnim()

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(10)
    end

    -- Remove Inside Points
    RemoveInsidePoints(currentApartment)

    -- Despawn Interior
    exports['qb-interior']:DespawnInterior(HouseObj, function()
        -- EnableSync
        TriggerEvent('qb-weathersync:client:EnableSync')

        -- Teleport PLayer outside
        SetEntityCoords(cache.ped, Config.Apartments[currentApartment].enter.xyz)
        SetEntityHeading(cache.ped, Config.Apartments[currentApartment].enter.w)

        Wait(1000)

        TriggerServerEvent("apartments:server:RemoveObject", currentApartmentId, currentApartment)
        TriggerServerEvent('qb-apartments:server:SetInsideMeta', currentApartmentId, false)

        currentOffset = 0

        DoScreenFadeIn(1000)

        TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
        TriggerServerEvent("apartments:server:setCurrentApartment", nil)

        HouseObj, POIOffsets = {}, {}
        currentApartment, currentApartmentId = nil, nil
    end)
end

function LoggedIn()
    CreateEnterances()
end

function LoggedOff()
    -- Remove Enterence Zones
    RemoveEnterances()

    -- If you are not in a apartment, then just return
    if not currentApartment then
        return
    end

    -- Remove Inside Points
    RemoveInsidePoints(currentApartment)

    -- Despawn Interior
    exports['qb-interior']:DespawnInterior(HouseObj, function()
        -- EnableSync
        TriggerEvent('qb-weathersync:client:EnableSync')

        -- Teleport PLayer outside
        --- @diagnostic disable-next-line: param-type-mismatch
        SetEntityCoords(cache.ped, Config.Apartments[currentApartment].enter.xyz)
        SetEntityHeading(cache.ped, Config.Apartments[currentApartment].enter.w)

        Wait(1000)

        TriggerServerEvent("apartments:server:RemoveObject", currentApartmentId, currentApartment)

        currentOffset = 0

        DoScreenFadeIn(1000)

        TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
        TriggerServerEvent("apartments:server:setCurrentApartment", nil)

        HouseObj, POIOffsets = {}, {}
        currentApartment, currentApartmentId = nil, nil
    end)
end

-- Events
RegisterNetEvent('apartments:client:EnterApartment', function(id)
    QBCore.Functions.TriggerCallback('apartments:GetOwnedApartment', function(result)
        if result then
            EnterApartment(id, result.name, false)
        end
    end)
end)

RegisterNetEvent('apartments:client:UpdateApartment', function(id)
    TriggerServerEvent("apartments:server:UpdateApartment", id, Config.Apartments[id].label)

    isOwned = true
end)

RegisterNetEvent('apartments:client:LeaveApartment', function()
    if not currentApartment then
        return
    end

    ExitApartment()
end)

RegisterNetEvent('apartments:client:DoorbellMenu', function()
    MenuOwners()
end)

RegisterNetEvent('apartments:client:RingMenu', function(data)
    RangDoorbell = currentEntrance

    TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
    TriggerServerEvent("apartments:server:RingDoor", data.apartmentId, currentEntrance)
end)

RegisterNetEvent('apartments:client:RingDoor', function(player, _)
    currentDoorBell = player

    TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)

    lib.notify({
        description = Lang:t('info.at_the_door')
    })
end)

RegisterNetEvent('apartments:client:OpenDoor', function()
    if currentDoorBell == 0 then
        lib.notify({
            description = Lang:t('error.nobody_at_door'),
            type = 'error'
        })
        return
    end

    TriggerServerEvent("apartments:server:OpenDoor", currentDoorBell, currentApartmentId, currentEntrance)

    currentDoorBell = 0
end)

RegisterNetEvent('apartments:client:SetHomeBlip', function(home)
    CreateThread(function()
        for name, _ in pairs(Config.Apartments) do
            RemoveBlip(Config.Apartments[name].blip)

            Config.Apartments[name].blip = AddBlipForCoord(Config.Apartments[name].enter.x, Config.Apartments[name].enter.y, Config.Apartments[name].enter.z)

            if name == home then
                SetBlipSprite(Config.Apartments[name].blip, 475)
                SetBlipCategory(Config.Apartments[name].blip, 11)
            else
                SetBlipSprite(Config.Apartments[name].blip, 476)
                SetBlipCategory(Config.Apartments[name].blip, 10)
            end

            SetBlipDisplay(Config.Apartments[name].blip, 4)
            SetBlipScale(Config.Apartments[name].blip, 0.65)
            SetBlipAsShortRange(Config.Apartments[name].blip, true)
            SetBlipColour(Config.Apartments[name].blip, 3)

            AddTextEntry(Config.Apartments[name].label, Config.Apartments[name].label)
            BeginTextCommandSetBlipName(Config.Apartments[name].label)
            EndTextCommandSetBlipName(Config.Apartments[name].blip)
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

RegisterNetEvent('apartments:client:SpawnInApartment', function(apartmentId, apartment)
    local pos = GetEntityCoords(cache.ped)
    local new = true

    if RangDoorbell then
        new = false

        local doorbelldist = #(pos - vec3(Config.Apartments[RangDoorbell].enter.x, Config.Apartments[RangDoorbell].enter.y, Config.Apartments[RangDoorbell].enter.z))

        if doorbelldist > 5 then
            lib.notify({
                description = Lang:t('error.to_far_from_door')
            })
            return
        end
    end

    currentApartment = apartment
    currentApartmentId = apartmentId

    EnterApartment(apartment, apartmentId, new)

    isOwned = true
end)

RegisterNetEvent('qb-apartments:client:LastLocationHouse', function(apartmentType, apartmentId)
    currentApartmentId = apartmentType
    currentApartment = apartmentType

    EnterApartment(apartmentType, apartmentId, false)
end)

-- Handlers
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName or not LocalPlayer.state.isLoggedIn then
        return
    end

    LoggedIn()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        RemoveEnterances()

        if next(HouseObj) then
            exports['qb-interior']:DespawnInterior(HouseObj, function()
                TriggerEvent('qb-weathersync:client:EnableSync')
                TriggerServerEvent("qb-apartments:returnBucket")

                DoScreenFadeIn(500)
                DoScreenFadeIn(1000)
            end)

            SetEntityCoords(cache.ped, Config.Apartments[currentApartment].enter.x, Config.Apartments[currentApartment].enter.y,Config.Apartments[currentApartment].enter.z)
            SetEntityHeading(cache.ped, Config.Apartments[currentApartment].enter.w)

            RemoveInsidePoints(currentApartment)

            HouseObj, POIOffsets = {}, {}
            currentApartment, currentApartmentId = nil, nil
            currentOffset = 0

            TriggerServerEvent('qb-apartments:returnBucket')
        end
    end
end)

AddStateBagChangeHandler('isLoggedIn', _, function(_, _, value, _, _)
    if value then
        LoggedIn()
    else
        LoggedOff()
    end
end)

-- QB Spawn
RegisterNetEvent('apartments:client:setupSpawnUI', function(cData)
    QBCore.Functions.TriggerCallback('apartments:GetOwnedApartment', function(result)
        if result then
            TriggerEvent('qb-spawn:client:setupSpawns', cData, false, nil)
            TriggerEvent('qb-spawn:client:openUI', true)
            TriggerEvent("apartments:client:SetHomeBlip", result.type)
        else
            if Config.ApartmentsStarting then
                TriggerEvent('qb-spawn:client:setupSpawns', cData, true, Config.Apartments)
                TriggerEvent('qb-spawn:client:openUI', true)
            else
                TriggerEvent('qb-spawn:client:setupSpawns', cData, false, nil)
                TriggerEvent('qb-spawn:client:openUI', true)
            end
        end
    end, cData.citizenid)
end)