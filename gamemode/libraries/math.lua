--
-- Description: Takes a table and returns the lowest and highest value
-- Arguments:
--      table: tbl (does not need to be sequential)
-- Returns:
--      numbers: Lowest value, then highest value

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
