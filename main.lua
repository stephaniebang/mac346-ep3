
-- local Vec = require 'common/vec'

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
  local index = 1

  -- Read entities
  Entities = {}

  for i=1, #scene do
    local entityChunk = love.filesystem.load('entity/' .. scene[i].entity .. '.lua')
    local entity = entityChunk()

    if entity.position then
      for j=1, scene[i].n do
        Entities[index] = {
          name = scene[i].entity,
          props = entityChunk()
        }

        local x, y = 0, 0

        repeat
          x, y = math.random(-1000, 1000), math.random(-1000, 1000)
        until math.sqrt(x*x + y*y) <= 1000
        Entities[index].props.position = { x = x, y = y }

        index = index + 1
      end
    end
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
  love.graphics.setColor(0, 1, 0)

  for i=1, #Entities do
    local x = Entities[i].props.position.x
    local y = Entities[i].props.position.y
    local props = Entities[i].props

    -- Set entity color
    if props.control then
      love.graphics.setColor(1, 1, 1)
    elseif props.field then
      if props.field.strength < 0 then love.graphics.setColor(1, 0, 0)
      elseif props.field.strength > 0 then love.graphics.setColor(0, 0, 1) end
    else
      love.graphics.setColor(0, 1, 0)
    end

    -- Draw entity
    if props.body then
      love.graphics.circle('fill', x, y, Entities[i].props.body.size)
    elseif props.control then
      love.graphics.polygon('fill', x, y - 20, x - 20, y + 20, x + 20, y + 20)
    elseif not props.field then
      love.graphics.circle('line', x, y, 8)
    end

    -- Draw field
    if props.field then
      if not props.body then
        if props.field.strength < 0 then love.graphics.setColor(1, 0, 0)
        elseif props.field.strength > 0 then love.graphics.setColor(0, 0, 1)
      else love.graphics.setColor(0, 1, 0) end
      else
        love.graphics.setColor(1, 1, 1)
      end

      love.graphics.circle('line', x, y, math.abs(Entities[i].props.field.strength))
    end

    -- DELETAR !!!!!!
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(Entities[i].name, x, y + 10)
  end
end

