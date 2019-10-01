
local Ent = require 'class' ()
local Vec = require './common/vec'

local mainColor = {
  red = { r = .8, g = .161, b = .255 },
  green = { r = .012, g = .9, b = .43 },
  blue = { r = .02, g = .41, b = .729 },
  white = { r = 1, g = 1, b = 1 }
}

local secondaryColor = {
  red = { r = 1, g = .4, b = .4 },
  green = { r = .1, g = 1, b = .5 },
  blue = { r = .2, g = .6, b = 1 }
}

local function randomPosition(props)
  local x, y
  local radius = props.body and props.body.size or 8

  repeat
    x, y = math.random(-1000, 1000), math.random(-1000, 1000)
  until math.sqrt(x*x + y*y) + radius <= 1000
  
  return Vec(x, y)
end

local function setPositions(n, props)
  local positions = {}

  for i=1,n do
    positions[i] = { point = props.position.point or randomPosition(props) }

    if props.charge then
      positions[i].charge = Vec(-1, 0)
    end
  end

  return positions
end

local function strengthColor(strength)
  if strength < 0 then return secondaryColor.red
  elseif strength > 0 then return secondaryColor.blue end
  return secondaryColor.green
end

local function setPropWithColor(prop)
  return { strength = prop.strength, color = strengthColor(prop.strength) }
end

local function setColor(props)
  local color

  if not props.body and props.charge then return strengthColor(props.charge.strength) end

  if props.control then color = mainColor.white
  elseif props.field then
    if props.field.strength < 0 then color = mainColor.red
    elseif props.field.strength > 0 then color = mainColor.blue end
  else color = mainColor.green end

  return color
end

function Ent:_init(name, n, props)
  -- save props
  self.name = name
  self.n = n or 1
  self.positions = setPositions(n, props)
  self.color = setColor(props)
  self.speed = Vec(0, 0)
  if props.movement then self.movement = props.movement end
  if props.body then self.body = props.body end
  if props.field then self.field = setPropWithColor(props.field) end
  if props.charge then self.charge = setPropWithColor(props.charge) end
  if props.control then self.control = props.control end
end

function Ent:getMainColor()
  return self.color.r, self.color.g, self.color.b
end

function Ent:getSecondaryColor(name)
  return self[name].color.r, self[name].color.g, self[name].color.b
end

function Ent:updatePlayer(direction, dt)
  local player = self.positions[1].point
  local speed = self.speed
  local max = self.control.max_speed

  -- Update speed
  speed = speed + direction*(self.control.acceleration*dt)
  speed:clamp(max)

  self.speed = speed

  -- Update position
  local position = player + speed*dt

  -- Check boundary
  if position:length() >= 985 then
    position = position*(-1)

    local x, y = position:get()

    x = x > 0 and 6 or -6
    y = y > 0 and 9 or -9

    position = position - Vec(x, y)
  end

  self.positions[1].point = position

  return self.positions[1].point
end

function Ent:updateCharge(index, perc)
  local charge = self.positions[index].charge
  local center = self.positions[index].point
  local oldRad = charge:getAngle()
  local newRad = perc*2*math.pi + oldRad

  self.positions[index].charge = Vec.fromAngle(newRad)
end

function Ent:chargesPosition(index)
  local charge = self.positions[index].charge
  local center = self.positions[index].point
  local rad = charge:getAngle()
  local charge1 = charge*8 + center
  local charge2 = Vec.fromAngle(math.pi + rad)*8 + center
  local x1, y1 = charge1:get()
  local x2, y2 = charge2:get()

  return x1, y1, x2, y2
end

-- function Ent:updateChargesAcceleration(ents, index)
--   for i=1, #ents do
--     if ents[i].field
--   end
-- end

return Ent
