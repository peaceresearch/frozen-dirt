pm = require 'playmat'

background = {
	imageTypes = {'forest'},
  currentType = 'forest',
	images = {},
  bottomStep = 0,
  topStep = 0,
  bottomMeshes = {},
  topMeshes = {},
  tileSize = 64,
	grass = {},
	speed = .01,
	cam = false
}

function background.load()
	for i, v in ipairs(background.imageTypes) do
		local name = background.imageTypes[i]
		-- background.images[name .. 'Fade'] = love.graphics.newImage('img/background/' .. name .. 'fade.png')
		background.images[name .. 'Bottom'] = love.graphics.newImage('img/background/' .. name .. 'bottom.png')
		-- background.images[name .. 'Top'] = love.graphics.newImage('img/background/' .. name .. 'top.png')
	end
	for type, img in pairs(background.images) do
		background.images[type]:setFilter('nearest', 'nearest')
		background.images[type]:setWrap('repeat', 'repeat')
	end
	background.cam = pm.newCamera()
	background.cam:setOffset(1)
	background.cam:setPosition(0, 0)
	background.cam:setZoom(1)
	background.cam:setRotation(0)
	background.cam:setFov(1)
end

function background.update()

end

function background.draw()
	pm.drawPlane(background.cam, background.images[background.currentType .. 'Bottom'])
end
