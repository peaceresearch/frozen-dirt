drops = {
	dump = {},
	pointImage = love.graphics.newImage('img/drops/point.png')
}

function drops.load()
	drops.pointImage:setFilter('nearest', 'nearest')
end

function drops.spawnPoint(enemy)
	local drop = hc.circle(enemy.x, enemy.y, drops.pointImage:getWidth() / 2)
	drop.colliderType = 'drop'
	drop.x = math.floor(enemy.x)
	drop.y = math.floor(enemy.y)
	drop.image = drops.pointImage
	drop.speed = 3
	drop.clock = 0
	drop.rotation = math.tau * math.random()
	table.insert(drops.dump, drop)
end

local function updateDrop(index)
	local drop = drops.dump[index];
	local angle = getAngle(drop, player)
	drop.x = drop.x + math.cos(angle) * drop.speed
	drop.y = drop.y + math.sin(angle) * drop.speed
	drop.speed = drop.speed + .2
	drop:moveTo(drop.x, drop.y)
	drop.clock = drop.clock + 1
	if drop.y >= gameHeight + drop.image:getHeight() / 2 or
		drop.y < -drop.image:getHeight() / 2 or
		drop.x >= gameWidth + drop.image:getWidth() / 2 or
		drop.x < -drop.image:getWidth() / 2 or drop.collected
		then
			if drop.collected then
				currentScore = currentScore + 100
				if player.power < 3 then player.power = player.power + .025 end
			end
			hc.remove(drop)
			table.remove(drops.dump, index)
	end
end

function drops.update()
	for i, v in ipairs(drops.dump) do updateDrop(i) end
end

local function drawDrop(index)
	local drop = drops.dump[index]
	currentStencil = masks.quarter
	love.graphics.stencil(setStencilMask, 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	love.graphics.draw(drop.image, drop.x + gameX, drop.y + gameY, drop.rotation, 1, 1, drop.image:getWidth() / 2, drop.image:getHeight() / 2)
	love.graphics.setStencilTest()
end

function drops.draw()
	for i, v in ipairs(drops.dump) do drawDrop(i) end
end
