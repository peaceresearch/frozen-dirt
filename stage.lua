stage = {
	enemies = {},
	bullets = {},
	bulletTypes = {'red', 'redbig', 'redarrow', 'redpill', 'blue', 'bluebig', 'bluearrow', 'bluepill'},
	enemyTypes = {'fairyred', 'chen'},
	bulletImages = {},
	enemyImages = {},
	killBullets = false,
	killBulletTimer = 0
}

currentWave = nil

bossOffset = grid * 8

function stage.load()
	for i = 1, #stage.bulletTypes do stage.bulletImages[stage.bulletTypes[i]] = love.graphics.newImage('img/bullets/' .. stage.bulletTypes[i] .. '.png') end
	for i = 1, #stage.enemyTypes do
		stage.enemyImages[stage.enemyTypes[i]] = {
			idle1 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/idle1.png'),
			idle2 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/idle2.png'),
			idle3 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/idle3.png')
		}
	end
	for type, img in pairs(stage.bulletImages) do stage.bulletImages[type]:setFilter('nearest', 'nearest') end
	for type, img in pairs(stage.enemyImages) do
		for jType, jImg in pairs(stage.enemyImages[type]) do
			stage.enemyImages[type][jType]:setFilter('nearest', 'nearest')
		end
	end
end

function stage.spawnEnemy(type, x, y, initFunc, updateFunc)
	x = math.floor(x)
	y = math.floor(y)
	local enemy = hc.circle(x + gameX, y + gameY, stage.enemyImages[type].idle1:getWidth() / 2)
	enemy.image = stage.enemyImages[type].idle1
	enemy.images = stage.enemyImages[type]
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

function moveEnemySides(enemy)
	if not enemy.moveOffset then enemy.moveOffset = bossOffset end
	local diff = bossOffset
	if enemy.clock == 0 then
		enemy.initial = enemy.moveOffset - diff
		enemy.count = 0
	end
	local offset = math.cos(enemy.count) * diff
	local mod = .25
	enemy.moveOffset = enemy.initial - offset
	enemy.count = enemy.count + mod
	return enemy
end

local function updateEnemy(index)
	local enemy = stage.enemies[index]
	if enemy.updateFunc then stage.enemies[index].updateFunc(stage.enemies[index]) end
	if enemy.velocity then
		enemy.x = enemy.x + enemy.velocity.x
		enemy.y = enemy.y + enemy.velocity.y
		enemy:moveTo(enemy.x, enemy.y)
	end
	local img = enemy.images.idle1
	local interval = aniTime * 4
	if (enemy.clock % interval >= aniTime and enemy.clock % interval < aniTime * 2) or enemy.clock % interval >= aniTime * 3 then img = enemy.images.idle2
	elseif enemy.clock % interval >= aniTime * 2 and enemy.clock % interval < aniTime * 3 then img = enemy.images.idle3 end
	enemy.image = img
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
	bullet.visible = true
	bullet.color = 'red'
	if string.find(string.lower(type), 'blue') then bullet.color = 'blue' end
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
		local bound = grid * 10
		if bullet.y < gameY - bound or
			bullet.y > gameY + gameHeight + bound or
			bullet.x < gameX - bound or
			bullet.x > gameX + gameWidth + bound then
			hc.remove(bullet)
			table.remove(stage.bullets, index)
		elseif stage.killBullets then
 			explosions.spawn({x = bullet.x, y = bullet.y}, bullet.color == 'blue')
 			hc.remove(bullet)
 			table.remove(stage.bullets, index)
 		end
	end
end

local function drawBullet(index)
	local bullet = stage.bullets[index]
	if bullet.visible then
		love.graphics.draw(bullet.image, bullet.x + gameX, bullet.y + gameY, bullet.rotation, 1, 1, bullet.image:getWidth() / 2, bullet.image:getHeight() / 2)
	end
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
	if stage.killBullets then
		if stage.killBulletTimer == 0 then stage.killBulletTimer = 10 end
		stage.killBulletTimer = stage.killBulletTimer - 1
		if stage.killBulletTimer == 0 then stage.killBullets = false end
	end
end


function stage.draw()
	for i = 1, #stage.enemies do drawEnemy(i) end
	for i = 1, #stage.bullets do drawBullet(i) end
end
