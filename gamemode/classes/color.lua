local LUM_RED = 0.216
local LUM_GREEN = 0.07152
local LUM_BLUE = 0.0722

Color = {}
Color.__type = "Color"
Color.__index = Color

--
-- Description: Creates color instance
-- Arguments:
--      varargs: ... -  Can be a string representing #RGB/#RGBA/#RRGGBB/#RRGGBBAA format,
--                      a table with rgba keys, or RGBA arguments.
-- Returns:
--      Color: color
--
function Color:New(...)
    local color = {
        r = 255,
        g = 255,
        b = 255,
        a = 255,
        _cache = {}
    }

    local arg = {...}

    local function instance()
        setmetatable(color, Color)
        return color
    end

    if (#arg == 0) then
        return instance()
    end

    if (#arg == 1) then
        arg = arg[1]

        if (type(arg) == "string" and string.sub(arg, 1, 1) == "#") then
            local hex = string.sub(arg, 2, string.len(arg))
            assert(
                string.len(hex) == 3 or string.len(hex) == 6 or string.len(hex) == 8,
                "expected color format #RGB, #RRGGBB, or #RRGGBBAA"
            )
            if (string.len(hex) == 3) then
                color.r = tonumber("0x"..string.rep(string.sub(hex, 1, 1), 2))
                color.g = tonumber("0x"..string.rep(string.sub(hex, 2, 2), 2))
                color.b = tonumber("0x"..string.rep(string.sub(hex, 3, 3), 2))
            else
                color.r = tonumber("0x"..string.sub(hex, 1, 2), 16)
                color.g = tonumber("0x"..string.sub(hex, 3, 4), 16)
                color.b = tonumber("0x"..string.sub(hex, 5, 6), 16)
                if (string.len(hex) == 8) then
                    color.a = tonumber("0x"..string.sub(hex, 7, 8), 16)
                end
            end
            return instance()
        end

        if (type(arg) == "table" and arg.r and arg.g and arg.b) then
            assert(
                type(arg.r) == "number",
                "red channel contains non-number value"
            )
            assert(
                type(arg.g) == "number",
                "blue channel contains non-number value"
            )
            assert(
                type(arg.b) == "number",
                "green channel contains non-number value"
            )
            if (arg.a) then
                assert(
                    type(arg.a) == "number",
                    "alpha channel contains non-number value"
                )
            end
            color.r = arg.r
            color.g = arg.g
            color.b = arg.b
            color.a = arg.a or 255
            return instance()
        end

        error("expected hex color string or rgba table, got "..type(arg[1]))
    end

    if (#arg == 3 or #arg == 4) then
        arg = {r = arg[1], b = arg[2], g = arg[3], a = arg[4]}
        assert(
            type(arg.r) == "number",
            "red channel contains non-number value"
        )
        assert(
            type(arg.g) == "number",
            "blue channel contains non-number value"
        )
        assert(
            type(arg.b) == "number",
            "green channel contains non-number value"
        )
        if (arg.a) then
            assert(
                type(arg.a) == "number",
                "alpha channel contains non-number value"
            )
        end
        color.r = arg.r
        color.g = arg.b
        color.b = arg.g
        color.a = arg.a or 255
        return instance()
    end

    error("Color received an invalid number of arguments "..#arg);
end

setmetatable(Color, { __call = Color.New })

function Color:__tostring()
    return self.r.." "..self.g.." "..self.b.." "..self.a
end

function Color.__add(left, right)
    return Color(
        math.Clamp(left.r + right.r, 0, 255),
        math.Clamp(left.g + right.g, 0, 255),
        math.Clamp(left.b + right.b, 0, 255)
    )
end

function Color.__sub(left, right)
    return Color(
        math.Clamp(left.r - right.r, 0, 255),
        math.Clamp(left.g - right.g, 0, 255),
        math.Clamp(left.b - right.b, 0, 255)
    )
end

function Color.__mul(left, right)
    return Color(
        math.Clamp(left.r * right.r, 0, 255),
        math.Clamp(left.g * right.g, 0, 255),
        math.Clamp(left.b * right.b, 0, 255)
    )
end

function Color.__div(left, right)
    return Color(
        math.Clamp(left.r / right.r, 0, 255),
        math.Clamp(left.g / right.g, 0, 255),
        math.Clamp(left.b / right.b, 0, 255)
    )
end

--
-- Description: Calculates, caches, and returns RGB values scaled from 0-1
-- Returns:
--      table: scaled rgb table
--
function Color:GetScales()
    if (not self._cache) then
        self._cache = {}
    end
    self._cache.scales = {}
    self._cache.scales.r = self.r / 255
    self._cache.scales.g = self.g / 255
    self._cache.scales.b = self.b / 255
    return self._cache.scales
end

--
-- Description: Finds and caches smallest and largest scaled value among rgb components
-- Returns:
--      numbers: scaled min and max
--
function Color:GetMinMax()
    if (not self._cache or not self._cache.scales) then
        self:GetScales()
    end

    self._cache.min, self._cache.max = math.GetMinMax(self._cache.scales)
    return self._cache.min, self._cache.max
end

--
-- Description: Calculates and caches chroma (max - min)
-- Returns:
--      number: scaled chroma
--
function Color:GetChroma()
    if (not self._cache or not self._cache.min or not self._cache.max) then
        self:GetMinMax()
    end
    self._cache.chroma = self._cache.max - self._cache.min
    return self._cache.chroma
end

--
-- Description: Calculates and caches hue
-- Returns:
--      number: hue in degrees
--
function Color:GetHue()
    if (not self._cache or not self._cache.max) then
        self:GetMinMax()
    end

    if (not self._cache or not self._cache.chroma) then
        self:GetChroma()
    end

    if (self._cache.chroma == 0) then
        return nil
    end

    local r, g, b = self._cache.scales.r, self._cache.scales.g, self._cache.scales.b
    local c = self._cache.chroma

    if (self._cache.max == r) then
        self._cache.hue = (((g - b) / c) % 6) * 60
    end
    if (self._cache.max == g) then
        self._cache.hue = (((b - r) / c) + 2) * 60
    end
    if (self._cache.max == b) then
        self._cache.hue = (((r - g) / c) + 4) * 60
    end

    return self._cache.hue
end

--
-- Descrption: Calculates and caches saturation
-- Returns:
--      number: scaled saturation
--
function Color:GetSaturation()
    if (not self._cache or not self._cache.chroma) then
        self:GetChroma()
    end
    if (not self._cache or not self._cache.lightness) then
        self:GetLightness()
    end

    local c = self._cache.chroma
    local l = self._cache.lightness

    if (chroma == 0) then
        self._cache.saturation = 0
    else
        self._cache.saturation = c / (1 - math.abs(2 * l - 1))
    end

    return self._cache.saturation
end

--
-- Descrption: Calculates and caches lightness
-- Returns:
--      number: scaled lightness
--
function Color:GetLightness()
    if (not self._cache or not self._cache.max or not self._cache.min) then
        self:GetMinMax()
    end
    self._cache.lightness = (self._cache.max + self._cache.min) / 2
    return self._cache.lightness
end

--
-- Descrption: Calculates and caches approximate luminance
-- Returns:
--      number: scaled luminance
--
function Color:GetLuminance()
    if (not self._cache or not self._cache.scales) then
        self:GetScales()
    end

    local scales = self._cache.scales
    self._cache.luminance = scales.r * LUM_RED + scales.g * LUM_GREEN + scales.b
        * LUM_BLUE
    return self._cache.luminance
end

--
-- Descrption: Modifies RGB components to match HSL
-- Arguments:
--      number: hue (does not need to be within 0-360 degree range)
--      number: saturation (scaled from 0-1)
--      number: lightness (scaled from 0-1)
function Color:SetHsl(hue, saturation, lightness)
    while (hue > 360) do
        hue = hue - 360
    end

    while (hue < 0) do
        hue = hue + 360
    end

    local chroma  = (1 - math.abs(2 * lightness - 1)) * saturation
    local x = chroma * (1 - math.abs((hue / 60) % 2 - 1))
    local r, g, b

    if (hue >= 0 and hue <= 60) then
        r = chroma
        g = x
        b = 0
    elseif (hue > 60 and hue <= 120) then
        r = chroma
        g = x
        b = 0
    elseif (hue > 120 and hue <= 180) then
        r = 0
        g = chroma
        b = x
    elseif (hue > 180 and hue <= 240) then
        r = 0
        g = x
        b = c
    elseif (hue > 240 and hue <= 300) then
        r = x
        g = 0
        b = chroma
    elseif (hue > 300 and hue <= 360) then
        r = chroma
        g = 0
        b = x
    end

    local m = lightness - (.5 * chroma)
    self.r = (r + m) * 255
    self.g = (g + m) * 255
    self.b = (b + m) * 255

    self:ClearCache()

    self._cache.hue         = hue
    self._cache.saturation  = saturation
    self._cache.lightness   = lightness
end

--
-- Descrption: Modifies RGB components to match hue and caches resulting hue
-- Arguments:
--      number: hue (does not need to be within 0-360 degree range)
--
function Color:SetHue(hue)
    if (not self._cache or not self._cache.saturation) then
        self:GetSaturation()
    end
    if (not self._cache or not self._cache.lightness) then
        self:GetLightness()
    end
    self:SetHsl(hue, self._cache.saturation, self._cache.lightness)
end

--
-- Descrption: Modifies RGB components to match saturation and caches resulting saturation
-- Arguments:
--      number: scaled saturation
--
function Color:SetSaturation(saturation)
    if (not self._cache or not self._cache.hue) then
        self:GetHue()
    end
    if (not self._cache or not self._cache.lightness) then
        self:GetLightness()
    end
    self:SetHsl(self._cache.hue, saturation, self._cache.lightness)
end

--
-- Descrption: Modifies RGB components to match lightness and caches resulting lightness
-- Arguments:
--      number: scaled lightness
--
function Color:SetLightness(lightness)
    if (not self._cache.saturation) then
        self:GetSaturation()
    end
    if (not self._cache.lightness) then
        self:GetLightness()
    end
    self:SetHsl(self._cache.hue, self._cache.saturation, lightness)
end

--
-- Descrption: Modifies RGB components to match added hue and caches resulting hue
-- Arguments:
--      number: hue (does not need to be within 0-360 degree range)
--
function Color:RotateHue(hue)
    if (not self._cache.hue) then
        self:GetHue()
    end
    self:SetHue(self._cache.hue + hue)
end

--
-- Descrption: Prints color information to console
--
function Color:PrintColorInformation()
    debug.Print("Color information")
    MsgC(Color(255, 255, 255), debug.Timestamp())
    MsgC(self, "██: "..tostring(self).."\n")
    debug.Print("Red Channel  ", self.r)
    debug.Print("Green Channel", self.g)
    debug.Print("Blue Channel ", self.b)

    local scales = self:GetScales()
    debug.Print("Red scale    ", scales.r)
    debug.Print("Green scale  ", scales.g)
    debug.Print("Blue scale   ", scales.b)

    local min, max = self:GetMinMax(scales)
    debug.Print("Minimum      ", min)
    debug.Print("Maximum      ", max)

    local chroma = self:GetChroma()
    debug.Print("Chroma       ", chroma)
    
    local hue = self:GetHue()
    debug.Print("Hue          ", hue)

    local saturation = self:GetSaturation()
    debug.Print("Saturation   ", saturation)

    local lightness = self._cache.lightness
    debug.Print("Lightness    ", lightness)

    local luminance = self:GetLuminance()
    debug.Print("Luminance    ", luminance)
end

--
-- Descrption: Sets _cache table to empty table
--
function Color:ClearCache()
    self._cache = {}
end
