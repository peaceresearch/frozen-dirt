graze = {
	image = love.graphics.newImage('img/player/graze.png'),
	graze = {}
}

function graze.load()
	graze.image:setFilter('nearest', 'nearest')
end

function graze.spawn(pos, angle)
	local speed = 1
	local grazeItem = {
		x = pos.x,
		y = pos.y,
		clock = 0,
		velocity = {
			x = math.cos(angle) * speed,
			y = math.sin(angle) * speed
		},
	}
	table.insert(graze.graze, grazeItem)
end

function graze.update()
	for i, v in ipairs(graze.graze) do
		local grazeItem = graze.graze[i]
		grazeItem.x = grazeItem.x + grazeItem.velocity.x
		grazeItem.y = grazeItem.y + grazeItem.velocity.y
		grazeItem.clock = grazeItem.clock + 1
		if grazeItem.clock >= 30 then
			table.remove(graze.graze, i)
		end
	end
end

function graze.draw()
	currentStencil = masks.quarter
	love.graphics.stencil(setStencilMask, 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	for i, v in ipairs(graze.graze) do
		local grazeItem = graze.graze[i]
		love.graphics.draw(graze.image, grazeItem.x, grazeItem.y, 0, 1, 1, graze.image:getWidth() / 2, graze.image:getHeight() / 2)
	end
	love.graphics.setStencilTest()
end
