local pm = require('lib/playmat')
background = {
  types = {
		'antlia',
    'carina',
		'eridanus',
		'horologium',
		'bootes',
  },
  images = { },
	bottomStep = 0,
  middleStep = 0,
  topStep = 0,
	bottomMeshes = {},
  middleMeshes = {},
  topMeshes = {},
  tileSize = 64,
  grass = { },
	bottomCam = pm.newCamera(gameWidth + gameX * 2, gameHeight + gameY * 2, 0, 0, -math.pi / 2, 64, 1, 1),
  middleCam = pm.newCamera(gameWidth + gameX * 2, gameHeight + gameY * 2, 0, 0, -math.pi / 2, 64, 1, 1),
  topCam = pm.newCamera(gameWidth + gameX * 2, gameHeight + gameY * 2, 0, 0, -math.pi / 2, 64, 1, 1),
  currentType = 'bootes'
}
background.load = function()
  for i = 1, #background.types do
    background.images[background.types[i]] = {
      bottom = love.graphics.newImage("img/background/" .. tostring(background.types[i]) .. "/bottom.png"),
			middle = love.graphics.newImage("img/background/" .. tostring(background.types[i]) .. "/middle.png"),
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
  local speed = .75
  background.bottomStep = background.bottomStep + speed
	background.middleStep = background.topStep + (speed * 1.3)
  background.topStep = background.topStep + (speed * 1.6)
end
background.draw = function()
  local planeScale = .2
	local offset = -grid * 4.75 - 1

  pm.drawPlane(background.bottomCam, background.images[background.currentType].bottom, 0, background.bottomStep, planeScale, planeScale, true)
  love.graphics.draw(background.images[background.currentType].fade, gameX, gameY + grid)
  pm.drawPlane(background.middleCam, background.images[background.currentType].middle, offset, background.topStep, planeScale, planeScale, true)
  love.graphics.setStencilTest('greater', 0)
  pm.drawPlane(background.topCam, background.images[background.currentType].top, offset, background.topStep, planeScale, planeScale, true)
  love.graphics.setStencilTest()
  love.graphics.draw(background.images[background.currentType].fade, gameX, gameY)

end
