-- A probabilistic pantograph spark generator.
--
-- @include YoRyan/LibRailWorks/RailWorks.lua
local P = {}
PantoSpark = P

-- Create a new PantoSpark context.
function P:new(conf)
  local o = {
    _tick_s = conf.tick_s or 0.2,
    _getmeantimebetween_s = conf.getmeantimebetween_s or function(aspeed_mps)
      -- Calibrated for 22 mph = 30 s, with a rapid falloff thereafter.
      if aspeed_mps == 0 then
        return 60 * 60 * 24 * 365
      else
        return 300 / aspeed_mps
      end
    end,
    _lasttick_s = nil,
    _showspark = false
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- Query the current spark state.
function P:isspark()
  local now = RailWorks.GetSimulationTime()
  if self._lasttick_s == nil or now - self._lasttick_s > self._tick_s then
    local aspeed_mps = math.abs(RailWorks.GetSpeed())
    local meantime = self._getmeantimebetween_s(aspeed_mps)
    self._showspark = math.random() < self._tick_s / meantime
    self._lasttick_s = now
  end
  return self._showspark
end

return P
