
local Ent = require 'class' ()
local Vec = require './common/vec'

local function randomPosition(props)
  local x, y
  local radius = props.body and props.body.size or 8

  repeat
    x, y = math.random(-1000, 1000), math.random(-1000, 1000)
  until math.sqrt(x*x + y*y) + radius <= 1000
  
  return Vec(x, y)
end

local function getPositions(n, props)
  local positions = {}

  for i=1,n do
    positions[i] = { point = props.position.point or randomPosition(props) }

    if props.charge then
      positions[i].charge = Vec(-1, 0)
    end
  end

  return positions
end

function Ent:_init(name, n, props)
  self.name = name or ''
  self.n = n or 0
  self.positions = getPositions(n, props)
  if props.movement then self.movement = props.movement end
  if props.body then self.body = props.body end
  if props.field then self.field = props.field end
  if props.charge then self.charge = props.charge end
  if props.control then
    self.control = props.control
    self.control.speed = Vec(0, 0)
  end
end

function Ent:updatePlayer(direction, dt, released)
  local player = self.positions[1].point
  local speed = self.control.speed
  local max = self.control.max_speed

  -- Update speed
  local spdX, spdY = speed:get()
  local dirX, dirY = direction:get()

  if dirY*spdY < 0 or (released and dirY == 0) then spdY = 0
  elseif dirX*spdX < 0 or (released and dirX == 0) then spdX = 0 end 

  speed = Vec(spdX, spdY)
  speed = speed + direction*(self.control.acceleration*dt)
  speed:clamp(max)

  self.control.speed = speed

  -- Update position
  self.positions[1].point = player + speed*dt
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

return Ent
