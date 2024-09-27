local Groups = {}

RegisterNetEvent('trickortreat:createGroup')
AddEventHandler('trickortreat:createGroup', function()
    local leaderId = source
    print("Creating group for leader: " .. leaderId)
    if not Groups[leaderId] then
        Groups[leaderId] = { leader = leaderId, members = { leaderId } }
        TriggerClientEvent('client:notify', leaderId, "Group created!", "success")
        UpdateGroupForMembers(leaderId)
    else
        TriggerClientEvent('client:notify', leaderId, "You are already in a group.", "error")
    end
end)

RegisterNetEvent('trickortreat:invitePlayer')
AddEventHandler('trickortreat:invitePlayer', function(inviteeId)
    local leaderId = source
    print("Leader " .. leaderId .. " is inviting player " .. inviteeId)
    if Groups[leaderId] then
        table.insert(Groups[leaderId].members, inviteeId)
        TriggerClientEvent('client:notify', inviteeId, "You were invited to a Trick or Treat group!", "inform")
        UpdateGroupForMembers(leaderId)
    else
        TriggerClientEvent('client:notify', leaderId, "You need to create a group first.", "error")
    end
end)

RegisterNetEvent('trickortreat:disbandGroup')
AddEventHandler('trickortreat:disbandGroup', function()
    local leaderId = source
    print("Disbanding group for leader: " .. leaderId)
    if Groups[leaderId] then
        for _, memberId in ipairs(Groups[leaderId].members) do
            TriggerClientEvent('trickortreat:groupDisbanded', memberId)
        end
        Groups[leaderId] = nil
    else
        TriggerClientEvent('client:notify', leaderId, "No group found.", "error")
    end
end)

RegisterNetEvent('trickortreat:knockDoor')
AddEventHandler('trickortreat:knockDoor', function(playerId, doorLocation)
    local loot = GetLoot()
    local playerGroup = GetPlayerGroup(playerId)
    if playerGroup then
        for _, memberId in ipairs(playerGroup.members) do
            if IsPlayerInRange(memberId, doorLocation, Config.GroupRadius) then
                GivePlayerItem(memberId, loot.item, math.floor(loot.amount / #playerGroup.members))
            end
        end
    else
        GivePlayerItem(playerId, loot.item, loot.amount)
    end
end)

RegisterNetEvent('trickortreat:getGroupMembers')
AddEventHandler('trickortreat:getGroupMembers', function()
    local leaderId = source
    if Groups[leaderId] then
        TriggerClientEvent('trickortreat:showGroupMembers', leaderId, Groups[leaderId].members)
    else
        TriggerClientEvent('client:notify', leaderId, "You are not in a group.", "error")
    end
end)

RegisterNetEvent('trickortreat:kickMember')
AddEventHandler('trickortreat:kickMember', function(memberId)
    local leaderId = source
    if Groups[leaderId] then
        for i, member in ipairs(Groups[leaderId].members) do
            if member == memberId then
                table.remove(Groups[leaderId].members, i)
                TriggerClientEvent('client:notify', memberId, "You were kicked from the group.", "error")
                TriggerClientEvent('trickortreat:groupDisbanded', memberId)
                break
            end
        end
        UpdateGroupForMembers(leaderId)
    else
        TriggerClientEvent('client:notify', leaderId, "You are not in a group.", "error")
    end
end)

RegisterNetEvent('trickortreat:spawnNPCAndLoot')
AddEventHandler('trickortreat:spawnNPCAndLoot', function(doorLocation)
    local playerId = source
    local loot = GetLoot()
    local npcModel = 's_m_m_autoshop_02'

    TriggerClientEvent('trickortreat:spawnNPCAndLootClient', playerId, npcModel, doorLocation, 180.0) -- Pass the NPC model, location, and heading

    local playerGroup = GetPlayerGroup(playerId)
    if playerGroup then
        for _, memberId in ipairs(playerGroup.members) do
            if IsPlayerInRange(memberId, doorLocation, Config.GroupRadius) then
                GivePlayerItem(memberId, loot.item, math.floor(loot.amount / #playerGroup.members))
            end
        end
    else
        GivePlayerItem(playerId, loot.item, loot.amount)
    end
end)

function GetLoot()
    for _, loot in ipairs(Config.LootPool) do
        if math.random(0, 100) <= loot.chance then
            local amount = math.random(loot.min or 1, loot.max or 1)
            return { item = loot.item, amount = amount }
        end
    end
    return { item = "nothing", amount = 0 }
end

function IsPlayerInRange(playerId, doorLocation, radius)
    local playerPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    return #(playerCoords - doorLocation) <= radius
end

function GetPlayerGroup(playerId)
    for _, group in pairs(Groups) do
        for _, member in ipairs(group.members) do
            if member == playerId then
                return group
            end
        end
    end
    return nil
end

function UpdateGroupForMembers(leaderId)
    local group = Groups[leaderId]
    if group then
        for _, memberId in ipairs(group.members) do
            print("Updating group for member: " .. memberId)
            TriggerClientEvent('trickortreat:updateGroup', memberId, group.members)
        end
    end
end

function GivePlayerItem(playerId, item, amount)
    if item == "nothing" then
        TriggerClientEvent('client:notify', playerId, "You received nothing!", "error")
    else
        local itemData = exports.ox_inventory:Items()[item]

        if itemData then
            local itemLabel = itemData.label or item
            exports.ox_inventory:AddItem(playerId, item, amount)
            TriggerClientEvent('client:notify', playerId, "You received " .. amount .. "x " .. itemLabel, "success")
            local xpProgress = AddXP(amount)
            TriggerClientEvent('client:notify', playerId, "XP Progress: " .. math.floor(xpProgress) .. "%", "info")
        else
            TriggerClientEvent('client:notify', playerId, "Item not found in inventory!", "error")
        end
    end
end


