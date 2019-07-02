player = {
	speed = 4,
	startingX = gameWidth / 2,
	startingY = gameHeight - grid * 4,
	images = {
		idle1 = love.graphics.newImage('img/player/marisa-idle-1.png'),
		idle2 = love.graphics.newImage('img/player/marisa-idle-2.png'),
		idle3 = love.graphics.newImage('img/player/marisa-idle-3.png'),
		left1 = love.graphics.newImage('img/player/marisa-left-1.png'),
		left2 = love.graphics.newImage('img/player/marisa-left-2.png'),
		right1 = love.graphics.newImage('img/player/marisa-right-1.png'),
		right2 = love.graphics.newImage('img/player/marisa-right-2.png'),
		hitbox = love.graphics.newImage('img/player/hitbox.png'),
		bulletMarisa = love.graphics.newImage('img/player/bullet-marisa.png'),
		sideMarisa = love.graphics.newImage('img/player/marisa-side.png')
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
	laserHeight = 0,
	laserY = 0,
	sideOffset = grid * 1.75
}

function player.load()
	for type, img in pairs(player.images) do
		player.images[type]:setFilter('nearest', 'nearest')
		player.images[type]:setWrap('repeat', 'repeat')
	end
	player.x = player.startingX
	player.y = player.startingY
	player.collider = hc.circle(player.x, player.y, 0)
	player.grazeCollider = hc.circle(player.x, player.y, player.grazeSize)
end

function player.currentImage()
	local img = player.images.idle1
	local interval = aniTime * 4
	if (player.clock % interval >= aniTime and player.clock % interval < aniTime * 2) or player.clock % interval >= aniTime * 3 then img = player.images.idle2
	elseif player.clock % interval >= aniTime * 2 and player.clock % interval < aniTime * 3 then img = player.images.idle3 end
	return img
end

local function spawnBullet(diff, yOffset)
	local mod = math.pi / 15
	local size = 22
	local y = player.y - grid
	local x = player.x + gameX
	if yOffset then y = y + yOffset * 10 end
	if player.hitboxVisible then
		x = x + 8
		if yOffset then x = x - 4 * math.abs(yOffset) end
	end
	local bullet = hc.circle(x, y, size / 2)
	bullet.image = player.images.bulletMarisa
	local angle = -math.pi / 2
	bullet.angle = angle + diff * mod
	bullet.rotation = angle + diff * mod
	bullet.diff = .1
	bullet.initial = 0
	bullet.count = 0
	table.insert(player.bullets, bullet)
end

local function updateBullet(index)
	local bullet = player.bullets[index]
	local x, y = bullet:center()
	local xOff = math.cos(bullet.count) * bullet.diff
	local yOff = math.sin(bullet.count) * bullet.diff
	bullet.count = bullet.count + .5
	x = x + (math.cos(bullet.angle) + 0) * player.bulletSpeed
	y = y + (math.sin(bullet.angle) + yOff) * player.bulletSpeed
	bullet:moveTo(x, y)
	if y < -bullet.image:getHeight() / 2 then
		hc.remove(bullet)
		table.remove(player.bullets, index)
	else
		collision.check(hc.collisions(bullet), 'enemy', function(enemy)
			local x, y = enemy:center()
			if enemy.health <= 0 then
				explosions.spawn({x = x, y = y}, false, true, true)
				enemy:moveTo(-gameWidth, - gameHeight)
				player.score = player.score + .1
			else
				explosions.spawn({x = x, y = y}, false, false, true)
				if enemy and (enemy.health) then enemy.health = enemy.health - 1 end
			end
			bullet:moveTo(gameWidth * 3, gameHeight / 2)
		end)
	end
end

local function updateMove()
	local speed = player.speed
	if controls.focus then speed = 2 end

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

			-- marisa b
			-- spawnBullet(0)
			spawnBullet(.25)
			spawnBullet(-.25)

			-- if controls.focus then
			-- 	spawnBullet(0, -1)
			-- 	spawnBullet(0, -2)
			-- 	spawnBullet(0, 1)
			-- 	spawnBullet(0, 2)
			-- else
			-- 	spawnBullet(-2)
			-- 	spawnBullet(-1)
			-- 	spawnBullet(1)
			-- 	spawnBullet(2)
			-- end

		end
		player.shotClock = player.shotClock + 1
	end
	if player.shotClock >= max then player.canShoot = true end
	for i, v in ipairs(player.bullets) do updateBullet(i) end
end

local function updateLaser()
	if controls.shoot then
		local max = gameY + player.y - grid
		if player.laserHeight < max then player.laserHeight = player.laserHeight + 32 end
		if player.laserHeight > max then player.laserHeight = max end
		player.laserY = gameY + max - player.laserHeight
	else player.laserHeight = 0 end
end

function player.update()
	updateMove()
	updateShoot()
	updateLaser()
	player.clock = player.clock + 1
end

local function drawBullet(index)
	local bullet = player.bullets[index]
	local x, y = bullet:center()
	love.graphics.setStencilTest('greater', 0)
	love.graphics.draw(bullet.image, x, y, bullet.rotation, 1, 1, bullet.image:getWidth() / 2, bullet.image:getHeight() / 2)
	love.graphics.setStencilTest()
end

local function drawLaser()
	local laserWidth = 6
	love.graphics.setStencilTest('greater', 0)
	love.graphics.setColor(colors.blueLight)
	love.graphics.rectangle('fill', gameX + player.x - player.sideOffset - 3, player.laserY, laserWidth, player.laserHeight)
	love.graphics.rectangle('fill', gameX + player.x + player.sideOffset - 4, player.laserY, laserWidth, player.laserHeight)
	love.graphics.setColor(colors.light)
	love.graphics.rectangle('fill', gameX + player.x - player.sideOffset - 1, player.laserY, laserWidth - 4, player.laserHeight)
	love.graphics.rectangle('fill', gameX + player.x + player.sideOffset - 2, player.laserY, laserWidth - 4, player.laserHeight)
	love.graphics.setColor(colors.white)
	love.graphics.setStencilTest()
end

function player.draw()
	for i, v in ipairs(player.bullets) do drawBullet(i) end
	love.graphics.draw(player.currentImage(), player.x + gameX, player.y + gameY - 1, 0, 1, 1, player.currentImage():getWidth() / 2, player.currentImage():getHeight() / 2)

	if controls.shoot then drawLaser() end

	love.graphics.draw(player.images.sideMarisa, player.x + gameX - player.sideOffset, player.y + gameY - 1, 0, 1, 1, player.images.sideMarisa:getWidth() / 2, player.images.sideMarisa:getHeight() / 2)
	love.graphics.draw(player.images.sideMarisa, player.x + gameX + player.sideOffset - 1, player.y + gameY - 1, 0, 1, 1, player.images.sideMarisa:getWidth() / 2, player.images.sideMarisa:getHeight() / 2)

	if controls.focus then love.graphics.draw(player.images.hitbox, player.x + gameX, player.y + gameY, 0, 1, 1, player.images.hitbox:getWidth() / 2, player.images.hitbox:getHeight() / 2) end
end
