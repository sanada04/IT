local SPAWN_EVENT = 'sparrow_fast:spawn'

RegisterCommand('sparrowfast', function(source)
    if source <= 0 then
        print('[sparrow_fast] This command is for in-game players only.')
        return
    end

    TriggerClientEvent(SPAWN_EVENT, source)
end, false)
