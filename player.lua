player = {
	speed = 4,
	startingX = gameWidth / 2,
	startingY = gameHeight - grid * 4,
	currentType = 'reimu',
	images = {
		hitbox = love.graphics.newImage('img/player/hitbox.png'),
		hitboxBottom = love.graphics.newImage('img/player/hitboxbottom.png'),
		bulletMarisa = love.graphics.newImage('img/player/bullet-marisa.png'),
		border = love.graphics.newImage('img/player/border.png')
	},
	grazeSize = grid * 1.75,
	clock = 0,
	bullets = {},
	canShoot = true,
	bulletSpeed = 20,
	shotClock = 0,
	invulnerableClock = 0,
	lives = 2,
	bombs = 3,
	lasers = {},
	sideOffset = grid * 1.75,
	sideY = 0,
	borderRotationA = 0,
	borderRotationB = 0
}

local function setupLasers()
	for i = 1, 2 do
		local laserObj = {
			x = 0,
			y = 0,
			height = 0,
			width = 6,
			collider = hc.rectangle(0, 0, 6, gameHeight) -- need to find how to change height/width of collider
		}
		table.insert(player.lasers, laserObj)
	end
end

function player.load()
	local types = {'idle'}
	for i = 1, #types do
		for j = 1, 3 do 	player.images[types[i] .. j] = love.graphics.newImage('img/player/' .. player.currentType .. '/' .. types[i] .. j .. '.png') end
	end

	player.images.side = love.graphics.newImage('img/player/' .. player.currentType .. '/side.png')
	for type, img in pairs(player.images) do
		player.images[type]:setFilter('nearest', 'nearest')
		player.images[type]:setWrap('repeat', 'repeat')
	end
	player.x = math.floor(player.startingX)
	player.y = math.floor(player.startingY)
	player.collider = hc.circle(player.x, player.y, 0)
	player.grazeCollider = hc.circle(player.x, player.y, player.grazeSize)
	setupLasers()
end

function player.currentImage()
	local img = player.images.idle1
	local interval = aniTime * 4
	if (player.clock % interval >= aniTime and player.clock % interval < aniTime * 2) or (player.clock % interval >= aniTime * 3) then img = player.images.idle2
	elseif player.clock % interval >= aniTime * 2 and player.clock % interval < aniTime * 3 then img = player.images.idle3 end
	return img
end

local function spawnBullet(diff, yOffset)
	local mod = math.pi / 15
	local size = 22
	local y = player.y
	local x = player.x
	if yOffset then y = y + yOffset * 10 end
	if player.hitboxVisible then
		x = x + 8
		if yOffset then x = x - 4 * math.abs(yOffset) end
	end
	local bullet = hc.circle(x + gameX, y + gameY, size / 2)
	bullet.image = player.images.bulletMarisa
	local angle = -math.pi / 2
	bullet.angle = angle + diff * mod
	bullet.rotation = angle + diff * mod
	bullet.diff = .1
	bullet.initial = 0
	bullet.count = 0
	bullet.x = x
	bullet.y = y
	table.insert(player.bullets, bullet)
end

local function updateMove()
	local speed = player.speed
	if controls.focus then
		speed = 2
		local mod = .01
		player.borderRotationA = player.borderRotationA + mod
		player.borderRotationB = player.borderRotationB - mod / 2
	end
	if controls.left then player.x = player.x - speed
	elseif controls.right then player.x = player.x + speed end
	if controls.up then player.y = player.y - speed
	elseif controls.down then player.y = player.y + speed end
	if player.x <= player.images.hitbox:getWidth() / 2 then player.x = player.images.hitbox:getWidth() / 2
	elseif player.x >= gameWidth - player.images.hitbox:getWidth() / 2 then player.x = gameWidth - player.images.hitbox:getWidth() / 2 end
	if player.y <= player.images.hitbox:getHeight() / 2 then player.y = player.images.hitbox:getHeight() / 2
	elseif player.y >= gameHeight - player.images.hitbox:getHeight() / 2 then player.y = gameHeight - player.images.hitbox:getHeight() / 2 end
	player.collider:moveTo(player.x, player.y)
	player.grazeCollider:moveTo(player.x, player.y)
end

local function updateBullet(index)
	local bullet = player.bullets[index]
	bullet.count = bullet.count + .5
	bullet.x = bullet.x + math.cos(bullet.angle) * player.bulletSpeed
	bullet.y = bullet.y + math.sin(bullet.angle) * player.bulletSpeed
	bullet:moveTo(bullet.x, bullet.y)
	if bullet.y < -bullet.image:getHeight() / 2 then
		hc.remove(bullet)
		table.remove(player.bullets, index)
	else
		collision.check(hc.collisions(bullet), 'enemy', function(enemy)
			if enemy.health <= 0 then
				enemy.x = -gameWidth
				enemy.y = -gameHeight
			elseif enemy and (enemy.health) then
				enemy.health = enemy.health - 1
				explosions.spawn(bullet, true)
			end
			bullet.x = -gameWidth
			bullet.y = -gameHeight
		end)
	end
end

local function updateShoot()
	if controls.shoot and player.canShoot and player.clock >= 15 and player.invulnerableClock < 60 * 3 then
		player.canShoot = false
		player.shotClock = 0
	end
	local interval = 5
	local limit = interval * 2
	local max = limit * 3
	if not player.canShoot then
		if player.shotClock % interval == 0 and player.shotClock <= limit then
			spawnBullet(.25)
			spawnBullet(-.25)
		end
		player.shotClock = player.shotClock + 1
	end
	if player.shotClock >= max then player.canShoot = true end
	for i, v in ipairs(player.bullets) do updateBullet(i) end
end

local function updateLaser()
	for i = 1, #player.lasers do
		local laser = player.lasers[i]
		if i == 1 then laser.x = player.x - player.sideOffset - 3
		else laser.x = player.x + player.sideOffset - 4 end
		if controls.shoot then
			local max = player.y + player.sideY - gameY
			local function doDimensions()
				if laser.height < max then laser.height = laser.height + 32 end
				if laser.height > max then laser.height = max end
				laser.y = gameY + max - laser.height
			end
			doDimensions()
			laser.collider:moveTo(laser.x, 0)
			collision.check(hc.collisions(laser.collider), 'enemy', function(enemy)
				if enemy.health <= 0 then
					enemy.x = -gameWidth
					enemy.y = -gameHeight
				elseif enemy and (enemy.health) then enemy.health = enemy.health - .1 end
				if gameClock % 5 == 0 then explosions.spawn(laser, true) end
				max = max - enemy.y - enemy.image:getHeight() / 2
				doDimensions()
				laser.y = laser.y + enemy.y + enemy.image:getHeight() / 2
			end)
		elseif laser.height > 0 then
			laser.height = 0
		end
	end
end

function player.update()
	local yOff = 4.5
	if controls.focus then
		if player.sideOffset > 10 then
			player.sideOffset = player.sideOffset - 3
			player.sideY = player.sideY - yOff
		end
	else
		if player.sideOffset < 30 then
			player.sideOffset = player.sideOffset + 3
			player.sideY = player.sideY + yOff
		else
			player.sideOffset = 30
			player.sideY = grid
		end
	end
	updateMove()
	updateShoot()
	updateLaser()
	player.clock = player.clock + 1
end

local function drawBullet(index)
	local bullet = player.bullets[index]
	love.graphics.setStencilTest('greater', 0)
	love.graphics.draw(bullet.image, bullet.x + gameX, bullet.y + gameY, bullet.rotation, 1, 1, bullet.image:getWidth() / 2, bullet.image:getHeight() / 2)
	love.graphics.setStencilTest()
end

local function drawLaser()
	love.graphics.setStencilTest('greater', 0)
	for i = 1, #player.lasers do
		local laser = player.lasers[i]
		love.graphics.setColor(colors.blueLight)
		love.graphics.rectangle('fill', gameX + laser.x, laser.y, laser.width, laser.height)
		love.graphics.setColor(colors.white)
		love.graphics.rectangle('fill', gameX + laser.x + 2, laser.y, laser.width - 4, laser.height)
	end
	love.graphics.setStencilTest()
end

local function drawBorder()
	currentStencil = masks.quarter
	love.graphics.stencil(setStencilMask, 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	love.graphics.setColor(colors.peach)
	love.graphics.draw(player.images.border, player.x + gameX - 1, player.y + gameY, player.borderRotationA, 1, 1, player.images.border:getWidth() / 2, player.images.border:getHeight() / 2)
	love.graphics.draw(player.images.border, player.x + gameX - 1, player.y + gameY, player.borderRotationB, 1, 1, player.images.border:getWidth() / 2, player.images.border:getHeight() / 2)
	love.graphics.setColor(colors.white)
	love.graphics.setStencilTest()
	currentStencil = masks.half
	love.graphics.stencil(setStencilMask, 'replace', 1)
end

function player.draw()
	for i, v in ipairs(player.bullets) do drawBullet(i) end
	if controls.focus then drawBorder() end
	love.graphics.draw(player.currentImage(), player.x + gameX, player.y + gameY + 2, 0, 1, 1, player.currentImage():getWidth() / 2, player.currentImage():getHeight() / 2)
	if controls.shoot then drawLaser() end
	love.graphics.draw(player.images.side, player.x + gameX - player.sideOffset, player.y + player.sideY, 0, 1, 1, player.images.side:getWidth() / 2, player.images.side:getHeight() / 2)
	love.graphics.draw(player.images.side, player.x + gameX + player.sideOffset, player.y + player.sideY, 0, 1, 1, player.images.side:getWidth() / 2, player.images.side:getHeight() / 2)
	if controls.focus then
		love.graphics.setStencilTest('greater', 0)
		love.graphics.draw(player.images.hitboxBottom, player.x + gameX - 1, player.y + gameY - 1, 0, 1, 1, player.images.hitbox:getWidth() / 2, player.images.hitbox:getHeight() / 2)
		love.graphics.setStencilTest()
		love.graphics.draw(player.images.hitbox, player.x + gameX, player.y + gameY, 0, 1, 1, player.images.hitbox:getWidth() / 2, player.images.hitbox:getHeight() / 2)
	end
end
