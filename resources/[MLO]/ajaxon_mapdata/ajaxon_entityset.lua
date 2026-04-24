local interiors = {
    {
        ipl = 'ajaxon_burton_lscv2_milo_',
        coords = { x = -344.962, y = -122.361, z = 41.5921 },
        entitySets = {
        { name = 'office_01', enable = false }, -- office theme
        { name = 'office_02', enable = true },  -- arcade theme
        }
    }
}



CreateThread(function()
    for _, interior in ipairs(interiors) do
        if not interior.ipl or not interior.coords or not interior.entitySets then
            print('^5[AJAXON MLOs]^7 ^1Error while loading interior.^7')
            return
        end
        RequestIpl(interior.ipl)
        local interiorID = GetInteriorAtCoords(interior.coords.x, interior.coords.y, interior.coords.z)
        if IsValidInterior(interiorID) then
            for __, entitySet in ipairs(interior.entitySets) do
                if entitySet.enable then
                    EnableInteriorProp(interiorID, entitySet.name)
                    if entitySet.color then
                        SetInteriorPropColor(interiorID, entitySet.name, entitySet.color)
                    end
                else
                    DisableInteriorProp(interiorID, entitySet.name)
                end
            end
            RefreshInterior(interiorID)
        end
    end
    print("^5[AJAXON MLOs]^7 All interiors data loaded successfully.")
end)