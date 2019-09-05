local pm = require('lib/playmat')
background = {
  images = {
		bottom = love.graphics.newImage('img/background/bottom.png'),
		middleBase = love.graphics.newImage('img/background/middle-base.png'),
		middleColor = love.graphics.newImage('img/background/middle-color.png'),
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

local stageColor = false

background.load = function()
  for type, img in pairs(background.images) do
    background.images[type]:setFilter('nearest', 'nearest')
  end

	-- forest of magic
	stageColor = 'purple'

	-- spring path
	-- stageColor = 'gray'

	-- misty lake
	-- stageColor = 'blue'

end

background.update = function()
  local speed = 1
  background.bottomStep = background.bottomStep + speed
	background.middleStep = background.middleStep + (speed * 1.15)
  background.topStep = background.topStep + (speed * 1.5)

end

background.draw = function()
  local planeScale = .2
	local offset = -grid * 4.75 - 1
	love.graphics.setColor(colors.black)
	love.graphics.rectangle('fill', gameX, gameY, gameWidth, gameHeight)
	love.graphics.setColor(colors[stageColor])
  pm.drawPlane(background.bottomCam, background.images.bottom, 0, background.bottomStep, planeScale, planeScale, true)
	love.graphics.setColor(colors.white)
	pm.drawPlane(background.middleCam, background.images.middleBase, offset, background.middleStep, planeScale, planeScale, true)
	love.graphics.setColor(colors[stageColor])
  pm.drawPlane(background.middleCam, background.images.middleColor, offset, background.middleStep, planeScale, planeScale, true)
	love.graphics.setColor(colors.white)
	currentStencil = masks.half
	-- love.graphics.stencil(setStencilMask, 'replace', 1)
	-- love.graphics.setStencilTest('greater', 0)
  -- pm.drawPlane(background.topCam, background.images.top, offset, background.topStep, planeScale, planeScale, true)
  -- love.graphics.setStencilTest()
	love.graphics.draw(background.images.fade, gameX, gameY - 1)
	love.graphics.setColor(colors.purple)
	love.graphics.stencil(setStencilMask, 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	love.graphics.rectangle('fill', gameX, gameY, gameWidth, gameHeight)
  love.graphics.setStencilTest()
	love.graphics.setColor(colors.white)

end
