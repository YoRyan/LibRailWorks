--- A class that makes it easy to turn light cones partially on/off.
-- @include YoRyan/LibRailWorks/Misc.lua
-- @include YoRyan/LibRailWorks/RailWorks.lua
local P = {}
FadeableLight = P

local function setrgb(self)
  local r, g, b = Call(self._light .. ":GetColour")
  self._rgb = {r, g, b}
end

--- Create a new FadeableLight context.
-- @param light the name of the light
-- @param fade_s time it takes to turn the light on or off
-- @return the context
function P:new(conf)
  local o = {
    _light = conf.light,
    _fade_s = conf.fade_s or 0.5,
    _rgb = {1, 1, 1},
    _target = 0,
    _intensity = 0
  }
  setmetatable(o, self)
  self.__index = self
  setrgb(o)
  return o
end

--- Update this instance once every frame.
-- @param dt time since last update
function P:update(dt)
  if not Misc.isinitialized() then
    self._intensity = self._target
  elseif self._target > self._intensity then
    self._intensity =
      math.min(self._target, self._intensity + dt / self._fade_s)
  elseif self._target < self._intensity then
    self._intensity =
      math.max(self._target, self._intensity - dt / self._fade_s)
  end

  if self._intensity > 0 then
    local r = self._intensity * self._rgb[1]
    local g = self._intensity * self._rgb[2]
    local b = self._intensity * self._rgb[3]
    Call(self._light .. ":SetColour", r, g, b)
    Call(self._light .. ":Activate", 1)
  else
    Call(self._light .. ":Activate", 0)
  end
end

--- Set this light's target intensity.
-- @param intensity the intensity, from 0 to 1
function P:setintensity(intensity) self._target = intensity end

--- Set this light's target intensity as a binary value.
-- @param state the boolean value to use
function P:setonoff(state) self._target = Misc.intbool(state) end

--- Determine whether the light has any power at all.
-- @return the state of the light
function P:ison() return self._intensity > 0 end

return P
