stage = {
	enemies = {},
	bullets = {},
	bulletTypes = {'arrow', 'big', 'bigb', 'small',	'bullet', 'bolt'},
	enemyTypes = {'cirno', 'fairyred', 'fairygreen', 'fairyyellow'},
	bulletImages = {},
	enemyImages = {},
	killBullets = false,
	killBulletTimer = 0,
	border = love.graphics.newImage('img/enemies/border.png'),
	glow = love.graphics.newImage('img/enemies/glow.png'),
	borderRotation = 0,
	borderScale = 1,
	borderScaleFlipped = false
}

currentWave = nil

bossOffset = grid * 5

function stage.load()
	for i = 1, #stage.bulletTypes do
		stage.bulletImages[stage.bulletTypes[i] .. '1'] = love.graphics.newImage('img/bullets/' .. stage.bulletTypes[i] .. '1.png')
		stage.bulletImages[stage.bulletTypes[i] .. '2'] = love.graphics.newImage('img/bullets/' .. stage.bulletTypes[i] .. '2.png')
		stage.bulletImages[stage.bulletTypes[i] .. '3'] = love.graphics.newImage('img/bullets/' .. stage.bulletTypes[i] .. '3.png')
		stage.bulletImages[stage.bulletTypes[i] .. '4'] = love.graphics.newImage('img/bullets/' .. stage.bulletTypes[i] .. '4.png')
	end
	for i = 1, #stage.enemyTypes do
		stage.enemyImages[stage.enemyTypes[i]] = {
			idle1 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/idle1.png'),
			idle2 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/idle2.png'),
			idle3 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/idle3.png'),
			left1 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/left1.png'),
			left2 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/left2.png'),
			right1 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/right1.png'),
			right2 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/right2.png'),
		}
		if stage.enemyTypes[i] == 'cirno' then
			stage.enemyImages[stage.enemyTypes[i]].idle4 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/idle4.png')
		else
			stage.enemyImages[stage.enemyTypes[i]].left3 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/left3.png')
			stage.enemyImages[stage.enemyTypes[i]].right3 = love.graphics.newImage('img/enemies/' .. stage.enemyTypes[i] .. '/right3.png')
		end
	end
	for type, img in pairs(stage.bulletImages) do stage.bulletImages[type]:setFilter('nearest', 'nearest') end
	for type, img in pairs(stage.enemyImages) do
		for jType, jImg in pairs(stage.enemyImages[type]) do stage.enemyImages[type][jType]:setFilter('nearest', 'nearest') end
	end
	stage.border:setFilter('nearest', 'nearest')
	stage.glow:setFilter('nearest', 'nearest')
end

function stage.spawnEnemy(type, x, y, initFunc, updateFunc)
	x = math.floor(x)
	y = math.floor(y)
	local enemy = hc.circle(x + gameX, y + gameY, stage.enemyImages[type].idle1:getWidth() / 2)
	enemy.image = stage.enemyImages[type].idle1
	enemy.images = stage.enemyImages[type]
	enemy.colliderType = 'enemy'
	enemy.clock = 0
	enemy.health = 1
	enemy.x = x
	enemy.y = y
	enemy.lastX = x
	enemy.rotation = 0
	enemy.movingLeftClock = 0
	enemy.movingRightClock = 0
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
	if enemy then
		enemy.sidesActive = false
		if enemy.updateFunc then stage.enemies[index].updateFunc(stage.enemies[index]) end
		if enemy.velocity then
			enemy.x = enemy.x + enemy.velocity.x
			enemy.y = enemy.y + enemy.velocity.y
			enemy:moveTo(enemy.x, enemy.y)
		end

		local img = enemy.images.idle1

		local interval = aniTime * 4
		local sideDiff = .2
		local sideMax = sideDiff * 1.8
		local sideAbs = math.abs(enemy.velocity.x)
		if enemy.isBoss then
			if enemy.velocity and sideAbs >= sideDiff then
				if enemy.x < enemy.lastX then
					img = enemy.images.left1
					if sideAbs >= sideMax then img = enemy.images.left2 end
				elseif enemy.x > enemy.lastX then
					img = enemy.images.right1
					if sideAbs >= sideMax then img = enemy.images.right2 end
				end
			elseif enemy.clock % interval >= aniTime and enemy.clock % interval < aniTime * 2 then img = enemy.images.idle2
			elseif enemy.clock % interval >= aniTime * 2 and enemy.clock % interval < aniTime * 3 then img = enemy.images.idle3
			elseif enemy.clock % interval >= aniTime * 3 then img = enemy.images.idle4 end
		else
			if enemy.velocity and sideAbs >= sideDiff then
				if enemy.x < enemy.lastX then
					img = enemy.images.left1
					if (enemy.clock % interval >= aniTime and enemy.clock % interval < aniTime * 2) or enemy.clock % interval >= aniTime * 3 then img = enemy.images.left2
					elseif enemy.clock % interval >= aniTime * 2 and enemy.clock % interval < aniTime * 3 then img = enemy.images.left3 end
				elseif enemy.x > enemy.lastX then
					img = enemy.images.right1
					if (enemy.clock % interval >= aniTime and enemy.clock % interval < aniTime * 2) or enemy.clock % interval >= aniTime * 3 then img = enemy.images.right2
					elseif enemy.clock % interval >= aniTime * 2 and enemy.clock % interval < aniTime * 3 then img = enemy.images.right3 end
				end
			else
				if (enemy.clock % interval >= aniTime and enemy.clock % interval < aniTime * 2) or enemy.clock % interval >= aniTime * 3 then img = enemy.images.idle2
				elseif enemy.clock % interval >= aniTime * 2 and enemy.clock % interval < aniTime * 3 then img = enemy.images.idle3 end
			end
		end

		enemy.image = img

		enemy.clock = enemy.clock + 1
		enemy.lastX = enemy.x
		local bounds = 1.5
		if enemy.y < -enemy.image:getHeight() * bounds or
			enemy.y > gameHeight + enemy.image:getHeight() * bounds or
			enemy.x < -enemy.image:getWidth() * bounds or
			enemy.x > gameWidth + enemy.image:getWidth() * bounds then
			if enemy.suicide then enemy.suicide() end
			hc.remove(enemy)
			table.remove(stage.enemies, index)
		end
	end
end

local function drawEnemy(index)
	local enemy = stage.enemies[index]

	if enemy.isBoss then
		currentStencil = masks.quarter
		love.graphics.stencil(setStencilMask, 'replace', 1)
		love.graphics.setStencilTest('greater', 0)
		local tempBorderScale = 1.25
		love.graphics.setColor(colors.blueDark)
		love.graphics.draw(stage.border, enemy.x, enemy.y, stage.borderRotation, stage.borderScale * tempBorderScale * 1.1, stage.borderScale * tempBorderScale, stage.border:getWidth() / 2, stage.border:getHeight() / 2)
		love.graphics.draw(stage.glow, enemy.x, enemy.y, -stage.borderRotation, 1, 1, stage.glow:getWidth() / 2, stage.glow:getHeight() / 2)
		currentStencil = masks.half
		love.graphics.stencil(setStencilMask, 'replace', 1)
		love.graphics.draw(stage.glow, enemy.x, enemy.y, -stage.borderRotation, .75, .75, stage.glow:getWidth() / 2, stage.glow:getHeight() / 2)
		love.graphics.setColor(colors.white)
		love.graphics.setStencilTest()
	end

	love.graphics.draw(enemy.image, enemy.x + gameX, enemy.y + gameY, enemy.rotation, 1, 1, enemy.image:getWidth() / 2, enemy.image:getHeight() / 2)
end

local animateBulletInterval = 5

function stage.spawnBullet(type, x, y, initFunc, updateFunc)
	x = math.floor(x)
	y = math.floor(y)
	width = stage.bulletImages[type .. '1']:getWidth() / 2
	local bullet = hc.circle(x, y, width)
	bullet.bulletType = type
	bullet.rotation = 0
	bullet.clock = 0
	bullet.grazed = false
	bullet.colliderType = 'bullet'
	bullet.x = x
	bullet.y = y
	bullet.visible = true
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
		local animateTime = animateBulletInterval * 4
		local img = bullet.bulletType .. '1'
		if bullet.clock % animateTime >= animateTime / 4 and bullet.clock % animateTime < animateTime / 2 then img = bullet.bulletType .. '2'
		elseif bullet.clock % animateTime >= animateTime / 2 and bullet.clock % animateTime < animateTime / 4 * 3 then img = bullet.bulletType .. '3'
		elseif bullet.clock % animateTime >= animateTime / 4 then img = bullet.bulletType .. '4' end
		bullet.image = stage.bulletImages[img]
		bullet.clock = bullet.clock + 1
		local bound = grid * 10
		if bullet.y < gameY - bound or
			bullet.y > gameY + gameHeight + bound or
			bullet.x < gameX - bound or
			bullet.x > gameX + gameWidth + bound then
			hc.remove(bullet)
			table.remove(stage.bullets, index)
		elseif stage.killBullets then
 			explosions.spawn({x = bullet.x, y = bullet.y}, bullet.color == 'blue', false, bullet.color == 'gray')
 			hc.remove(bullet)
 			table.remove(stage.bullets, index)
 		end
	end
end

local function drawBullet(index)
	local bullet = stage.bullets[index]
	if bullet.visible then
		if bullet.transparent or bullet.superTransparent then
			if bullet.superTransparent then
				currentStencil = masks.quarter
				love.graphics.stencil(setStencilMask, 'replace', 1)
			end
			love.graphics.setStencilTest('greater', 0)
		end
		love.graphics.draw(bullet.image, bullet.x + gameX, bullet.y + gameY, bullet.rotation, 1, 1, bullet.image:getWidth() / 2, bullet.image:getHeight() / 2)
		if bullet.transparent or bullet.superTransparent then
			if bullet.superTransparent then
				currentStencil = masks.half
				love.graphics.stencil(setStencilMask, 'replace', 1)
			end
			love.graphics.setStencilTest()
		end
	end
end

local function updateWaves()
	if not currentWave then currentWave = enemies.stageFiveBoss end
	currentWave.func()
	currentWave.clock = currentWave.clock + 1
end

function spawnBoss(type, attacks, moves, suicide, subUpdateFunc)
	stage.spawnEnemy(type, gameWidth / 2, -stage.enemyImages.cirno.idle1:getHeight() / 2, function(enemy)
		enemy.angle = math.pi / 2
		enemy.speed = 1.85
		enemy.currentAttack = 1
		enemy.health = 300
		enemy.started = false
		bossHealthInit = enemy.health
		enemy.isBoss = true
		if subUpdateFunc then enemy.subUpdateFunc = subUpdateFunc end
		function enemy.suicide(enemy)
			suicide(enemy)
		end
	end, function(enemy)
		if enemy.started then
			local current = 1
			for i = 1, #attacks do if enemy.health >= bossHealthInit / #attacks * (i - 1) then current = #attacks - i + 1 end end
			if enemy.currentAttack ~= current then
				stage.killBullets = true
				enemy.clock = -90
				enemy.lastHealth = enemy.health
				enemy.currentAttack = current
			end
			if enemy.clock >= 0 then
				attacks[enemy.currentAttack](enemy)
			end
			bossHealth = enemy.health
			if enemy.subUpdateFunc then enemy.subUpdateFunc(enemy) end
		else
			if enemy.lastHealth then enemy.health = enemy.lastHealth end
			enemy.speed = enemy.speed - .02
			if enemy.speed <= 0 then
				enemy.speed = 0
				enemy.clock = -1
				enemy.started = true
				enemy.angle = 0
				enemy.y = math.floor(enemy.y)
			end
			enemy.velocity = {
				x = math.cos(enemy.angle) * enemy.speed,
				y = math.sin(enemy.angle) * enemy.speed
			}
		end
	end)
end

function stage.prepForBoss(wave)
	if currentWave.clock > 0 and #stage.enemies == 0 then
		if goingToBossClock == 0 then goingToBossClock = goingToBossLimit
		elseif goingToBossClock == 1 then
			currentWave = enemies[wave]
			currentWave.clock = -1
		end
	end
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
	stage.borderRotation = stage.borderRotation + .005
	local mod = .001
	if stage.borderScaleFlipped then mod = -mod end
	stage.borderScale = stage.borderScale + mod
	if stage.borderScale >= 1.15 then
		stage.borderScaleFlipped = true
	elseif stage.borderScale < 1 then
		stage.borderScaleFlipped = false
	end

end

function stage.draw()
	for i = 1, #stage.enemies do drawEnemy(i) end
	for i = 1, #stage.bullets do drawBullet(i) end
end
