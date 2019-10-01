
local Vec = require './common/vec'
local Ent = require './common/entity'

math.randomseed(os.time())

-- DELETAR !!!
local function round(vec)
  local mult = 100
  local x, y = vec:get()

  return '(' .. math.floor(x*mult + 0.5)/mult .. ', ' .. math.floor(y*mult + 0.5)/mult .. ')'
end

local function isValidPath(path)
  local f = io.open(path, "r")

  if f then
    io.close(f)

    return true
  else
    return false
  end
end

local function getFileContent(path)
  if not isValidPath(path) then
    print('File ' .. path .. ' does not exist.\nEnding program...')

    return false
  end

  local chunk = love.filesystem.load(path)
  return chunk()
end

function love.load(args)
  -- Read scene
  local path = 'scene/' .. args[1] .. '.lua'
  local scene = getFileContent(path)
  if not scene then love.event.quit() return end

  -- Read entities
  Entities = {}

  for i=1, #scene do
    local entityPath = 'entity/' .. scene[i].entity .. '.lua'
    local props = getFileContent(entityPath)
    if not props then love.event.quit() return end

    Entities[i] = Ent(scene[i].entity, scene[i].n, props)

    if scene[i].entity == 'player' then
      Camera = Entities[i].positions[1].point
    end
  end
end

function love.draw()
  -- Window settings
  local w, h = love.graphics.getDimensions()

  if not Camera then
    love.graphics.scale(0.3, 0.3)
    love.graphics.translate(w/0.6, h/0.6)
  else
    local camX, camY = Camera:get()
    love.graphics.translate(-camX+w/2, -camY+h/2)
  end
  love.graphics.setBackgroundColor(.07, .024, .07)

  -- DELETAR !!!!!!
  love.graphics.setFont(love.graphics.newFont(30))

  -- Draw border circle
  love.graphics.setColor(1, 1, 1)
  love.graphics.circle('line', 0, 0, 1000)

  -- Draw entities
  for i=1, #Entities do
    for j=1, Entities[i].n do
      -- Set entity color
      love.graphics.setColor(Entities[i]:getMainColor())

      -- Draw entity
      local x, y = Entities[i].positions[j].point:get()

      if Entities[i].body then
        love.graphics.circle('fill', x, y, Entities[i].body.size)
      elseif Entities[i].control then
        love.graphics.polygon('fill', x, y - 15, x - 10, y + 15, x + 10, y + 15)
      elseif not Entities[i].field then
        love.graphics.circle('line', x, y, 8)
      end

      -- Draw field
      if Entities[i].field then
        love.graphics.setColor(Entities[i]:getSecondaryColor('field'))
        love.graphics.circle('line', x, y, math.abs(Entities[i].field.strength))
      end

      -- Draw charge
      if Entities[i].charge then
        love.graphics.setColor(Entities[i]:getSecondaryColor('charge'))

        local x1, y1, x2, y2 = Entities[i]:chargesPosition(j)

        love.graphics.circle('line', x1, y1, 4)
        love.graphics.circle('line', x2, y2, 4)
      end

      -- DELETAR !!!!!!
      love.graphics.setColor(1, 1, 1)
      love.graphics.print(round(Entities[i].speed), x, y + 10)
    end
  end
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

      local x, y = direction:get()

      if Entities[i].speed:length() > 0 or direction:length() > 0 then
        Camera = Entities[i]:updatePlayer(direction, dt)
      end
    end

    -- Update charges
    for j=1, Entities[i].n do
      if Entities[i].charge then
        -- Update position
        -- Entities[i]:updateChargesAcceleration(Entities, i)

        -- Update rotation
        local freq = math.sqrt(math.abs(Entities[i].charge.strength))
        Entities[i]:updateCharge(j, freq*dt)
        if Released then Released = false end
      end
    end
  end
end
