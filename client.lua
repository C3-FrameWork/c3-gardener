local Base = Config.Gardener.Base
local Garage = Config.Gardener.Garage
local Marker = Config.Gardener.DefaultMarker
local GarageSpawnPoint = Config.Gardener.GarageSpawnPoint
local Type = nil
local AmountPayout = 0
local done = 0
local PlayerData = {}
local salary = nil

onDuty = false
hasCar = false
inGarageMenu = false
inMenu = false
wasTalked = false
appointed = false
waitingDone = false
CanWork = false
Paycheck = false

hasOpenDoor = false
hasBlower = false
hasTrimmer = false
hasLawnMower = false
hasBackPack = false

Citizen.CreateThread(function()
	while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
		Citizen.Wait(5)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

function Randomize(tb)
	local keys = {}
	for k in pairs(tb) do table.insert(keys, k) end
	return tb[keys[math.random(#keys)]]
end

-- BASE
Citizen.CreateThread(function()
    while true do

        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

            if PlayerData.job ~= nil and PlayerData.job.grade_name == 'gardener' then
                if (GetDistanceBetweenCoords(coords, Base.Pos.x, Base.Pos.y, Base.Pos.z, true) < 8) then
                    sleep = 5
                    DrawMarker(Base.Type, Base.Pos.x, Base.Pos.y, Base.Pos.z - 0.95, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Base.Size.x, Base.Size.y, Base.Size.z, Base.Color.r, Base.Color.g, Base.Color.b, 100, false, true, 2, false, false, false, false)
                    if (GetDistanceBetweenCoords(coords, Base.Pos.x, Base.Pos.y, Base.Pos.z, true) < 1.2) then
                        if not onDuty then
                            sleep = 5
                            DrawText3Ds(Base.Pos.x, Base.Pos.y, Base.Pos.z + 0.4, '~g~[E]~s~ - Change your clothes with working clothes!')
                            if IsControlJustPressed(0, Keys["E"]) then
                                exports.rprogress:Custom({
                                    Duration = 2500,
                                    Label = "You are changing your clothes...",
                                    Animation = {
                                        scenario = "WORLD_HUMAN_COP_IDLES",
                                        animationDictionary = "idle_a",
                                    },
                                    DisableControls = {
                                        Mouse = false,
                                        Player = true,
                                        Vehicle = true
                                    }
                                })
                                Citizen.Wait(2500)
                                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                                if skin.sex == 0 then
                                    TriggerEvent('skinchanger:loadClothes', skin, Config.Clothes.male)
                                elseif skin.sex == 1 then
                                    TriggerEvent('skinchanger:loadClothes', skin, Config.Clothes.female)
                                end
                                end)
                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You started the work!", timeout = 3000})
                                onDuty = true
                                addGarageBlip()
                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>To open your job menu click button <b>[DEL]</b>", timeout = 6000})
                            end
                        elseif onDuty then
                            sleep = 5
                            DrawText3Ds(Base.Pos.x, Base.Pos.y, Base.Pos.z + 0.4, '~r~[E]~s~ - Change clothes with yours!')
                            if IsControlJustPressed(0, Keys["E"]) then
                                exports.rprogress:Custom({
                                    Duration = 2500,
                                    Label = "You are changing clothes...",
                                    Animation = {
                                        scenario = "WORLD_HUMAN_COP_IDLES",
                                        animationDictionary = "idle_a",
                                    },
                                    DisableControls = {
                                        Mouse = false,
                                        Player = true,
                                        Vehicle = true
                                    }
                                })
                                Citizen.Wait(2500)
                                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                                    TriggerEvent('skinchanger:loadSkin', skin)
                                end)
                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You finished the work!", timeout = 3000})
                                onDuty = false
                                removeGarageBlip()
                            end
                        end
                    end
                end
            end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do

        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

            if PlayerData.job ~= nil and PlayerData.job.grade_name == 'gardener' then
                if onDuty then
                    if not inMenu then
                        sleep = 2
                        if IsControlJustPressed(0, Keys["DEL"]) then
                            inMenu = true
                        end
                    elseif inMenu then
                        sleep = 2
                        DrawText3Dss(coords.x, coords.y, coords.z + 1.0, '~g~[7]~s~ - Search a work | ~r~[8]~s~ - Cancel the search')
                        if IsControlJustPressed(0, Keys["DEL"]) then
                            inMenu = false
                        elseif IsControlJustPressed(0, Keys["7"]) then
                            if Type == nil then
                                inMenu = false
                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>They finding a customer for you...", timeout = 15000})
                                Citizen.Wait(15000)
                                Gardens = Randomize(Config.Gardens)
                                CreateWork(Gardens.StreetHouse)
                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>GPS location was submited, drive to " ..Gardens.StreetHouse, timeout = 2000})
                                salary = math.random(300, 900)
                                if Type == "Rockford Hills" then
                                    for i, v in ipairs(Config.RockfordHills) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "West Vinewood" then
                                    for i, v in ipairs(Config.WestVinewood) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "Vinewood Hills" then
                                    for i, v in ipairs(Config.VinewoodHills) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "El Burro Heights" then
                                    for i, v in ipairs(Config.ElBurroHeights) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "Richman" then
                                    for i, v in ipairs(Config.Richman) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "Mirror Park" then
                                    for i, v in ipairs(Config.MirrorPark) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                elseif Type == "East Vinewood" then
                                    for i, v in ipairs(Config.EastVinewood) do
                                        SetNewWaypoint(v.x, v.y, v.z)
                                    end
                                end
                            else
                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You are searching for work from before!", timeout = 2000})
                            end
                        elseif IsControlJustPressed(0, Keys["8"]) then
                            if Type then
                                CancelWork()
                                DeleteWaypoint()
                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You canceled the customer", timeout = 2000})
                            elseif not Type then
                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You don't have now any work, take a rest!", timeout = 4000})
                            end
                        end
                    end
                end
            end
        Citizen.Wait(sleep)
    end
end)

-- GARAGE MENU
Citizen.CreateThread(function()
    while true do

        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local WLCar = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

            if PlayerData.job ~= nil and PlayerData.job.grade_name == 'gardener' then
                if onDuty then
                    if (GetDistanceBetweenCoords(coords, Garage.Pos.x, Garage.Pos.y, Garage.Pos.z, true) < 8) then
                        sleep = 5
                        DrawMarker(Marker.Type, Garage.Pos.x, Garage.Pos.y, Garage.Pos.z - 0.95, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Garage.Size.x, Garage.Size.y, Garage.Size.z, Garage.Color.r, Garage.Color.g, Garage.Color.b, 100, false, true, 2, false, false, false, false)
                        if (GetDistanceBetweenCoords(coords, Garage.Pos.x, Garage.Pos.y, Garage.Pos.z, true) < 1.2) then
                            if IsPedInAnyVehicle(ped, false) then
                                sleep = 5
                                DrawText3Ds(Garage.Pos.x, Garage.Pos.y, Garage.Pos.z + 0.4, '~r~[E]~s~ - Give the vehicle back!')
                                if IsControlJustReleased(0, Keys["E"]) then
                                    if hasCar then
                                        TriggerServerEvent('c3-vrtnar:returnVehicle', source)
                                        ReturnVehicle()
                                        exports.pNotify:SendNotification({text = '<b>GARDENER</b></br>You got ' ..Config.DepositPrice.. '$ for returned vehicle', timeout = 1500})
                                        hasCar = false
                                        Plate = nil
                                    else
                                        exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You didn't payed for vehicle!", timeout = 2500})
                                    end
                                end
                            elseif not IsPedInAnyVehicle(ped, false) then
                                sleep = 5
                                if not inGarageMenu then
                                    DrawText3Ds(Garage.Pos.x, Garage.Pos.y, Garage.Pos.z + 0.4, '~g~[E]~s~ - Open the menu of the car!')
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        if not inMenu then
                                            FreezeEntityPosition(ped, true)
                                            inGarageMenu = true
                                            exports.pNotify:SendNotification({text = '<b>GARDENER</b></br>Select the vehicle place', timeout = 2500})
                                        elseif inMenu then
                                            exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>Close menu!", timeout = 2500})
                                        end
                                    end
                                elseif inGarageMenu then
                                    DrawText3DMenu(Garage.Pos.x - 0.8, Garage.Pos.y, Garage.Pos.z + 0.8, '~g~[7]~s~ - Parking slot #1\n~g~[8]~s~ - Parking slot #2\n~r~[E]~s~ - Close menu ')
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        inGarageMenu = false
                                        FreezeEntityPosition(ped, false)
                                    elseif IsControlJustReleased(0, Keys["7"]) then
                                        if not hasCar then
                                            ESX.TriggerServerCallback('c3-vrtnar:checkMoney', function(hasMoney)
                                            if hasMoney then
                                                ESX.Game.SpawnVehicle(Config.CompanyVehicle, vector3(GarageSpawnPoint.Pos1.x, GarageSpawnPoint.Pos1.y, GarageSpawnPoint.Pos1.z), GarageSpawnPoint.Pos1.h, function(vehicle)
                                                SetVehicleNumberPlateText(vehicle, "GRD"..tostring(math.random(1000, 9999)))
                                                SetVehicleEngineOn(vehicle, true, true)
                                                exports.pNotify:SendNotification({text = '<b>GARDENER</b></br>You payed ' ..Config.DepositPrice.. '$ for car insurance', timeout = 2000})
                                                hasCar = true
                                                Plate = GetVehicleNumberPlateText(vehicle)
                                                end)
                                                inGarageMenu = false
                                                FreezeEntityPosition(ped, false)
                                            else
                                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You don't have enough money!", timeout = 2500})
                                                inGarageMenu = false
                                                FreezeEntityPosition(ped, false)
                                            end
                                            end)
                                        elseif hasCar then
                                            exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>First give back the vehicle", timeout = 2500})
                                        end
                                    elseif IsControlJustReleased(0, Keys["8"]) then
                                        if not hasCar then
                                            ESX.TriggerServerCallback('c3-vrtnar:checkMoney', function(hasMoney)
                                            if hasMoney then
                                                ESX.Game.SpawnVehicle(Config.CompanyVehicle, vector3(GarageSpawnPoint.Pos2.x, GarageSpawnPoint.Pos2.y, GarageSpawnPoint.Pos2.z), GarageSpawnPoint.Pos2.h, function(vehicle)
                                                SetVehicleNumberPlateText(vehicle, "GRD"..tostring(math.random(1000, 9999)))
                                                SetVehicleEngineOn(vehicle, true, true)
                                                exports.pNotify:SendNotification({text = '<b>GARDENER</b></br>You Payed ' ..Config.DepositPrice.. '$ for vehicle insurance', timeout = 1500})
                                                hasCar = true
                                                Plate = GetVehicleNumberPlateText(vehicle)
                                                end)
                                                inGarageMenu = false
                                                FreezeEntityPosition(ped, false)
                                            else
                                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You don't enough money", timeout = 2500})
                                                inGarageMenu = false
                                                FreezeEntityPosition(ped, false)
                                            end
                                            end)
                                        elseif hasCar then
                                            exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>First return the vehicle", timeout = 2500})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        Citizen.Wait(sleep)
    end
end)

-- OPENING VAN DOORS
Citizen.CreateThread(function()
    while true do

        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), true)

            if hasCar then
                if not IsPedInAnyVehicle(ped, false) then
                    if Plate == GetVehicleNumberPlateText(vehicle) then
                        local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.0, 0)
                        if (GetDistanceBetweenCoords(coords.x, coords.y, coords.z, trunkpos.x, trunkpos.y, trunkpos.z, true) < 2) then
                            if not hasOpenDoor then
                                sleep = 5
                                DrawText3Ds(trunkpos.x, trunkpos.y, trunkpos.z + 0.4, "~g~[G]~s~ - Open doors")
                                if IsControlJustReleased(0, Keys["G"]) then
                                    exports.rprogress:Custom({
                                        Duration = 1600,
                                        Label = "You are opening the doors",
                                        DisableControls = {
                                            Mouse = false,
                                            Player = true,
                                            Vehicle = true
                                        }
                                    })
                                    Citizen.Wait(1500)
                                    SetVehicleDoorOpen(vehicle, 3, false, false)
                                    SetVehicleDoorOpen(vehicle, 2, false, false)
                                    hasOpenDoor = true
                                end
                            elseif hasOpenDoor then
                                if not hasBlower and not hasLawnMower and not hasTrimmer and not hasBackPack then
                                    sleep = 5
                                    DrawText3Ds(trunkpos.x, trunkpos.y, trunkpos.z + 0.7, "~g~[E]~s~ - Leaf blower | ~g~[H]~s~ Backpack")
                                    DrawText3Ds(trunkpos.x, trunkpos.y, trunkpos.z + 0.5, "~g~[7]~s~ - A trimmer | ~g~[8]~s~ - Lawn Mower")
                                    DrawText3Ds(trunkpos.x, trunkpos.y, trunkpos.z + 0.3, "~r~[G]~s~ - Close the Doors")
                                    if IsControlJustReleased(0, Keys["G"]) then
                                        exports.rprogress:Custom({
                                            Duration = 1600,
                                            Label = "You are closing the rear doors",
                                            DisableControls = {
                                                Mouse = false,
                                                Player = true,
                                                Vehicle = true
                                            }
                                        })
                                        Citizen.Wait(1500)
                                        SetVehicleDoorShut(vehicle, 3, false)
                                        SetVehicleDoorShut(vehicle, 2, false)
                                        hasOpenDoor = false
                                    elseif IsControlJustReleased(0, Keys["E"]) then
                                        exports.rprogress:Custom({
                                            Duration = 1500,
                                            Label = "You are search for Leaf Blower...",
                                            DisableControls = {
                                                Mouse = false,
                                                Player = true,
                                                Vehicle = true
                                            }
                                        })
                                        Citizen.Wait(1500)
                                        addLeafBlower()
                                        hasBlower = true
                                    elseif IsControlJustReleased(0, Keys["H"]) then
                                        exports.rprogress:Custom({
                                            Duration = 1500,
                                            Label = "You are searching for Backpack...",
                                            DisableControls = {
                                                Mouse = false,
                                                Player = true,
                                                Vehicle = true
                                            }
                                        })
                                        Citizen.Wait(1500)
                                        addBackPack()
                                        hasBackPack = true
                                    elseif IsControlJustReleased(0, Keys["7"]) then
                                        exports.rprogress:Custom({
                                            Duration = 1500,
                                            Label = "You are searching for a Trimmer...",
                                            DisableControls = {
                                                Mouse = false,
                                                Player = true,
                                                Vehicle = true
                                            }
                                        })
                                        Citizen.Wait(1500)
                                        addTrimmer()
                                        hasTrimmer = true
                                    elseif IsControlJustReleased(0, Keys["8"]) then
                                        exports.rprogress:Custom({
                                            Duration = 1500,
                                            Label = "You are searching for Lawn Mower...",
                                            DisableControls = {
                                                Mouse = false,
                                                Player = true,
                                                Vehicle = true
                                            }
                                        })
                                        Citizen.Wait(1500)
                                        addLawnMower()
                                        hasLawnMower = true
                                    end
                                elseif hasLawnMower or hasBlower or hasBackPack or hasTrimmer then
                                    sleep = 5
                                    DrawText3Ds(trunkpos.x, trunkpos.y, trunkpos.z + 0.5, "~g~[E]~s~ - Daj v prtljažnik")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        exports.rprogress:Custom({
                                            Duration = 1500,
                                            Label = "You are returning all tools to the van...",
                                            DisableControls = {
                                                Mouse = false,
                                                Player = true,
                                                Vehicle = true
                                            }
                                        })
                                        Citizen.Wait(1500)
                                        removeLawnMower()
                                        removeBackPack()
                                        removeLeafBlower()
                                        removeTrimmer()
                                        hasLawnMower = false
                                        hasBlower = false
                                        hasTrimmer = false
                                        hasBackPack = false
                                        ClearPedTasks(ped)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do

        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

            if Type == 'Rockford Hills' then
                for i, v in ipairs(Config.RockfordHills) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Hello, would you complete my garden for ~g~' ..salary.. '$~s~?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[7]~s~ - Yes, OFC | ~r~[8]~s~ - No fuck off! ')
                                if IsControlJustReleased(0, Keys["7"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>Take out the weeds of the garden", timeout = 5000})
                                    BlipsWorkingRH()
                                elseif IsControlJustReleased(0, Keys["8"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Good, we're going to get a better gardener!")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Super, When you'll complete say, I'll be at the doors!")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "You didn't complete already")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Garden is FANTASTIC, here is your pay")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[E]~s~ - Take money')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                TriggerServerEvent('c3-vrtnar:Payout', salary, AmountPayout)
                                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You got " ..salary.. "$!", timeout = 2500})
                                                ESX.Streaming.RequestAnimDict('mp_common', function()
                                                    TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                end)
                                                ESX.Streaming.RequestAnimDict('mp_common', function()
                                                    TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                end)
                                                Citizen.Wait(3500)
                                                ClearPedTasks(ped)
                                                CancelWork()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.RockfordHillsWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~g~[E]~s~ - Pull out weeds")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        ESX.Streaming.RequestAnimDict('amb@world_human_gardener_plant@male@enter', function()
                                            TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@enter', 'enter', 8.0, -8.0, -1, 2, 0, false, false, false)
                                        end)
                                        exports.rprogress:Custom({
                                            Duration = 3500,
                                            Label = "You are Pulling weeds...",
                                            DisableControls = {
                                                Mouse = false,
                                                Player = true,
                                                Vehicle = true
                                            }
                                        })
                                        Citizen.Wait(3500)
                                        v.taked = true
                                        RemoveBlip(v.blip)
                                        done = done + 1
                                        ClearPedTasks(ped)
                                        if done == #Config.RockfordHillsWork then
                                            Paycheck = true
                                            done = 0
                                            AmountPayout = AmountPayout + 1
                                            exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>Garden is clear, go get you money", timeout = 2500})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Type == "West Vinewood" then
                for i, v in ipairs(Config.WestVinewood) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Good day, would you plant trees for ~g~' ..salary.. '$~s~?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[7]~s~ - Of course! | ~r~[8]~s~ - No, forget it')
                                if IsControlJustReleased(0, Keys["7"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    exports.pNotify:SendNotification({text = "<b>Gardener</b></br>Planting trees by the driveway", timeout = 5000})
                                    BlipsWorkingWV()
                                elseif IsControlJustReleased(0, Keys["8"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Alright, we'll find a better gardener!")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "We'll wait for you by the pool")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "You haven't planted all the trees yet")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Now just wait for them to grow! Go get your paycheck")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[E]~s~ - Take money')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                TriggerServerEvent('c3-vrtnar:Payout', salary, AmountPayout)
                                                exports.pNotify:SendNotification({text = "<b>Gardener</b></br>You earned " ..salary.. "$!", timeout = 2500})
                                                ESX.Streaming.RequestAnimDict('mp_common', function()
                                                    TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                end)
                                                ESX.Streaming.RequestAnimDict('mp_common', function()
                                                    TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                end)
                                                Citizen.Wait(3500)
                                                ClearPedTasks(ped)
                                                CancelWork()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
                if CanWork then
                    for i, v in ipairs(Config.WestVinewoodWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~g~[E]~s~ - Plant a tree")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        exports.rprogress:Custom({
                                            Duration = 5500,
                                            Label = "Planting a tree...",
                                            Animation = {
                                                scenario = "WORLD_HUMAN_GARDENER_PLANT",
                                                animationDictionary = "enter",
                                            },
                                            DisableControls = {
                                                Mouse = false,
                                                Player = true,
                                                Vehicle = true
                                            }
                                        })
                                        ClearPedTasks(ped)
                                        v.taked = true
                                        RemoveBlip(v.blip)
                                        done = done + 1
                                        if done == #Config.WestVinewoodWork then
                                            Paycheck = true
                                            done = 0
                                            AmountPayout = AmountPayout + 1
                                            exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>All trees was planted, go back to the van, and then find the Customer for Paycheck", timeout = 2500})
                                        end
                                    end
                                end
                            end
                        end
                    end
            elseif Type == "Vinewood Hills" then
                for i, v in ipairs(Config.VinewoodHills) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Hello, would you complete my garden for ~g~' ..salary.. '$~s~?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[7]~s~ - Yes, OFC | ~r~[8]~s~ - No, who cares!')
                                if IsControlJustReleased(0, Keys["7"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>Take out the weeds from the garden", timeout = 5000})
                                    BlipsWorkingRH()
                                elseif IsControlJustReleased(0, Keys["8"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Alright, fuck off before I call the police!")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Great! When you finish, come to the terrace!")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "You haven't finished yet!")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Fantastic garden! Here's your payment")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[E]~s~ - Take the money')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                if not hasBlower then
                                                    TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                    TriggerServerEvent('c3-vrtnar:Payout', salary, AmountPayout)
                                                    exports.pNotify:SendNotification({text = "<b>Gardener</b></br>You earned " ..salary.. "$!", timeout = 2500})
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    Citizen.Wait(3500)
                                                    ClearPedTasks(ped)
                                                    CancelWork()
                                                elseif hasBlower then
                                                    exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>Put the leaf blower back in the trunk", timeout = 3000})
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.VinewoodHillsWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~g~[E]~s~ - Leaf the grass")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        if hasBlower then
                                            ESX.Streaming.RequestAnimDict('amb@world_human_gardener_leaf_blower@idle_a', function()
                                                TaskPlayAnim(ped, 'amb@world_human_gardener_leaf_blower@idle_a', 'idle_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                            end)
                                            exports.rprogress:Custom({
                                                Duration = 5500,
                                                Label = "You are leafing the grass...",
                                                DisableControls = {
                                                    Mouse = false,
                                                    Player = true,
                                                    Vehicle = true
                                                }
                                            })
                                            Citizen.Wait(5500)
                                            ClearPedTasks(ped)
                                            v.taked = true
                                            RemoveBlip(v.blip)
                                            done = done + 1
                                            if done == #Config.VinewoodHillsWork then
                                                Paycheck = true
                                                done = 0
                                                AmountPayout = AmountPayout + 1
                                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>All grass was leafed, take your money and go.", timeout = 2500})
                                            end
                                        elseif not hasBlower then
                                            exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You don't have a leaf blower.", timeout = 2500})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Type == "El Burro Heights" then
                for i, v in ipairs(Config.ElBurroHeights) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Hello, would you complete my garden for ~g~' ..salary.. '$~s~?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[7]~s~ - Yes, OFC | ~r~[8]~s~ - No fuck off! ')
                                if IsControlJustReleased(0, Keys["7"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Hello, would you complete my garden for ~g~' ..salary.. '$~s~?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[7]~s~ - Yes, OFC | ~r~[8]~s~ - No, who cares!')
                                if IsControlJustReleased(0, Keys["7"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>Take out the weeds from the garden", timeout = 5000})
                                    BlipsWorkingRH()
                                elseif IsControlJustReleased(0, Keys["8"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Alright, fuck off before I call the police!")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Great! When you finish, come to the terrace!")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "You haven't finished yet!")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Fantastic garden! Here's your payment")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[E]~s~ - Take the money')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                if not hasBlower then
                                                    TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                    TriggerServerEvent('c3-vrtnar:Payout', salary, AmountPayout)
                                                    exports.pNotify:SendNotification({text = "<b>Gardener</b></br>You earned " ..salary.. "$!", timeout = 2500})
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    Citizen.Wait(3500)
                                                    ClearPedTasks(ped)
                                                    CancelWork()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.ElBurroHeightsWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~g~[E]~s~ - Pull out the grass")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        ESX.Streaming.RequestAnimDict('amb@world_human_gardener_plant@male@idle_a', function()
                                            TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@idle_a', 'idle_c', 8.0, -8.0, -1, 2, 0, false, false, false)
                                        end)
                                        exports.rprogress:Custom({
                                            Duration = 5500,
                                            Label = "You are pulling the grass out...",
                                            DisableControls = {
                                                Mouse = false,
                                                Player = true,
                                                Vehicle = true
                                            }
                                        })
                                        Citizen.Wait(5500)
                                        ClearPedTasks(ped)
                                        v.taked = true
                                        RemoveBlip(v.blip)
                                        done = done + 1
                                        if done == #Config.ElBurroHeightsWork then
                                            Paycheck = true
                                            done = 0
                                            AmountPayout = AmountPayout + 1
                                            exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You pulled out every grass, go to the customer for paycheck", timeout = 2500})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Type == "Richman" then
                for i, v in ipairs(Config.Richman) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Hello, would you complete my garden for ~g~' ..salary.. '$~s~?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[7]~s~ - Yes, OFC | ~r~[8]~s~ - No fuck off! ')
                                if IsControlJustReleased(0, Keys["7"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>Go, take the trimmer and start the work", timeout = 5000})
                                    BlipsWorkingRM()
                                elseif IsControlJustReleased(0, Keys["8"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Okey, I'll get a different garder")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "I'll wait here")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "You didn't trimmed all of the Hedge")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "Here's you're money, you did very well")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[E]~s~ - Take the Money')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                if not hasTrimmer then
                                                    TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                    TriggerServerEvent('c3-vrtnar:Payout', salary, AmountPayout)
                                                    exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You earned " ..salary.. "$!", timeout = 2500})
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    Citizen.Wait(3500)
                                                    ClearPedTasks(ped)
                                                    CancelWork()
                                                elseif hasTrimmer then
                                                    exports.pNotify:SendNotification({text = "<b>Vrtnar</b></br>Return the Trimmer back into the van.", timeout = 2500})
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.RichmanWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~g~[E]~s~ - Timm the Hedges")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        if hasTrimmer then
                                            ESX.Streaming.RequestAnimDict('anim@mp_radio@garage@high', function()
                                                TaskPlayAnim(ped, 'anim@mp_radio@garage@high', 'idle_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                            end)
                                            exports.rprogress:Custom({
                                                Duration = 5500,
                                                Label = "You are trimming hadges...",
                                                DisableControls = {
                                                    Mouse = false,
                                                    Player = true,
                                                    Vehicle = true
                                                }
                                            })
                                            Citizen.Wait(5500)
                                            ClearPedTasks(ped)
                                            v.taked = true
                                            RemoveBlip(v.blip)
                                            done = done + 1
                                            if done == #Config.RichmanWork then
                                                Paycheck = true
                                                done = 0
                                                AmountPayout = AmountPayout + 1
                                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>Hedges were trimmed, return to the van and go to your payment", timeout = 2500})
                                            end
                                        elseif not hasTrimmer then
                                            exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You don't habe Trimmer", timeout = 2500})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Type == "Mirror Park" then
                for i, v in ipairs(Config.MirrorPark) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Hello, would you complete my garden for ~g~' ..salary.. '$~s~?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[7]~s~ - Yes, OFC | ~r~[8]~s~ - No fuck off! ')
                                if IsControlJustReleased(0, Keys["7"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    exports.pNotify:SendNotification({text = "<b>Vrtnar</b></br>Take thet mower out an mowe the lawn.", timeout = 5000})
                                    BlipsWorkingMP()
                                elseif IsControlJustReleased(0, Keys["8"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Okey, will see another time...")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "When you'll be complete, come for payment")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "You didn't complete the lawn already")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "What a beauty, you did a good work")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[E]~s~ - Take the Money')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                if not hasLawnMower then
                                                    TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                    TriggerServerEvent('c3-vrtnar:Payout', salary, AmountPayout)
                                                    exports.pNotify:SendNotification({text = "<b>Vrtnar</b></br>You earned " ..salary.. "$!", timeout = 2500})
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    Citizen.Wait(3500)
                                                    ClearPedTasks(ped)
                                                    CancelWork()
                                                elseif hasLawnMower then
                                                    exports.pNotify:SendNotification({text = "<b>Vrtnar</b></br>Return the mower to the van back", timeout = 2500})
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.MirrorParkWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~g~[E]~s~ - Start with law mowing")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        if hasLawnMower then
                                            v.taked = true
                                            RemoveBlip(v.blip)
                                            done = done + 1
                                            if done == #Config.MirrorParkWork then
                                                Paycheck = true
                                                done = 0
                                                AmountPayout = AmountPayout + 1
                                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You did mow everywhere, go get your payment", timeout = 2500})
                                            end
                                        elseif not hasLawnMower then
                                            exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You don't have a lawn mower", timeout = 2500})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Type == "East Vinewood" then
                for i, v in ipairs(Config.EastVinewood) do
                    local coordsNPC = GetEntityCoords(v.ped, false)
                    sleep = 5
                    if not IsPedInAnyVehicle(ped, false) then
                        if not wasTalked then
                            if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, 'Hello, would you complete my garden for ~g~' ..salary.. '$~s~?')
                                DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[7]~s~ - Yes, OFC | ~r~[8]~s~ - No fuck off! ')
                                if IsControlJustReleased(0, Keys["7"]) then
                                    wasTalked = true
                                    appointed = true
                                    CanWork = true
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                    exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>Take out the backpack and start with work!", timeout = 5000})
                                    BlipsWorkingEV()
                                elseif IsControlJustReleased(0, Keys["8"]) then
                                    wasTalked = true
                                    appointed = false
                                    FreezeEntityPosition(v.ped, false)
                                    TaskGoToCoordAnyMeans(v.ped, v.houseX, v.houseY, v.houseZ, 1.3)
                                end
                            end
                        elseif wasTalked then
                            if not appointed then
                                if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 3.5) then
                                    DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "Your problem, fuck off!")
                                elseif (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                    CancelWork()
                                end
                            elseif appointed then
                                if not waitingDone then
                                    if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                        DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 1.05, "When you'll complete, come for a payment")
                                    end
                                    if (GetDistanceBetweenCoords(coordsNPC, v.houseX, v.houseY, v.houseZ, true) < 0.35) then
                                        ClearPedTasksImmediately(v.ped)
                                        FreezeEntityPosition(v.ped, true)
                                        SetEntityCoords(v.ped, v.houseX, v.houseY, v.houseZ - 1.0)
                                        SetEntityHeading(v.ped, v.houseH)
                                        waitingDone = true
                                    end
                                elseif waitingDone then
                                    if not Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 2.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "You didn't complete with your work")
                                        end
                                    elseif Paycheck then
                                        if (GetDistanceBetweenCoords(coords, coordsNPC.x, coordsNPC.y, coordsNPC.z, true) < 1.5) then
                                            DrawText3Ds(coordsNPC.x, coordsNPC.y, coordsNPC.z + 0.95, "It will work sonner, here's your payment")
                                            DrawText3Ds(coords.x, coords.y, coords.z + 1.0, '~g~[E]~s~ - Take the money')
                                            if IsControlJustReleased(0, Keys["E"]) then
                                                if not hasBackPack then
                                                    TaskTurnPedToFaceEntity(v.ped, ped, 0.2)
                                                    TriggerServerEvent('c3-vrtnar:Payout', salary, AmountPayout)
                                                    exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You Earned " ..salary.. "$!", timeout = 2500})
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    ESX.Streaming.RequestAnimDict('mp_common', function()
                                                        TaskPlayAnim(v.ped, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                                    end)
                                                    Citizen.Wait(3500)
                                                    ClearPedTasks(ped)
                                                    CancelWork()
                                                elseif hasBackPack then
                                                    exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>Return the backpack to the van", timeout = 2500})
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if CanWork then
                    for i, v in ipairs(Config.EastVinewoodWork) do
                        if not v.taked then
                            if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 8) then
                                sleep = 5
                                DrawMarker(Marker.Type, v.x, v.y, v.z - 0.90, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 100, false, true, 2, false, false, false, false)
                                if (GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.2) then
                                    sleep = 5
                                    DrawText3Ds(v.x, v.y, v.z + 0.4, "~g~[E]~s~ - Water the Flowers")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        if hasBackPack then
                                            ESX.Streaming.RequestAnimDict('missarmenian3_gardener', function()
                                                TaskPlayAnim(ped, 'missarmenian3_gardener', 'blower_idle_a', 8.0, -8.0, -1, 2, 0, false, false, false)
                                            end)
                                            exports.rprogress:Custom({
                                                Duration = 5500,
                                                Label = "Watering...",
                                                DisableControls = {
                                                    Mouse = false,
                                                    Player = true,
                                                    Vehicle = true
                                                }
                                            })
                                            Citizen.Wait(5500)
                                            ClearPedTasks(ped)
                                            v.taked = true
                                            RemoveBlip(v.blip)
                                            done = done + 1
                                            if done == #Config.EastVinewoodWork then
                                                Paycheck = true
                                                done = 0
                                                AmountPayout = AmountPayout + 1
                                                exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You did water everywhere, go get your paycheck", timeout = 2500})
                                            end
                                        elseif not hasBackPack then
                                            exports.pNotify:SendNotification({text = "<b>GARDENER</b></br>You don't have your backpack", timeout = 2500})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        Citizen.Wait(sleep)
    end)

function CreateWork(type)

    if type == "Rockford Hills" then
        for i, v in ipairs(Config.RockfordHills) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Gardener] Job Place')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "West Vinewood" then
        for i, v in ipairs(Config.WestVinewood) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Gardener] Job Place')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "Vinewood Hills" then
        for i, v in ipairs(Config.VinewoodHills) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Gardener] Job Place')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "El Burro Heights" then
        for i, v in ipairs(Config.ElBurroHeights) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Gardener] Job Place')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "Richman" then
        for i, v in ipairs(Config.Richman) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Gardener] Job Place')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "Mirror Park" then
        for i, v in ipairs(Config.MirrorPark) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Gardener] Job Place')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    elseif type == "East Vinewood" then
        for i, v in ipairs(Config.EastVinewood) do
            v.blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(v.blip, 205)
            SetBlipColour(v.blip, 43)
            SetBlipScale(v.blip, 0.5)
            SetBlipAsShortRange(v.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[Gardener] Job Place')
            EndTextCommandSetBlipName(v.blip)

            local ped_hash = GetHashKey(Config.NPC['Peds'][math.random(1,#Config.NPC['Peds'])].ped)
            RequestModel(ped_hash)
            while not HasModelLoaded(ped_hash) do
                Citizen.Wait(1)
            end
            v.ped = CreatePed(1, ped_hash, v.x, v.y, v.z-0.96, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(v.ped, true)
            SetPedDiesWhenInjured(v.ped, false)
            SetPedCanPlayAmbientAnims(v.ped, true)
            SetPedCanRagdollFromPlayerImpact(v.ped, false)
            SetEntityInvincible(v.ped, true)
            FreezeEntityPosition(v.ped, true)
        end
    end
    Type = type
end

function CancelWork()

    if Type == "Rockford Hills" then
        for i, v in ipairs(Config.RockfordHills) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.RockfordHillsWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "West Vinewood" then
        for i, v in ipairs(Config.WestVinewood) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.WestVinewoodWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "Vinewood Hills" then
        for i, v in ipairs(Config.VinewoodHills) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.VinewoodHillsWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "El Burro Heights" then
        for i, v in ipairs(Config.ElBurroHeights) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.ElBurroHeightsWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "Richman" then
        for i, v in ipairs(Config.Richman) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.RichmanWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "Mirror Park" then
        for i, v in ipairs(Config.MirrorPark) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.MirrorParkWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    elseif Type == "East Vinewood" then
        for i, v in ipairs(Config.EastVinewood) do
            RemoveBlip(v.blip)
            DeletePed(v.ped)
        end
        for i, v in ipairs(Config.EastVinewoodWork) do
            v.taked = false
            RemoveBlip(v.blip)
        end
    end
    Type = nil
    appointed = false
    wasTalked = false
    waitingDone = false
    CanWork = false
    Paycheck = false
    salary = nil
    AmountPayout = 0
    done = 0
end

function BlipsWorkingRH()
    for i, v in ipairs(Config.RockfordHillsWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Gardener] Weeds')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingWV()
    for i, v in ipairs(Config.WestVinewoodWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Gardener] Trees')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingVH()
    for i, v in ipairs(Config.VinewoodHillsWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Gardener] Leafs')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingEBH()
    for i, v in ipairs(Config.ElBurroHeightsWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Gardener] Grass')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingRM()
    for i, v in ipairs(Config.RichmanWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Gardener] Hadges')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingMP()
    for i, v in ipairs(Config.MirrorParkWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Gardener] Grass for Lawn')
        EndTextCommandSetBlipName(v.blip)
    end
end

function BlipsWorkingEV()
    for i, v in ipairs(Config.EastVinewoodWork) do
        v.blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(v.blip, 1)
        SetBlipColour(v.blip, 24)
        SetBlipScale(v.blip, 0.4)
        SetBlipAsShortRange(v.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('[Gardener] Watering')
        EndTextCommandSetBlipName(v.blip)
    end
end

function addBackPack()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    backpack = CreateObject(GetHashKey('prop_spray_backpack_01'), coords.x, coords.y, coords.z,  true,  true, true)
    AttachEntityToEntity(backpack, ped, GetPedBoneIndex(ped, 56604), 0.0, -0.12, 0.28, 0.0, 0.0, 180.0, true, true, false, true, 1, true)
end

function removeBackPack()
    local ped = PlayerPedId()

    DeleteEntity(backpack)
end

function addLawnMower()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    RequestAnimDict("anim@heists@box_carry@")
    while (not HasAnimDictLoaded("anim@heists@box_carry@")) do
        Citizen.Wait(7)
    end
    TaskPlayAnim(ped, "anim@heists@box_carry@" ,"idle", 5.0, -1, -1, 50, 0, false, false, false)
    lawnmower = CreateObject(GetHashKey('prop_lawnmower_01'), coords.x, coords.y, coords.z,  true,  true, true)
    AttachEntityToEntity(lawnmower, ped, GetPedBoneIndex(ped, 56604), -0.05, 1.0, -0.85, 0.0, 0.0, 180.0, true, true, false, true, 1, true)
end

function removeLawnMower()
    local ped = PlayerPedId()

    DeleteEntity(lawnmower)
end

function addTrimmer()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    trimmer = CreateObject(GetHashKey('prop_hedge_trimmer_01'), coords.x, coords.y, coords.z,  true,  true, true)
    AttachEntityToEntity(trimmer, ped, GetPedBoneIndex(ped, 57005), 0.09, 0.02, 0.01, -121.0, 181.0, 187.0, true, true, false, true, 1, true)
end

function removeTrimmer()
    local ped = PlayerPedId()

    DeleteEntity(trimmer)
end

function addLeafBlower()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    leafblower = CreateObject(GetHashKey('prop_leaf_blower_01'), coords.x, coords.y, coords.z,  true,  true, true)
    AttachEntityToEntity(leafblower, ped, GetPedBoneIndex(ped, 57005), 0.14, 0.02, 0.0, -40.0, -40.0, 0.0, true, true, false, true, 1, true)
end

function removeLeafBlower()
    local ped = PlayerPedId()

    DeleteEntity(leafblower)
end

-- RETURNING VEHICLE
function ReturnVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)

    ESX.Game.DeleteVehicle(vehicle)
end

-- MAIN BLIP
Citizen.CreateThread(function()
    baseBlip = AddBlipForCoord(Base.Pos.x, Base.Pos.y, Base.Pos.z)
    SetBlipSprite(baseBlip, Base.BlipSprite)
    SetBlipDisplay(baseBlip, 4)
    SetBlipScale(baseBlip, Base.BlipScale)
    SetBlipAsShortRange(baseBlip, true)
    SetBlipColour(baseBlip, Base.BlipColor)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Base.BlipLabel)
    EndTextCommandSetBlipName(baseBlip)
end)

-- ADDING GARAGES BLIPS
function addGarageBlip()
    garageBlip = AddBlipForCoord(Garage.Pos.x, Garage.Pos.y, Garage.Pos.z)
    SetBlipSprite(garageBlip, Garage.BlipSprite)
    SetBlipDisplay(garageBlip, 4)
    SetBlipScale(garageBlip, Garage.BlipScale)
    SetBlipAsShortRange(garageBlip, true)
    SetBlipColour(garageBlip, Garage.BlipColor)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Garage.BlipLabel)
    EndTextCommandSetBlipName(garageBlip)
end

-- REMOVING GARAGES BLIPS
function removeGarageBlip()
    RemoveBlip(garageBlip)
end

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function DrawText3DMenu(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.02+0.0125, -0.14+ factor, 0.08, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function DrawText3Dss(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.008+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end