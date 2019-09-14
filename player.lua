player = {
	speed = 2,
	startingX = gameWidth / 2,
	startingY = gameHeight - grid * 2.5,
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
		bullet = love.graphics.newImage('img/player/bullet.png'),
		wing1 = love.graphics.newImage('img/player/wing1.png'),
		wing2 = love.graphics.newImage('img/player/wing2.png'),
		wing3 = love.graphics.newImage('img/player/wing3.png'),
		bomb1 = love.graphics.newImage('img/player/bomb1.png'),
		bomb2 = love.graphics.newImage('img/player/bomb2.png')
	},
	grazeSize = grid * 1.75,
	clock = 0,
	bullets = {},
	canShoot = true,
	shotClock = 0,
	invulnerableClock = 0,
	lives = 2,
	bombs = 3,
	bombing = false,
	bombClock = 0,
	bombLimit = 200,
	bombItems = {},
	bombAngle = 0,
	borderRotationA = 0,
	borderRotationB = 0,
	leftClock = 0,
	rightClock = 0,
	power = 0
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
	local bgMod = .065
	if controls.left then
		player.x = player.x - speed
		player.leftClock = player.leftClock + 1
		if player.x >= player.images.hitbox:getWidth() / 2 then background.middleOffset = background.middleOffset + bgMod end
	elseif controls.right then
		player.x = player.x + speed
		player.rightClock = player.rightClock + 1
		if player.x <= gameWidth - player.images.hitbox:getWidth() / 2 then background.middleOffset = background.middleOffset - bgMod end
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

local function spawnBullet(diff, hidden)
	local mod = math.pi / 13
	local size = 22
	local y = player.y
	local x = player.x
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
	if hidden then bullet.hidden = true end
	if controls.focus then bullet.timeSet = 2 end
	table.insert(player.bullets, bullet)
	sound.playSfx('playerbullet')
end

local function spawnBomb(opposite)
	sound.playSfx('bomb')
	local angle = player.bombAngle
	local count = 10
	for i = 1, count do
		local bomb = hc.circle(player.x, player.y, player.images.bomb1:getWidth() / 2)
		bomb.angle = angle
		bomb.image = player.images.bomb1
		bomb.clock = 0
		table.insert(player.bombItems, bomb)
		angle = angle + math.tau / count
	end
	player.bombAngle = player.bombAngle + math.pi / count * 5
end

local function updateBullet(index)
	local bullet = player.bullets[index]
	bullet.count = bullet.count + .5
	local angle = -math.pi / 2
	if bullet.angle then angle = bullet.angle end
	if not bullet.visible and bullet.clock >= bullet.timeSet then bullet.visible = true end
	bullet.clock = bullet.clock + 1
	local speed = grid
	bullet.x = bullet.x + math.cos(angle) * speed
	bullet.y = bullet.y + math.sin(angle) * speed
	bullet:moveTo(bullet.x, bullet.y)
	if bullet.y < -bullet.image:getHeight() / 2 then
		hc.remove(bullet)
		table.remove(player.bullets, index)
	elseif not bullet.hidden then
		collision.check(hc.collisions(bullet), 'enemy', function(enemy)
			if enemy.health <= 0 then
				if enemy.isBoss then
					for i = 1, 5 do
						drops.spawnPoint({x = (enemy.x - grid * 3) + grid * 6 * math.random(), y = enemy.y})
					end
				else drops.spawnPoint(enemy) end
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
			local diff = math.pi / 9
			if controls.focus then
				diff = math.pi / 30
			end
			spawnBullet(diff, true)
			spawnBullet(diff)
			spawnBullet(-diff)
			for i = 1, player.power do
				spawnBullet(diff * (i * 2 + 1))
				spawnBullet(-diff * (i * 2 + 1))
			end
		end
		player.shotClock = player.shotClock + 1
	end
	if player.shotClock >= max then player.canShoot = true end
	for i, v in ipairs(player.bullets) do updateBullet(i) end
end

local function updateBomb(index)
	local bomb = player.bombItems[index]
	local x, y = bomb:center()
	local speed = 3
	local animateInterval = 20
	if bomb.clock % animateInterval < animateInterval / 2 then
		bomb.image = player.images.bomb1
	else
		bomb.image = player.images.bomb2
	end
	bomb.clock = bomb.clock + 1
	bomb:moveTo(x + math.cos(bomb.angle) * speed, y + math.sin(bomb.angle) * speed)
	if x >= gameWidth + bomb.image:getWidth() / 2 then
		hc.remove(bomb)
		table.remove(player.bombItems, index)
	else
		collision.check(hc.collisions(bomb), 'enemy', function(enemy)
			if enemy.health <= 0 then
				explosions.spawn({x = enemy.x, y = enemy.y}, false, true)
				if enemy.suicide then enemy.suicide() end
				enemy.x = -gameWidth
				enemy.y = -gameHeight
			else
				explosions.spawn({x = enemy.x, y = enemy.y})
				if enemy.isBoss then enemy.health = enemy.health - .2
				else enemy.health = enemy.health - 1 end
			end
		end)
		collision.check(hc.collisions(bomb), 'bullet', function(bullet)
			explosions.spawn({x = bullet.x, y = bullet.y})
			bullet.x = -gameWidth
			bullet.y = -gameHeight
		end)
	end
end

local function updateBombing()
	if player.bombing then
		local interval = 15
		if player.bombClock % interval == 0 then spawnBomb(player.bombClock % (interval * 2) == interval) end
		player.bombClock = player.bombClock + 1
		if player.bombClock >= player.bombLimit then
			player.bombClock = 0
			player.bombing = false
		end
	elseif controls.bomb and player.bombs > 0 then
		player.bombing = true
		player.bombs = player.bombs - 1
	end
	for i, v in ipairs(player.bombItems) do updateBomb(i) end
end

function player.update()
	updateMove()
	updateShoot()
	updateBombing()
	player.clock = player.clock + 1
	if player.invulnerableClock > 0 then
		if player.invulnerableClock > 60 * 3 then
			player.x = player.startingX
			player.y = player.startingY
			if player.clock % 15 == 0 and player.dieX then explosions.spawn({x = player.dieX, y = player.dieY}, true, true, false, false, true) end
		end
		player.invulnerableClock = player.invulnerableClock - 1
	end
end

local function drawBorder()
	startStencil('quarter')
	love.graphics.setColor(colors.grayLight)
	love.graphics.draw(player.images.border, player.x + gameX, player.y + gameY, player.borderRotationA, 1, 1, player.images.border:getWidth() / 2, player.images.border:getHeight() / 2)
	love.graphics.draw(player.images.border, player.x + gameX, player.y + gameY, player.borderRotationB, 1, 1, player.images.border:getWidth() / 2, player.images.border:getHeight() / 2)
	love.graphics.setColor(colors.white)
	endStencil()
end

local playerScale = .8

local function drawWings()
	local img = player.images.wing1
	local interval = aniTime * 4
	if (player.clock % interval >= aniTime and player.clock % interval < aniTime * 2) or (player.clock % interval >= aniTime * 3) then img = player.images.wing2
	elseif player.clock % interval >= aniTime * 2 and player.clock % interval < aniTime * 3 then img = player.images.wing3 end
	startStencil('half')
	love.graphics.draw(img, player.x + gameX, player.y + gameY, 0, playerScale, playerScale, player.images.wing1:getWidth() / 2, player.images.wing1:getHeight() / 2)
	endStencil()
end

local function drawBullet(index)
	local bullet = player.bullets[index]
	if bullet.visible and not bullet.hidden then
		love.graphics.draw(bullet.image, bullet.x + gameX, bullet.y + gameY, bullet.rotation, 1, 1, bullet.image:getWidth() / 2, bullet.image:getHeight() / 2)
	end
end

function player.drawBullets()
	startStencil('half')
	for i, v in ipairs(player.bullets) do drawBullet(i) end
	endStencil()
end

local function drawBomb(index)
	local bomb = player.bombItems[index]
	local x, y = bomb:center()
	love.graphics.draw(bomb.image, x, y, bomb.angle, 1, 1, bomb.image:getWidth() / 2, bomb.image:getHeight() / 2)
end

local function drawBombs()
	startStencil('half')
	for i, v in ipairs(player.bombItems) do drawBomb(i) end
	endStencil()
end

function player.draw()
	local function drawPlayer()
		drawBombs()
		if controls.focus then drawBorder() end
		love.graphics.draw(player.currentImage(), player.x + gameX, player.y + gameY - 1, 0, playerScale, playerScale, player.currentImage():getWidth() / 2, player.currentImage():getHeight() / 2)
		drawWings()
		if controls.focus then
			startStencil('half')
			love.graphics.draw(player.images.hitboxBottom, player.x + gameX - 1, player.y + gameY - 1, 0, 1, 1, player.images.hitbox:getWidth() / 2, player.images.hitbox:getHeight() / 2)
			endStencil()
			love.graphics.draw(player.images.hitbox, player.x + gameX, player.y + gameY, 0, 1, 1, player.images.hitbox:getWidth() / 2, player.images.hitbox:getHeight() / 2)
		end
	end
	if player.invulnerableClock > 0 then
		if player.invulnerableClock < 60 * 3 then
			local interval = 30
			if player.invulnerableClock % interval < interval / 2 then drawPlayer() end
		end
	else drawPlayer() end
end
