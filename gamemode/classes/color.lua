local LUM_RED = 0.216
local LUM_GREEN = 0.07152
local LUM_BLUE = 0.0722

Color = {}
Color.__type = "Color"
Color.__index = Color

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

function Color:GetScales()
    self._cache.scales = {}
    self._cache.scales.r = self.r / 255
    self._cache.scales.g = self.g / 255
    self._cache.scales.b = self.b / 255
    return self._cache.scales
end

function Color:GetMinMax()
    if (not self._cache.scales) then
        Color:GetScales()
    end

    self._cache.min, self._cache.max = math.GetMinMax(self._cache.scales)
    return self._cache.min, self._cache.max
end

function Color:GetChroma()
    if (not self._cache.min or not self._cache.max) then
        self:GetMinMax()
    end
    self._cache.chroma = self._cache.max - self._cache.min
    return self._cache.chroma
end

function Color:GetHue()
    if (not self._cache.max) then
        self:GetMinMax()
    end

    if (not self._cache.chroma) then
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

function Color:GetSaturation()
    if (not self._cache.chroma) then
        self:GetChroma()
    end
    if (not self._cache.lightness) then
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

function Color:GetLightness()
    if (not self._cache.max or not self._cache.min) then
        self:GetMinMax()
    end
    self._cache.lightness = (self._cache.max + self._cache.min) / 2
    return self._cache.lightness
end

function Color:GetColorInformation()
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
end

function Color:ClearCache()
    self._cache = {}
end
