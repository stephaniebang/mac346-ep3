
local Vec = require 'class' ()

local function round(num, decimalPlaces)
  local mult = 10^(decimalPlaces or 0)
  return math.floor(num*mult + 0.5)/mult
end

function Vec:_init(x, y)
  self.x = x or 0
  self.y = y or 0
end

function Vec:clone()
  return Vec(self.x, self.y)
end

function Vec:__tostring()
  return "(" .. self.x .. ", " .. self.y .. ")"
end

function Vec:set(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function Vec:get()
  return self.x, self.y
end

function Vec.fromAngle(rads)
  return Vec(round(math.cos(rads), 2), round(math.sin(rads), 2))
end

function Vec:getAngle()
  return math.atan2(self.y, self.x)
end

function Vec:__add(other)
  return Vec(self.x + other.x, self.y + other.y)
end

function Vec:__sub(other)
  return Vec(self.x - other.x, self.y - other.y)
end

function Vec:__unm()
  return Vec(-self.x, -self.y)
end

function Vec:__mul(other)
  if type(other) == 'number' then
    return Vec(self.x * other, self.y * other)
  else
    return Vec(self.x * other.x, self.y * other.y)
  end
end

function Vec:__div(other)
  if type(other) == 'number' then
    return Vec(self.x / other, self.y / other)
  else
    return Vec(self.x / other.x, self.y / other.y)
  end
end

function Vec:dot(other)
  return self.x * other.x + self.y * other.y
end

function Vec:add(other)
  self.x = self.x + other.x
  self.y = self.y + other.y
end

function Vec:clamp(max)
  local length = self:length()
  if length >= max then
    self.x = self.x / length * max
    self.y = self.y / length * max
  end
end

function Vec:length()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vec:normalized()
  local length = self:length()
  if length >= 0.1 then
    return self / length
  else
    return Vec()
  end
end

return Vec
