stage = {
	enemies = {},
	bullets = {},
	bulletImages = {
		redbig = love.graphics.newImage('img/bullets/redbig.png')
	},
	clock = 0
}

function stage.load()
	for type, img in pairs(stage.bulletImages) do
		stage.bulletImages[type]:setFilter('nearest', 'nearest')
	end
end

function stage.update()
	stage.clock = stage.clock + 1
end

function stage.draw()
	local img = stage.bulletImages.redbig
	love.graphics.draw(img, gameX + gameWidth / 2, gameY + gameHeight / 2, 0, 1, 1, img:getWidth() / 2, img:getHeight() / 2)
end
