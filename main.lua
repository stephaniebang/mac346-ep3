
local Vec = require './common/vec'
local Ent = require './common/entity'

local function isValidPath(path)
  local f = io.open(path, "r")

  if f then
    io.close(f)

    return true
  else
    return false
  end
end

function love.load(args)
  math.randomseed(os.time())

  -- Read scene
  local path = 'scene/' .. args[1] .. '.lua'

  if not isValidPath(path) then
    print('Invalid scene file path')
    love.event.quit()

    return
  end

  local chunk = love.filesystem.load(path)
  local scene = chunk()

  -- Read entities
  Entities = {}

  for i=1, #scene do
    local propsChunk = love.filesystem.load('entity/' .. scene[i].entity .. '.lua')
    local props = propsChunk()

    Entities[i] = Ent(scene[i].entity, scene[i].n, props)
  end
end

function love.draw()
  -- Window settings
  love.graphics.scale(0.3, 0.3)
  local w, h = love.graphics.getDimensions()
  love.graphics.translate(w/0.6, h/0.6)

  -- DELETAR !!!!!!
  love.graphics.setFont(love.graphics.newFont(40))

  -- Draw border circle
  love.graphics.setColor(1, 1, 1)
  love.graphics.circle('line', 0, 0, 1000)

  -- Draw entities
  for i=1, #Entities do
    for j=1, Entities[i].n do
      -- Set entity color
      if Entities[i].control then
        love.graphics.setColor(1, 1, 1)
      elseif Entities[i].field then
        if Entities[i].field.strength < 0 then love.graphics.setColor(.9, .3, .3)
        elseif Entities[i].field.strength > 0 then love.graphics.setColor(.3, .3, .9) end
      else
        love.graphics.setColor(.3, .9, .3)
      end

      -- Draw entity
      local x, y = Entities[i].positions[j].point:get()

      if Entities[i].body then
        love.graphics.circle('fill', x, y, Entities[i].body.size)
      elseif Entities[i].control then
        love.graphics.polygon('fill', x, y - 20, x - 20, y + 20, x + 20, y + 20)
      elseif not Entities[i].field then
        love.graphics.circle('line', x, y, 8)
      end

      -- Draw field
      if Entities[i].field then
        if Entities[i].field.strength < 0 then love.graphics.setColor(1, 0, 0)
        elseif Entities[i].field.strength > 0 then love.graphics.setColor(0, 0, 1)
        else love.graphics.setColor(0, 1, 0) end

        love.graphics.circle('line', x, y, math.abs(Entities[i].field.strength))
      end

      -- Draw charge
      if Entities[i].charge then
        if Entities[i].charge.strength < 0 then love.graphics.setColor(1, 0, 0)
        elseif Entities[i].charge.strength > 0 then love.graphics.setColor(0, 0, 1)
        else love.graphics.setColor(0, 1, 0) end

        local x1, y1, x2, y2 = Entities[i]:chargesPosition(j)

        love.graphics.circle('line', x1, y1, 4)
        love.graphics.circle('line', x2, y2, 4)
      end

      -- DELETAR !!!!!!
      love.graphics.setColor(1, 1, 1)
      love.graphics.print(Entities[i].name, x, y + 10)
    end
  end
end

function love.keyreleased(key)
  Released = true

  if key == 'down' then Stop = Vec(0, 1)
  elseif key == 'up' then Stop = Vec(0, -1)
  elseif key == 'left' then Stop = Vec(-1, 0)
  elseif key == 'right' then Stop = Vec(1, 0)
  else Released = false end
end

function love.update(dt)
  for i=1, #Entities do
    -- Check input
    if Entities[i].name == 'player' then
      local direction = Vec(0, 0)

      if love.keyboard.isDown('down') then direction = direction + Vec(0, 1)
      elseif love.keyboard.isDown('up') then direction = direction + Vec(0, -1) end

      if love.keyboard.isDown('left') then direction = direction + Vec(-1, 0)
      elseif love.keyboard.isDown('right') then direction = direction + Vec(1, 0) end

      if Stop then
        local dirX, dirY = direction:get()
        local stpX, stpY = Stop:get()

        if stpY*dirY < 0 then direction = Vec(dirX, 0)
        elseif stpX*dirX < 0 then direction = Vec(0, dirY) end
      end

      if direction:length() > 0 or Released then
        Entities[i]:updatePlayer(direction, dt, Released)
        Key = nil
      end
    end

    -- Update charges
    for j=1, Entities[i].n do
      if Entities[i].charge then
        local freq = math.sqrt(math.abs(Entities[i].charge.strength))
        Entities[i]:updateCharge(j, freq*dt)
        if Released then Released = false end
      end
    end
  end
end
