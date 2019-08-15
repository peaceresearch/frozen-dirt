explosions = {
  explosions = {},
  types = {'red', 'blue', 'gray'},
  images = {}
}

explosions.load = function()
  for i, type in pairs(explosions.types) do
    explosions.images[type] = {}
    for i = 1, 5 do
      explosions.images[type][i] = love.graphics.newImage('img/explosions/explosion-' .. tostring(type) .. tostring((i - 1)) .. '.png')
      explosions.images[type][i]:setFilter('nearest', 'nearest')
    end
  end
end

explosions.spawn = function(target, blue, big, gray, transparent)
  local explosion = {
    currentTexture = 1,
    x = target.x,
    y = target.y,
    xRandom = math.floor(math.random() * 2),
    yRandom = math.floor(math.random() * 2),
    clock = 0,
    prefix = 'red'
  }
  if blue then
    explosion.prefix = 'blue'
  elseif gray then
    explosion.prefix = 'gray'
  end
  if transparent then
    explosion.transparent = true
  end
  if explosion.xRandom == 0 then
    explosion.xRandom = -1
  end
  if explosion.yRandom == 0 then
    explosion.yRandom = -1
  end
  if big then
    explosion.xRandom = explosion.xRandom * 2
    explosion.yRandom = explosion.yRandom * 2
  end
  return table.insert(explosions.explosions, explosion)
end

explosions.update = function()
  local prune
  prune = function()
    if #explosions.explosions > 100 then
      table.remove(explosions.explosions, 1)
      return prune()
    end
  end
  prune()
  for i = 1, #explosions.explosions do
    local explosion = explosions.explosions[i]
    if explosion then
      local interval = 4
      explosion.clock = explosion.clock + 1
      if explosion.clock == interval then
        explosion.currentTexture = 2
      elseif explosion.clock == interval * 2 then
        explosion.currentTexture = 3
      elseif explosion.clock == interval * 3 then
        explosion.currentTexture = 4
      elseif explosion.clock == interval * 4 then
        explosion.currentTexture = 5
      elseif explosion.clock >= interval * 5 then
        table.remove(explosions.explosions, i)
      end
    end
  end
end

explosions.draw = function()
  for i = 1, #explosions.explosions do
    local explosion = explosions.explosions[i]
    local img = explosions.images[explosion.prefix][explosion.currentTexture]
    if explosion.transparent then
      love.graphics.setStencilTest('greater', 0)
    end
    love.graphics.draw(img, explosion.x + gameX, explosion.y + gameY, 0, explosion.xRandom, explosion.yRandom, img:getWidth() / 2, img:getHeight() / 2)
    if explosion.transparent then
      love.graphics.setStencilTest()
    end
  end
end
