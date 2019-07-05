local pm = require 'playmat'

background = {
	types = {'hell'},
	images = {},
  bottomStep = 0,
  topStep = 0,
  bottomMeshes = {},
  topMeshes = {},
  tileSize = 64,
	grass = {},
	bottomCam = pm.newCamera(gameWidth + gameX * 2, gameHeight + gameY * 2, 0, 0, 0, 64, 1, 1),
	topCam = pm.newCamera(gameWidth + gameX * 2, gameHeight + gameY * 2, 0, 0, 0, 64, 1, 1),
	currentType = 'hell'
}

function background.load()
	for i = 1, #background.types do
		background.images[background.types[i]] = {
			bottom = love.graphics.newImage('img/background/' .. background.types[i] .. '/bottom.png'),
			top = love.graphics.newImage('img/background/' .. background.types[i] .. '/top.png'),
			fade = love.graphics.newImage('img/background/' .. background.types[i] .. '/fade.png')
		}
	end
	for type, img in pairs(background.images) do
		for jType, jImg in pairs(background.images[type]) do
			background.images[type][jType]:setFilter('nearest', 'nearest')
		end
	end
end

function background.update()
	local speed = 1
	background.bottomStep = background.bottomStep - speed
	background.topStep = background.topStep - speed * 1.5
end

function background.draw()
	local planeScale = .2
	pm.drawPlane(background.bottomCam, background.images[background.currentType].bottom, background.bottomStep, 102, planeScale, planeScale, true)
	love.graphics.setStencilTest('greater', 0)
	pm.drawPlane(background.topCam, background.images[background.currentType].top, background.topStep, 60, planeScale, planeScale, true)
	love.graphics.setStencilTest()
	love.graphics.draw(background.images[background.currentType].fade, gameX, gameY)
end
