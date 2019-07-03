stage = {
	enemies = {},
	bullets = {},
	bulletTypes = {'red', 'redbig', 'blue', 'bluebig'},
	enemyTypes = {'fairyred'},
	bulletImages = {},
	enemyImages = {}
}

currentWave = nil

function stage.load()
	for i = 1, #stage.bulletTypes do stage.bulletImages[stage.bulletTypes[i]] = love.graphics.newImage('img/bullets/' .. stage.bulletTypes[i] .. '.png') end
	for i = 1, #stage.enemyTypes do stage.enemyImages[stage.enemyTypes[i]] = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '.png') end
	for type, img in pairs(stage.bulletImages) do stage.bulletImages[type]:setFilter('nearest', 'nearest') end
	for type, img in pairs(stage.enemyImages) do stage.enemyImages[type]:setFilter('nearest', 'nearest') end
end

function stage.spawnEnemy(type, x, y, initFunc, updateFunc)
	x = math.floor(x)
	y = math.floor(y)
	local enemy = hc.circle(x, y, stage.enemyImages[type]:getWidth() / 2)
	enemy.image = stage.enemyImages[type]
	enemy.colliderType = 'enemy'
	enemy.clock = 0
	enemy.health = 10
	enemy.x = x
	enemy.y = y
	enemy.rotation = 0
	if initFunc then initFunc(enemy) end
	if updateFunc then enemy.updateFunc = updateFunc end
	table.insert(stage.enemies, enemy)
end

local function updateEnemy(index)
	local enemy = stage.enemies[index]
	if enemy.updateFunc then stage.enemies[index].updateFunc(stage.enemies[index]) end
	if enemy.velocity then
		enemy.x = enemy.x + enemy.velocity.x
		enemy.y = enemy.y + enemy.velocity.y
		enemy:moveTo(enemy.x, enemy.y)
	end
	enemy.clock = enemy.clock + 1
	if enemy.y < -enemy.image:getHeight() / 2 or
		enemy.y > gameHeight + enemy.image:getHeight() / 2 or
		enemy.x < -enemy.image:getWidth() / 2 or
		enemy.x > gameWidth + enemy.image:getWidth() / 2 then
		if enemy.suicide then enemy.suicide() end
		hc.remove(enemy)
		table.remove(stage.enemies, index)
	end
end

local function drawEnemy(index)
	local enemy = stage.enemies[index]
	love.graphics.draw(enemy.image, enemy.x + gameX, enemy.y + gameY, enemy.rotation, 1, 1, enemy.image:getWidth() / 2, enemy.image:getHeight() / 2)
end

function stage.spawnBullet(type, x, y, initFunc, updateFunc)
	x = math.floor(x)
	y = math.floor(y)
	local bullet = hc.circle(x, y, stage.bulletImages[type]:getWidth() / 2)
	bullet.image = stage.bulletImages[type]
	bullet.rotation = 0
	bullet.clock = 0
	bullet.grazed = false
	bullet.colliderType = 'bullet'
	bullet.x = x
	bullet.y = y
	if initFunc then initFunc(bullet) end
	if updateFunc then bullet.updateFunc = updateFunc end
	table.insert(stage.bullets, bullet)
end

local function updateBullet(index)
	local bullet = stage.bullets[index]
	if bullet then
		if bullet.updateFunc then stage.bullets[index].updateFunc(stage.bullets[index]) end
		if bullet.velocity then
			bullet.x = bullet.x + bullet.velocity.x
			bullet.y = bullet.y + bullet.velocity.y
			bullet:moveTo(bullet.x, bullet.y)
		end
		bullet.clock = bullet.clock + 1
		if bullet.y < -bullet.image:getHeight() / 2 or
			bullet.y > gameHeight + bullet.image:getHeight() / 2 or
			bullet.x < -bullet.image:getWidth() / 2 or
			bullet.x > gameWidth + bullet.image:getWidth() / 2 then
			hc.remove(bullet)
			table.remove(stage.bullets, index)
		end
	end
end

local function drawBullet(index)
	local bullet = stage.bullets[index]
	love.graphics.draw(bullet.image, bullet.x + gameX, bullet.y + gameY, bullet.rotation, 1, 1, bullet.image:getWidth() / 2, bullet.image:getHeight() / 2)
end

local function updateWaves()
	if not currentWave then currentWave = enemies.one end
	currentWave.func()
	currentWave.clock = currentWave.clock + 1
end

function stage.update()
	for i = 1, #stage.enemies do updateEnemy(i) end
	for i = 1, #stage.bullets do updateBullet(i) end
	updateWaves()
end

function stage.draw()
	for i = 1, #stage.enemies do drawEnemy(i) end
	for i = 1, #stage.bullets do drawBullet(i) end
end
