CreateConVar(
    "debug_timestamp_format",
    "%y/%m/%d %H:%M:%S",
    FCVAR_ARCHIVE,
    [[Controls formatting of timestamps for Lua code that uses debug.Timestamp 
    and debug.Print]]
)

cvars.AddChangeCallback("debug_timestamp_format", function(name, oldValue, newValue)
    debug.Print("Your timestamp settings have been changed")
end)

--
-- Description: Using the format from the debug_timestamp_format ConVar, returns a
--              timestamp prefix to be used by debug.Print
-- Returns:
--      string: timestamp
--
function debug.Timestamp()
    local format = GetConVar("debug_timestamp_format"):GetString()
    local time   = os.date(format, os.time())
    return "["..time.."]: "
end

--
-- Description: Prints values prefixed by timestamp
-- Arguments:
--      vararg: ... (the values to be printed)
function debug.Print(...)
    MsgC(Color(255, 255, 255), debug.Timestamp())
    print(...)
end
