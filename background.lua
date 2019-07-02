local pm = require 'playmat'

background = {
	images = {
		bottom = love.graphics.newImage('img/background/bottom.png'),
		fadeBottom = love.graphics.newImage('img/background/fadebottom.png'),
		top = love.graphics.newImage('img/background/top.png'),
		fadeTop = love.graphics.newImage('img/background/fadetop.png'),
	},
  bottomStep = 0,
  topStep = 0,
  bottomMeshes = {},
  topMeshes = {},
  tileSize = 64,
	grass = {},
	bottomCam = pm.newCamera(gameWidth + gameX * 2, gameHeight + gameY * 2, 0, 0, 0, 64, 1, 1),
	topCam = pm.newCamera(gameWidth + gameX * 2, gameHeight + gameY * 2, 0, 0, 0, 64, 1, 1),
}

function background.load()
	for type, img in pairs(background.images) do
		background.images[type]:setFilter('nearest', 'nearest')
		background.images[type]:setWrap('repeat', 'repeat')
	end
end

function background.update()
	local speed = 1.75
	background.bottomStep = background.bottomStep - speed
	background.topStep = background.topStep - speed * 1.5
end

function background.draw()
	local planeScale = .5
	pm.drawPlane(background.bottomCam, background.images.bottom, background.bottomStep, 0, planeScale, planeScale, true)
	love.graphics.draw(background.images.fadeBottom, gameX, gameY)
	love.graphics.setStencilTest('greater', 0)
	pm.drawPlane(background.topCam, background.images.top, background.topStep, 0, planeScale, planeScale, true)
	love.graphics.setStencilTest()
	love.graphics.draw(background.images.fadeTop, gameX, gameY)
end
