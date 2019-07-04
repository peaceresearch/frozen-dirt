enemies = {}

local function enemyObj(func)
	return {
		clock = 0,
		func = func
	}
end

enemies.one = enemyObj(function()

	local attacks = {

		-- function(enemy)
		-- 	local function burst()
		-- 		local function spawnBullet()
		-- 			stage.spawnBullet('red', enemy.x, enemy.y, function(bullet)
		-- 				bullet.speed = 6
		-- 				bullet.angle = math.pi * math.random()
		-- 			end, function(bullet)
		-- 				if bullet.speed > 3 then
		-- 					bullet.velocity = {
		-- 						x = math.cos(bullet.angle) * (bullet.speed * .75),
		-- 						y = math.sin(bullet.angle) * bullet.speed
		-- 					}
		-- 					bullet.speed = bullet.speed - .1
		-- 				end
		-- 			end)
		-- 		end
		-- 		local limit = 5
		-- 		local max = limit * 3
		-- 		if enemy.clock % max < limit then
		-- 			spawnBullet()
		-- 			spawnBullet()
		-- 		end
		-- 	end
		-- 	local function lasers()
		-- 		local function laser(speedOffset, opposite, bulletOpposite)
		-- 			local offset = grid * 8
		-- 			local x = enemy.x - offset
		-- 			local bulletMod = math.pi / 4
		-- 			local angle = math.pi / 2 - bulletMod
		-- 			if opposite then
		-- 				x = enemy.x + offset
		-- 			end
		-- 			for i = 1, 3 do
		-- 				stage.spawnBullet('bluebig', x, enemy.y, function(bullet)
		-- 					bullet.angle = angle
		-- 					bullet.speed = 3 + speedOffset / 4
		-- 					if bulletOpposite then bullet.opposite = true end
		-- 				end, function(bullet)
		-- 					bullet.velocity = {
		-- 						x = math.cos(bullet.angle) * bullet.speed,
		-- 						y = math.sin(bullet.angle) * bullet.speed
		-- 					}
		-- 					local mod = .01
		-- 					if bullet.opposite then mod = mod * -1 end
		-- 					bullet.angle = bullet.angle + mod
		-- 				end)
		-- 				angle = angle + bulletMod
		-- 			end
		-- 		end
		-- 		local interval = 5
		-- 		local limit = interval * 5
		-- 		local max = limit * 3
		-- 		if enemy.clock % interval == 0 and enemy.clock % max < limit then
		-- 			laser(enemy.clock % max / interval, false, enemy.clock % (max * 2) < max)
		-- 			laser(enemy.clock % max / interval, true, enemy.clock % (max * 2) >= max)
		-- 		end
		-- 	end
		-- 	burst()
		-- 	lasers()
		-- end,

		-- function(enemy)
		-- 	local function spawnBullets(opposite, other)
		-- 		local angle = enemy.bulletAngleA
		-- 		local x = enemy.x - grid * 8
		-- 		local img = 'redarrow'
		-- 		if other then
		-- 			angle = enemy.bulletAngleB
		-- 			x = enemy.x + grid * 8
		-- 			img = 'bluearrow'
		-- 		end
		-- 		local mod = math.pi / 15
		-- 		angle = angle - mod * math.floor(enemy.bulletCount / 2)
		-- 		if opposite then angle = angle + mod / 2 end
		-- 		for i = 1, enemy.bulletCount do
		-- 			stage.spawnBullet(img, x, enemy.y, function(bullet)
		-- 				bullet.rotation = angle
		-- 				bullet.angle = angle
		-- 				bullet.speed = 5
		-- 			end, function(bullet)
		-- 				if bullet.speed > 1.75 then
		-- 					bullet.velocity = {
		-- 						x = math.cos(bullet.angle) * bullet.speed,
		-- 						y = math.sin(bullet.angle) * bullet.speed
		-- 					}
		-- 					bullet.speed = bullet.speed - .033
		-- 				end
		-- 			end)
		-- 			angle = angle + mod
		-- 		end
		-- 		if enemy.bulletCount < 15 then enemy.bulletCount = enemy.bulletCount + 1 end
		-- 	end
		-- 	if enemy.clock == 0 then
		-- 		enemy.bulletCount = 5
		-- 		enemy.bulletAngleA = getAngle({x = enemy.x - grid * 8, y = enemy.y}, {x = gameWidth, y = gameHeight})
		-- 		enemy.bulletAngleB = getAngle({x = enemy.x + grid * 8, y = enemy.y}, {x = 0, y = gameHeight})
		-- 	end
		-- 	local interval = 25
		-- 	if enemy.clock % interval == 0 and enemy.bulletAngleA then
		-- 		spawnBullets(enemy.clock % (interval * 2) == 0)
		-- 		spawnBullets(enemy.clock % (interval * 2) == 0, true)
		-- 	end
		-- end,

		-- function(enemy)
		-- 	local function spawnCenter()
		-- 		local function triangle()
		-- 			local count = 5
		-- 			local angle = enemy.bulletAngle
		-- 			local speed = 3
		-- 			for i = 1, count do
		-- 				local bulletCount = 3
		-- 				for j = 1, bulletCount do
		-- 					local index = j - count
		-- 					local diff = 16
		-- 					local bulletAngle = angle + math.pi / 2
		-- 					local x = enemy.x + math.cos(bulletAngle) * index * diff
		-- 					local y = enemy.y + math.sin(bulletAngle) * index * diff
		-- 					stage.spawnBullet('bluearrow', x, y, function(bullet)
		-- 						-- bullet.visible = false
		-- 						bullet.velocity = {
		-- 							x = math.cos(angle) * speed,
		-- 							y = math.sin(angle) * speed
		-- 						}
		-- 						bullet.rotation = angle
		-- 					end, function(bullet)
		-- 						-- if bullet.clock >= 15 and not bullet.visible then bullet.visible = true end
		-- 					end)
		-- 				end
		-- 				angle = angle + math.tau / count
		-- 			end
		-- 		end
		-- 		local interval = 25
		-- 		local shotInterval = 5
		-- 		local limit = shotInterval * 5
		-- 		local mod = math.pi / 8
		-- 		if enemy.clock == 0 then enemy.bulletAngle = math.pi - mod end
		-- 		if enemy.clock % interval < limit and enemy.clock % shotInterval == 0 then
		-- 			if enemy.clock % interval == 0 and enemy.bulletAngle then
		-- 				enemy.bulletAngle = enemy.bulletAngle + mod
		-- 			end
		-- 			if enemy.bulletAngle then triangle() end
		-- 		end
		-- 	end
		-- 	local function spawnSides()
		-- 		local function spawnBullets(offset)
		-- 			local function spawnBullet(opposite, other)
		-- 				local x = enemy.x + grid * 8
		-- 				local y = enemy.y
		-- 				if other then x = enemy.x - grid * 8 end
		-- 				local speed = 3
		-- 				local target = {x = enemy.bulletTarget, y = gameHeight}
		-- 				if opposite then target = {x = enemy.bulletTarget + gameWidth, y = gameHeight} end
		-- 				target.x = target.x + offset * (grid * 4)
		-- 				local angle = getAngle(enemy, target)
		-- 				stage.spawnBullet('red', x, y, function(bullet)
		-- 					bullet.velocity = {
		-- 						x = math.cos(angle) * speed,
		-- 						y = math.sin(angle) * speed
		-- 					}
		-- 				end)
		-- 			end
		-- 			spawnBullet()
		-- 			spawnBullet(true)
		-- 			spawnBullet(false, true)
		-- 			spawnBullet(true, true)
		-- 		end
		-- 		if enemy.clock == 0 then
		-- 			enemy.bulletTarget = 0
		-- 			enemy.bulletInitial = enemy.bulletTarget
		-- 			enemy.bulletCount = 2
		-- 		end
		-- 		local interval = 8
		-- 		local limit = interval * 6
		-- 		local max = limit * 2
		-- 		if enemy.clock % interval == 0 and enemy.clock % max < limit and enemy.bulletInitial then
		-- 			if enemy.startedBullets then
		-- 				spawnBullets(-1)
		-- 				spawnBullets(1)
		-- 			end
		-- 			local offset = math.cos(enemy.bulletCount) * (grid * 3)
		-- 			enemy.bulletTarget = enemy.bulletInitial - offset
		-- 			enemy.bulletCount = enemy.bulletCount + 1
		-- 			if not enemy.startedBullets then enemy.startedBullets = true end
		-- 		end
		-- 	end
		-- 	spawnCenter()
		-- 	spawnSides()
		-- end,

		-- function(enemy)
		-- 	local function arrows()
		-- 		local function spawnBullets()
		-- 			local angle = enemy.bulletAngle
		-- 			local speed = 3
		-- 			stage.spawnBullet('redarrow', enemy.x, enemy.y, function(bullet)
		-- 				bullet.velocity = {
		-- 					x = math.cos(angle) * speed,
		-- 					y = math.sin(angle) * speed
		-- 				}
		-- 				bullet.rotation = angle
		-- 			end)
		-- 		end
		-- 		local interval = 5
		-- 		local limit = interval * 20
		-- 		local max = limit * 2.5
		-- 		if enemy.clock % interval == 0 and enemy.clock % max < limit then
		-- 			if enemy.clock % max == 0 then
		-- 				local mod = .6
		-- 				enemy.bulletAngle = getAngle(enemy, player)
		-- 				enemy.bulletAngleMin = enemy.bulletAngle - mod
		-- 				enemy.bulletAngleMax = enemy.bulletAngle + mod
		-- 				enemy.bulletDirection = true
		-- 			end
		-- 			if enemy.bulletAngle then spawnBullets() end
		-- 			local diff = 0.3
		-- 			if enemy.bulletAngle and enemy.bulletAngleMin and enemy.bulletAngleMax then
		-- 				if enemy.bulletDirection then diff = diff * -1 end
		-- 				if enemy.bulletDirection and enemy.bulletAngle <= enemy.bulletAngleMin then enemy.bulletDirection = false
		-- 				elseif enemy.bulletAngle >= enemy.bulletAngleMax then enemy.bulletDirection = true end
		-- 				enemy.bulletAngle = enemy.bulletAngle + diff
		-- 			end
		-- 		end
		-- 	end
		-- 	local function ring()
		-- 		local function spawnBullets(opposite)
		-- 			local count = 25
		-- 			local angle = enemy.ringAngle
		-- 			local x = enemy.x - grid * 8
		-- 			if opposite then x = enemy.x + grid * 8 end
		-- 			for i = 1, count do
		-- 				stage.spawnBullet('bluebig', x, enemy.y, function(bullet)
		-- 					bullet.speed = 5
		-- 					bullet.angle = angle
		-- 				end, function(bullet)
		-- 					if bullet.speed > 2 then
		-- 						bullet.velocity = {
		-- 							x = math.cos(bullet.angle) * bullet.speed,
		-- 							y = math.sin(bullet.angle) * bullet.speed
		-- 						}
		-- 						bullet.speed = bullet.speed - .1
		-- 					end
		-- 				end)
		-- 				angle = angle + math.tau / count
		-- 			end
		-- 			local mod = 0.05
		-- 			if opposite then mod = mod * -1 end
		-- 			enemy.ringAngle = enemy.ringAngle + mod
		-- 		end
		-- 		local interval = 60
		-- 		if enemy.clock == 0 then enemy.ringAngle = 0 end
		-- 		if enemy.clock % interval == 0 and enemy.ringAngle then
		-- 			spawnBullets()
		-- 			spawnBullets(true)
		-- 		end
		-- 	end
		-- 	arrows()
		-- 	ring()
		-- end,

		function(enemy)
		end

	}

	local function spawnEnemy()
		stage.spawnEnemy('chen', gameWidth / 2, -stage.enemyImages.chen.idle1:getHeight() / 2, function(enemy)
			enemy.angle = math.pi / 2
			enemy.speed = 3
			enemy.currentAttack = 1
			enemy.health = 200
			bossHealthInit = enemy.health
		end, function(enemy)
			if enemy.speed > 0 then
				enemy.speed = enemy.speed - .05
				enemy.clock = -1
			end
			if enemy.speed < 0 then
				enemy.speed = 0
				enemy.clock = -1
				enemy.y = math.floor(enemy.y)
			end
			enemy.velocity = {
				x = math.cos(enemy.angle) * enemy.speed,
				y = math.sin(enemy.angle) * enemy.speed
			}
			if enemy.clock >= 0 then attacks[enemy.currentAttack](enemy) end
			bossHealth = enemy.health
		end)
	end
	if currentWave.clock == 0 then spawnEnemy() end

end)
