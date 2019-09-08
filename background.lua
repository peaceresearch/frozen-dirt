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
	bottomMeshes = {},
  middleMeshes = {},
  tileSize = 64,
  grass = { },
	bottomCam = pm.newCamera(gameWidth + gameX * 2, winHeight + gameY * 2, 0, 0, -math.pi / 2, 32, 1, 1),
  middleCam = pm.newCamera(gameWidth + gameX * 2, winHeight + gameY * 2, 0, 0, -math.pi / 2, 32, 1, 1)
}

background.load = function()
  for type, img in pairs(background.images) do
    background.images[type]:setFilter('nearest', 'nearest')
  end
end

background.update = function()
  local speed = 1
  background.bottomStep = background.bottomStep + speed
	background.middleStep = background.middleStep + speed * .75
end

background.draw = function()
  local planeScale = .2
	local offset = -grid * 4.75 - 1
	pm.drawPlane(background.bottomCam, background.images.bottom, 0, background.bottomStep, planeScale, planeScale, true)
	pm.drawPlane(background.middleCam, background.images.middle, offset, background.middleStep, planeScale, planeScale, true)
	love.graphics.draw(background.images.fade, gameX, gameY - 1)
	love.graphics.setColor(colors.black)
	currentStencil = masks.half
	love.graphics.stencil(setStencilMask, 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	love.graphics.rectangle('fill', gameX, gameY, gameWidth, winHeight)
  love.graphics.setStencilTest()
	love.graphics.setColor(colors.white)
end
