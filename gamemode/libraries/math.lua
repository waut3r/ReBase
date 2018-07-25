function math.GetMinMax(tbl)
    if (not table.IsSequential(tbl)) then
        local copy = {}
        for k, v in pairs(tbl) do
            table.insert(copy, v)
        end
        tbl = copy
    end
    table.sort(tbl)
    return tbl[1], tbl[#tbl]
end
