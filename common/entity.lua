
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

    if props.charge then positions[i].charge = Vec(-1, 0) end
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
    position = position:normalized()
    position = position*(-1000)

    local x, y = position:get()

    x = x > 0 and 20 or -20
    y = y > 0 and 30 or -30

    position = position - Vec(x, y)
  end

  self.positions[1].point = position

  return self.positions[1].point
end

function Ent:updateCharge(index, perc)
  local charge = self.positions[index].charge
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

function Ent.updateChargesAcceleration(ents, index, posIndex, dt)
  local chargeStr = ents[index].charge.strength
  local chargePos = ents[index].positions[posIndex].point
  local sum = Vec(0, 0)

  for i=1, #ents do
    if ents[i].field then
      for j=1, ents[i].n do
        if index ~= i or j ~= posIndex then
          local fieldPos = ents[i].positions[j].point
          local diff = chargePos - fieldPos
          local normalized = diff:normalized()
          local div = normalized:length() > 0 and normalized:length() or 1
          local partial = (normalized/div)*ents[i].field.strength
          sum = sum + partial
        end
      end
    end
  end

  local force = sum*(100*chargeStr)
  local mass = ents[index].body and ents[index].body.size or 1
  local acceleration = force/mass
  local speed = acceleration*dt
  chargePos = chargePos + speed*dt

  -- Check boundary
  if chargePos:length() >= 1000 - mass/2 then
    chargePos = chargePos:normalized()
    chargePos = chargePos*(-1000)

    local x, y = chargePos:get()
    local size = ents[index].body and ents[index].body.size or 8

    x = x > 0 and size or -size
    y = y > 0 and size or -size

    chargePos = chargePos - Vec(x, y)
  end

  ents[index].positions[posIndex].point = chargePos
end

return Ent
