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

function debug.Timestamp()
    local format = GetConVar("debug_timestamp_format"):GetString()
    local time   = os.date(format, os.time())
    return "["..time.."]: "
end

function debug.Print(...)
    MsgC(Color(255, 255, 255), debug.Timestamp())
    print(...)
end
