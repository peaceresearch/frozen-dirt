player = {
	speed = 3,
	startingX = gameWidth / 2,
	startingY = gameHeight - grid * 4,
	images = {
		hitbox = love.graphics.newImage('img/player/hitbox.png'),
		hitboxBottom = love.graphics.newImage('img/player/hitboxbottom.png'),
		border = love.graphics.newImage('img/player/border.png'),
		idle1 = love.graphics.newImage('img/player/idle1.png'),
		idle2 = love.graphics.newImage('img/player/idle2.png'),
		idle3 = love.graphics.newImage('img/player/idle3.png'),
		left1 = love.graphics.newImage('img/player/left1.png'),
		left2 = love.graphics.newImage('img/player/left2.png'),
		right1 = love.graphics.newImage('img/player/right1.png'),
		right2 = love.graphics.newImage('img/player/right2.png'),
		side = love.graphics.newImage('img/player/side.png'),
		bullet = love.graphics.newImage('img/player/bullet.png'),
		wing1 = love.graphics.newImage('img/player/wing1.png'),
		wing2 = love.graphics.newImage('img/player/wing2.png'),
		wing3 = love.graphics.newImage('img/player/wing3.png')
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
	sideOffset = grid * 1.75,
	sideY = 0,
	borderRotationA = 0,
	borderRotationB = 0,
	sideRotation = 0,
	leftClock = 0,
	rightClock = 0,
	power = 1
}

function player.load()
	for type, img in pairs(player.images) do
		player.images[type]:setFilter('nearest', 'nearest')
		player.images[type]:setWrap('repeat', 'repeat')
	end
	player.x = math.floor(player.startingX)
	player.y = math.floor(player.startingY)
	player.collider = hc.circle(player.x, player.y, 0)
	player.grazeCollider = hc.circle(player.x, player.y, player.grazeSize)
end

function player.currentImage()
	local img = player.images.idle1
	local interval = aniTime * 4
	if controls.left then
		img = player.images.left1
		if player.leftClock >= interval / 2 then img = player.images.left2 end
		player.leftClock = player.leftClock + 1
	elseif controls.right then
		img = player.images.right1
		if player.rightClock >= interval / 2 then img = player.images.right2 end
		player.rightClock = player.rightClock + 1
	else
		if (player.clock % interval >= aniTime and player.clock % interval < aniTime * 2) or (player.clock % interval >= aniTime * 3) then img = player.images.idle2
		elseif player.clock % interval >= aniTime * 2 and player.clock % interval < aniTime * 3 then img = player.images.idle3 end
		player.leftClock = 0
		player.rightClock = 0
	end
	return img
end

local function updateMove()
	local speed = player.speed
	if controls.focus then
		speed = speed / 2
		local mod = .01
		player.borderRotationA = player.borderRotationA + mod
		player.borderRotationB = player.borderRotationB - mod / 2
	end
	if controls.left then
		player.x = player.x - speed
		player.leftClock = player.leftClock + 1
	elseif controls.right then
		player.x = player.x + speed
		player.rightClock = player.rightClock + 1
	end
	if controls.up then player.y = player.y - speed
	elseif controls.down then player.y = player.y + speed end
	if player.x <= player.images.hitbox:getWidth() / 2 then player.x = player.images.hitbox:getWidth() / 2
	elseif player.x >= gameWidth - player.images.hitbox:getWidth() / 2 then player.x = gameWidth - player.images.hitbox:getWidth() / 2 end
	if player.y <= player.images.hitbox:getHeight() / 2 then player.y = player.images.hitbox:getHeight() / 2
	elseif player.y >= gameHeight - player.images.hitbox:getHeight() / 2 then player.y = gameHeight - player.images.hitbox:getHeight() / 2 end
	player.collider:moveTo(player.x, player.y)
	player.grazeCollider:moveTo(player.x, player.y)
end

local function spawnBullet(diff, yOffset)
	local mod = math.pi / 15
	local size = 22
	local y = player.y
	local x = player.x
	if yOffset then y = y + yOffset * 10 end
	local bullet = hc.circle(x + gameX, y + gameY, size / 2)
	bullet.image = player.images.bullet
	local angle = -math.pi / 2
	bullet.angle = angle + diff * mod
	bullet.rotation = angle + diff * mod
	bullet.diff = .1
	bullet.initial = 0
	bullet.count = 0
	bullet.x = x
	bullet.y = y
	bullet.visible = false
	bullet.clock = 0
	bullet.timeSet = 1
	if controls.focus then bullet.timeSet = 2 end
	table.insert(player.bullets, bullet)
end

local function updateBullet(index)
	local bullet = player.bullets[index]
	bullet.count = bullet.count + .5
	local angle = -math.pi / 2
	if bullet.angle then angle = bullet.angle end
	if not bullet.visible and bullet.clock >= bullet.timeSet then bullet.visible = true end
	bullet.clock = bullet.clock + 1
	bullet.x = bullet.x + math.cos(angle) * player.bulletSpeed
	bullet.y = bullet.y + math.sin(angle) * player.bulletSpeed
	bullet:moveTo(bullet.x, bullet.y)
	if bullet.y < -bullet.image:getHeight() / 2 then
		hc.remove(bullet)
		table.remove(player.bullets, index)
	else
		collision.check(hc.collisions(bullet), 'enemy', function(enemy)
			if enemy.health <= 0 then
				drops.spawnPoint(enemy)
				explosions.spawn(enemy, false, true, true)
				enemy.x = -gameWidth
				enemy.y = -gameHeight
			elseif enemy and (enemy.health) then
				if enemy.isBoss and enemy.clock >= 0 then enemy.health = enemy.health - 1
				elseif not enemy.isBoss then enemy.health = enemy.health - 1 end
				explosions.spawn(bullet, false, false, true)
			end
			bullet.x = -gameWidth
			bullet.y = -gameHeight
		end)
	end
end

local function updateShoot()
	if controls.shoot and player.canShoot and player.clock >= 15 and player.invulnerableClock <= 60 * 3 then
		player.canShoot = false
		player.shotClock = 0
	end
	local interval = 10
	local limit = interval * 2
	local max = limit * 2
	if not player.canShoot then
		if player.shotClock % interval == 0 and player.shotClock <= limit then
			local diff = 1
			if controls.focus then
				diff = .25
			end
			spawnBullet(diff)
			spawnBullet(0)
			spawnBullet(-diff)
		end
		player.shotClock = player.shotClock + 1
	end
	if player.shotClock >= max then player.canShoot = true end
	for i, v in ipairs(player.bullets) do updateBullet(i) end
end

local function drawBullet(index)
	local bullet = player.bullets[index]
	if bullet.visible then
		love.graphics.draw(bullet.image, bullet.x + gameX, bullet.y + gameY, bullet.rotation, 1, 1, bullet.image:getWidth() / 2, bullet.image:getHeight() / 2)
	end
end

local function drawBorder()
	currentStencil = masks.quarter
	love.graphics.stencil(setStencilMask, 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	love.graphics.setColor(colors.offWhite)
	love.graphics.draw(player.images.border, player.x + gameX, player.y + gameY, player.borderRotationA, 1, 1, player.images.border:getWidth() / 2, player.images.border:getHeight() / 2)
	love.graphics.draw(player.images.border, player.x + gameX, player.y + gameY, player.borderRotationB, 1, 1, player.images.border:getWidth() / 2, player.images.border:getHeight() / 2)
	love.graphics.setColor(colors.white)
	love.graphics.setStencilTest()
	currentStencil = masks.half
	love.graphics.stencil(setStencilMask, 'replace', 1)
end

local function drawSides()
	-- if player.power > 1 then
		love.graphics.draw(player.images.side, player.x + gameX - player.sideOffset, player.y + player.sideY, player.sideRotation, 1, 1, player.images.side:getWidth() / 2, player.images.side:getHeight() / 2)
		love.graphics.draw(player.images.side, player.x + gameX + player.sideOffset - 1, player.y + player.sideY, -player.sideRotation, 1, 1, player.images.side:getWidth() / 2, player.images.side:getHeight() / 2)
	-- end
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
	player.sideRotation = player.sideRotation - .015
	player.clock = player.clock + 1
	if player.invulnerableClock > 0 then
		if player.invulnerableClock > 60 * 3 then
			player.x = player.startingX
			player.y = player.startingY
		end
		player.invulnerableClock = player.invulnerableClock - 1
	end
end

local function drawWings()
	local img = player.images.wing1
	local interval = aniTime * 4
	if (player.clock % interval >= aniTime and player.clock % interval < aniTime * 2) or (player.clock % interval >= aniTime * 3) then img = player.images.wing2
	elseif player.clock % interval >= aniTime * 2 and player.clock % interval < aniTime * 3 then img = player.images.wing3 end
	currentStencil = masks.quarter
	love.graphics.stencil(setStencilMask, 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	love.graphics.draw(img, player.x + gameX, player.y + gameY, 0, 1, 1, player.images.wing1:getWidth() / 2, player.images.wing1:getHeight() / 2)
	love.graphics.setStencilTest()
end

function player.draw()
	local function drawPlayer()
		if controls.focus then drawBorder() end
		love.graphics.draw(player.currentImage(), player.x + gameX, player.y + gameY - 1, 0, 1, 1, player.currentImage():getWidth() / 2, player.currentImage():getHeight() / 2)
		drawWings()
		if controls.focus then
			currentStencil = masks.half
			love.graphics.stencil(setStencilMask, 'replace', 1)
			love.graphics.setStencilTest('greater', 0)
			love.graphics.draw(player.images.hitboxBottom, player.x + gameX - 1, player.y + gameY - 1, 0, 1, 1, player.images.hitbox:getWidth() / 2, player.images.hitbox:getHeight() / 2)
			love.graphics.setStencilTest()
			love.graphics.draw(player.images.hitbox, player.x + gameX, player.y + gameY, 0, 1, 1, player.images.hitbox:getWidth() / 2, player.images.hitbox:getHeight() / 2)
		end
		-- drawSides()
	end
	if player.invulnerableClock > 0 then
		if player.invulnerableClock < 60 * 3 then
			local interval = 30
			if player.invulnerableClock % interval < interval / 2 then drawPlayer() end
		end
	else drawPlayer() end
end

function player.drawBullets()
	currentStencil = masks.quarter
	love.graphics.stencil(setStencilMask, 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	for i, v in ipairs(player.bullets) do drawBullet(i) end
	love.graphics.setStencilTest()
end
