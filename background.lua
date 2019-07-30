local pm = require('lib/playmat')
background = {
  types = {
    'hell'
  },
  images = { },
  bottomStep = 0,
  topStep = 0,
  bottomMeshes = { },
  topMeshes = { },
  tileSize = 64,
  grass = { },
  bottomCam = pm.newCamera(gameWidth + gameX * 2, gameHeight + gameY * 2, 0, 0, 0, 64, 1, 1),
  topCam = pm.newCamera(gameWidth + gameX * 2, gameHeight + gameY * 2, 0, 0, 0, 64, 1, 1),
  currentType = 'hell'
}
background.load = function()
  for i = 1, #background.types do
    background.images[background.types[i]] = {
      bottom = love.graphics.newImage("img/background/" .. tostring(background.types[i]) .. "/bottom.png"),
      top = love.graphics.newImage("img/background/" .. tostring(background.types[i]) .. "/top.png"),
      fade = love.graphics.newImage("img/background/" .. tostring(background.types[i]) .. "/fade.png")
    }
  end
  for type, img in pairs(background.images) do
    for jType, jImg in pairs(background.images[type]) do
      background.images[type][jType]:setFilter('nearest', 'nearest')
    end
  end
end
background.update = function()
  local speed = 1
  background.bottomStep = background.bottomStep - speed
  background.topStep = background.topStep - (speed * 1.5)
end
background.draw = function()
  local planeScale = .2
  pm.drawPlane(background.bottomCam, background.images[background.currentType].bottom, background.bottomStep, 102, planeScale, planeScale, true)
  love.graphics.setStencilTest('greater', 0)
  pm.drawPlane(background.topCam, background.images[background.currentType].top, background.topStep, 60, planeScale, planeScale, true)
  love.graphics.setStencilTest()
  return love.graphics.draw(background.images[background.currentType].fade, gameX, gameY)
end
