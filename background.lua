local pm = require('lib/playmat')
background = {
  images = {
		bottom = love.graphics.newImage('img/background/bottom.png'),
		middle = love.graphics.newImage('img/background/middle.png'),
		top = love.graphics.newImage('img/background/top.png'),
		fade = love.graphics.newImage('img/background/fade.png')
	},
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
  topCam = pm.newCamera(gameWidth + gameX * 2, gameHeight + gameY * 2, 0, 0, -math.pi / 2, 64, 1, 1)
}
background.load = function()
  for type, img in pairs(background.images) do
    background.images[type]:setFilter('nearest', 'nearest')
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

  pm.drawPlane(background.bottomCam, background.images.bottom, 0, background.bottomStep, planeScale, planeScale, true)
  love.graphics.draw(background.images.fade, gameX, gameY + grid)
  pm.drawPlane(background.middleCam, background.images.middle, offset, background.topStep, planeScale, planeScale, true)
  love.graphics.setStencilTest('greater', 0)
  pm.drawPlane(background.topCam, background.images.top, offset, background.topStep, planeScale, planeScale, true)
  love.graphics.setStencilTest()
  love.graphics.draw(background.images.fade, gameX, gameY)

end
