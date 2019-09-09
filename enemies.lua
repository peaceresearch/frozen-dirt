enemies = {}

-- 9 sections with 4 spells each is 36. 9 with 5 is 45
-- maybe would be cool if last 3 were longer, so like 4 spells for 1-6, 5 for 7-9. maybe even 6.

local function enemyObj(func)
	return {
		clock = 0,
		func = func
	}
end

local function sideSideMove(enemy, fast)
	if not enemy.initial then
		enemy.initial = math.pi / 2
		enemy.angle = enemy.initial
		enemy.count = 0
	end
	local speed = .5
	if fast then
		speed = 2.5
		enemy.angle = enemy.initial + math.cos(enemy.count / 2)
	else
		enemy.angle = enemy.initial + math.cos(enemy.count / 10)
	end
		enemy.count = enemy.count + 0.1
		enemy.velocity = {
			x = math.cos(enemy.angle) * speed,
			y = 0
		}
end

function returnToCenter(enemy)
	enemy.initial = math.pi / 2
	enemy.angle = enemy.initial
	enemy.count = 0
	local limit = gameWidth / 2
	if enemy.clock == 0 then
		enemy.xDirection = false
		local speedLimit = .25
		if enemy.velocity.x < 0 and enemy.velocity.x > -speedLimit then enemy.velocity.x = -speedLimit
		elseif enemy.velocity.x > 0 and enemy.velocity.x < speedLimit then enemy.velocity.x = speedLimit end
		if enemy.x < limit then enemy.xDirection = 'right'
		elseif enemy.x > limit then enemy.xDirection = 'left' end
	end
	if enemy.xDirection == 'right' then
		if enemy.x > limit then enemy.velocity.x = 0
		elseif enemy.velocity.x < 0 then enemy.velocity.x = -enemy.velocity.x end
	elseif enemy.xDirection == 'left' then
		if enemy.x < limit then enemy.velocity.x = 0
		elseif enemy.velocity.x > 0 then enemy.velocity.x = -enemy.velocity.x end
	end
end

local function spawnSecond(enemy, func)
	local interval = 240
	if enemy.clock % (interval * 2) >= interval then func() end
end


-- STAGE 1
enemies.stageOneWaveOne = enemyObj(function()
	local function spawnBullets(enemy)
		local speed = 1.5
		local mod = math.pi / 9
		local angle = getAngle(enemy, player) - mod
		for i = 1, 3 do
			stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
			end)
			angle = angle + mod
		end
	end
	local function spawnEnemy(x, opposite)
		stage.spawnEnemy('fairyred', x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
			enemy.angle = math.pi / 2
			enemy.speed = .75
			enemy.health = 2
			if opposite then enemy.opposite = true end
		end, function(enemy)
			enemy.velocity = {
				x = math.cos(enemy.angle) * enemy.speed,
				y = math.sin(enemy.angle) * enemy.speed
			}
			local limit = 190
			local mod = 90
			local angleMod = .025
			if enemy.opposite then angleMod = angleMod * -1 end
			if enemy.clock >= limit and enemy.clock < limit + mod then enemy.angle = enemy.angle + angleMod end
			if enemy.clock == 45 then spawnBullets(enemy) end
		end)
	end
	local interval = 45
	local limit = interval * 8
	local limitMod = 60
	if currentWave.clock % interval == 0 and currentWave.clock < limit then
		spawnEnemy(gameWidth / 3)
		spawnEnemy(gameWidth / 3 * 2)
	end
	if currentWave.clock % interval == 0 and currentWave.clock >= limit + limitMod and currentWave.clock < limit * 2 + limitMod then
		spawnEnemy(gameWidth / 5, true)
		spawnEnemy(gameWidth - gameWidth / 5)
	end
	if currentWave.clock >= limit * 2.5 then
		currentWave = enemies.stageOneWaveTwo
		currentWave.clock = -1
	end
end)

enemies.stageOneWaveTwo = enemyObj(function()
	local function sprayerGroup(opposite)
		local function spawnBullets(enemy)
			local angle = enemy.bulletAngle
			local count = 5
			for i = 1, count do
				stage.spawnBullet('big', enemy.x, enemy.y, function(bullet)
					bullet.speed = 3
					bullet.angle = angle
				end, function(bullet)
					if bullet.speed > 1.25 then
						bullet.speed = bullet.speed - .05
						bullet.velocity = {
							x = math.cos(bullet.angle) * bullet.speed,
							y = math.sin(bullet.angle) * bullet.speed
						}
					end
				end)
				angle = angle + math.tau / count
			end
			local angleMod = math.pi / 5
			if opposite then angleMod = angleMod * -1 end
			enemy.bulletAngle = enemy.bulletAngle + angleMod
		end
		local function spawnEnemy(x)
			stage.spawnEnemy('fairygreen', x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
				enemy.angle = math.pi / 2
				enemy.speed = 2.5
				enemy.health = 4
				enemy.bulletAngle = math.pi * math.random()
			end, function(enemy)
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
				local limit = .5
				if enemy.speed > limit then
					enemy.speed = enemy.speed - .05
					enemy.clock = -1
				elseif enemy.speed <= limit then
					enemy.speed = limit
					local interval = 30
					if enemy.clock % interval == 0 and enemy.y < gameHeight / 3 then spawnBullets(enemy) end
				end
			end)
		end
		local baseX = gameWidth / 4 * 3
		local offset = grid * 2
		local baseTime = 0
		if opposite then
			baseTime = 60 * 5.25
			baseX = gameWidth / 4
		end
		if currentWave.clock == baseTime then spawnEnemy(baseX)
		elseif currentWave.clock == baseTime + 60 then
			spawnEnemy(baseX - offset)
			spawnEnemy(baseX + offset)
		end
	end
	local function laser(laserOpposite)
		local function spawnBullet(enemy, opposite)
			local angle = enemy.bulletAngle
			local offset = grid
			local offsetAngle = angle + math.pi / 2
			if opposite then offsetAngle = offsetAngle + math.pi end
			local x = enemy.bulletPos.x + math.cos(offsetAngle) * offset
			local y = enemy.bulletPos.y + math.sin(offsetAngle) * offset
			local speed = 2
			stage.spawnBullet('arrow', x, y, function(bullet)
				bullet.rotation = angle
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
			end)
		end
		local function spawnEnemy()
			local x = gameWidth / 4
			if laserOpposite then x = gameWidth / 4 * 3 end
			stage.spawnEnemy('fairyyellow', x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
				enemy.angle = math.pi / 2
				enemy.speed = 2.5
				enemy.health = 7
			end, function(enemy)
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
				local limit = .5
				if enemy.speed > limit then
					enemy.speed = enemy.speed - .05
					enemy.clock = -1
				elseif enemy.speed <= limit then
					enemy.speed = limit
					local interval = 15
					local limit = interval * 4
					local max = limit * 2
					if enemy.clock % interval == 0 and enemy.clock % max < limit and enemy.clock < max * 2 then
						if enemy.clock % max == 0 then
							enemy.bulletPos = {x = enemy.x, y = enemy.y + grid}
							enemy.bulletAngle = getAngle(enemy.bulletPos, player)
						end
						spawnBullet(enemy)
						spawnBullet(enemy, true)
					end
				end
			end)
		end
		local baseTime = 180
		if laserOpposite then baseTime = baseTime + 60 * 5.25 end
		if currentWave.clock == baseTime then spawnEnemy() end
	end
	sprayerGroup()
	sprayerGroup(true)
	laser()
	laser(true)
	if currentWave.clock == 60 * 12 then
		currentWave = enemies.stageOneWaveThree
		currentWave.clock = -1
	end
end)

enemies.stageOneWaveThree = enemyObj(function()
	local function spawnBullets(enemy, dir)
		local count = 21
		local angle = enemy.bulletAngle
		local speed = 1.75
		for i = 0, count do
			stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				if i == 0 or i > count / 2 then bullet.visible = false end
			end)
			if i > 0 then angle = angle + math.tau / count end
		end
		local mod = .05
		if dir then mod = mod * -1 end
		enemy.bulletAngle = enemy.bulletAngle + mod
	end
	local function spawnEnemy()
		stage.spawnEnemy('fairyred', gameWidth / 2, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
			enemy.angle = math.pi / 2
			enemy.speed = 1.5
			enemy.health = 40
		end, function(enemy)
			if enemy.speed > .25 then
				enemy.speed = enemy.speed - .015
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
				enemy.clock = -1
			else
				local interval = 15
				local limit = interval * 4
				local max = limit * 1.5
				if enemy.clock % interval == 0 and enemy.clock % max < limit and enemy.clock < max * 4 then
					if enemy.clock % max == 0 then
						enemy.bulletAngle = getAngle(enemy, player) - math.pi / 2
						enemy.bulletPos = {x = enemy.x, y = enemy.y}
					end
					spawnBullets(enemy, enemy.clock >= max and enemy.clock < max * 2)
				end
			end
		end)
	end
	if currentWave.clock == 0 then spawnEnemy() end
	prepForBoss('stageOneBoss')
end)

enemies.stageOneBoss = enemyObj(function()

	local attacks = {
		function(enemy)
			local function lasers()
				local function spawnBullet(x, angle)
					local mod = .015
					angle = angle - mod
					angle = angle + mod * 2 * math.random()
					local speed = 2
					stage.spawnBullet('arrow', x, enemy.y, function(bullet)
						bullet.rotation = angle
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
					end)
				end
				local interval = 15
				local limit = interval * 4
				local max = limit * 2.5
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						enemy.bulletAngleA = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player)
						enemy.bulletAngleB = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player)
						explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
						explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
					end
					spawnBullet(enemy.x - bossOffset, enemy.bulletAngleA)
					spawnBullet(enemy.x + bossOffset, enemy.bulletAngleB)
				end
			end
			local function spray()
				local function spawnBullets(x)
					local count = 15
					local angle = -math.pi / 2
					for i = 1, count do
						if angle > math.pi / 10 and angle < math.pi - math.pi / 10 then
							stage.spawnBullet('biglight', x, enemy.y, function(bullet)
								bullet.angle = angle
								bullet.speed = 3
							end, function(bullet)
								if bullet.speed > 1.25 then
									bullet.velocity = {
										x = math.cos(bullet.angle) * bullet.speed,
										y = math.sin(bullet.angle) * bullet.speed
									}
									bullet.speed = bullet.speed - .05
								end
							end)
						end
						angle = angle + math.tau / count
					end
				end
				local interval = 90
				if enemy.clock % interval == 0 then
					spawnBullets(enemy.x - bossOffset)
					spawnBullets(enemy.x + bossOffset)
				end
			end
			lasers()
			spawnSecond(enemy, spray)
		end,
		function(enemy)
			local function snow()
				local function spawnBullet(x)
					local diff = math.pi / 10
					stage.spawnBullet('bullet', x, enemy.y, function(bullet)
						local speed = 2
						local angle = math.pi - diff
						angle = angle - (math.pi - diff * 2) * math.random()
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.rotation = angle
					end)
				end
				local interval = 6
				if enemy.clock % interval == 0 then
					spawnBullet(enemy.x - bossOffset)
					spawnBullet(enemy.x + bossOffset)
					local explosionInterval = 2
					if enemy.clock % (interval * explosionInterval) == 0 then
						local explosionX = enemy.x - bossOffset
						if enemy.clock % (interval * (explosionInterval * 2)) == 0 then explosionX = enemy.x + bossOffset end
						explosions.spawn({x = explosionX, y = enemy.y}, true, true)
					end
				end
			end
			local function lasers()
				local function spawnBullet(x)
					local diff = math.pi / 6
					stage.spawnBullet('boltlight', x, enemy.y, function(bullet)
						local speed = 4
						local angle = math.pi / 2
						local mod = math.pi / 60
						angle = angle - mod + mod * 2 * math.random()
						bullet.rotation = angle
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
					end)
				end
				local interval = 6
				if enemy.clock % interval == 0 then
					local diff = 3
					spawnBullet(enemy.x - bossOffset - diff)
					spawnBullet(enemy.x - bossOffset + diff)
					spawnBullet(enemy.x + bossOffset - diff)
					spawnBullet(enemy.x + bossOffset + diff)
				end
			end
			snow()
			spawnSecond(enemy, lasers)
		end
	}
	local moves = {}
	if currentWave.clock == 0 then
		spawnBoss('cirno', attacks, moves, function()
			stage.killBullets = true
			clearedStageClock = clearedStageLimit
			currentWave = enemies.stageTwoWaveOne
			currentWave.clock = -clearedStageLimit
		end, function(enemy)
			sideSideMove(enemy)
		end)
	end

end)


-- STAGE 2
enemies.stageTwoWaveOne = enemyObj(function()
	local function spawnBullet(enemy)
		local angle = getAngle(enemy, player)
		local speed = 1.65
		stage.spawnBullet('big', enemy.x, enemy.y, function(bullet)
			bullet.velocity = {
				x = math.cos(angle) * speed,
				y = math.sin(angle) * speed
			}
		end)
	end
	local function spawnEnemy(opposite)
		local x = -stage.enemyImages.fairyred.idle1:getWidth() / 2
		local y = grid * 2.5
		if opposite then
			x = gameWidth + stage.enemyImages.fairyred.idle1:getWidth() / 2
			y = grid * 6.5
		end
		local img = 'fairyred'
		if opposite then img = 'fairygreen' end
		stage.spawnEnemy(img, x, y, function(enemy)
			local diff = math.pi / 30
			enemy.angle = 0 + diff
			if opposite then enemy.angle = math.pi - diff end
			enemy.speed = 2.25
			enemy.health = 3
		end, function(enemy)
			if enemy.speed > .75 then
				enemy.speed = enemy.speed - .05
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
			end
			local interval = 45
			if enemy.clock % interval == 0 and enemy.clock >= interval then spawnBullet(enemy) end
		end)
	end
	local interval = 70
	local limit = interval * 4
	if currentWave.clock % interval == 0 and currentWave.clock < limit then spawnEnemy() end
	if currentWave.clock % interval == 0 and currentWave.clock >= limit / 2 and currentWave.clock < limit * 1.5 then spawnEnemy(true) end
	if currentWave.clock >= limit * 1.5 then
		currentWave = enemies.stageTwoWaveTwo
		currentWave.clock = -1
	end
end)

enemies.stageTwoWaveTwo = enemyObj(function()
	local function spawnBullet(enemy)
		local angle = getAngle(enemy, player)
		local speed = 1.65
		local img = 'big'
		if enemy.opposite then
			img = 'small'
			speed = 1.35
		end
		stage.spawnBullet(img, enemy.x, enemy.y, function(bullet)
			bullet.velocity = {
				x = math.cos(angle) * speed,
				y = math.sin(angle) * speed
			}
		end)
	end
	local function spawnEnemy(x, altY, altAngle)
		local angle = math.pi / 2
		local y = -stage.enemyImages.fairyred.idle1:getHeight() / 2
		if altAngle then angle = altAngle end
		if altY then y = altY end
		local speed = .75
		stage.spawnEnemy('fairyyellow', x, y, function(enemy)
			enemy.velocity = {
				x = math.cos(angle) * speed,
				y = math.sin(angle) * speed
			}
			enemy.health = 3
			if altY then enemy.opposite = true end
		end, function(enemy)
			local interval = 90
			if enemy.clock % interval == interval / 2 and enemy.y < gameHeight / 4 * 3 then spawnBullet(enemy) end
		end)
	end
	local interval = 70
	local limit = interval * 4
	local offset = 40
	local yOffset = grid * 2.5
	local topStart = limit * 2 + offset * 2
	if currentWave.clock % interval == 0 then
		if currentWave.clock < limit then
			spawnEnemy(gameWidth - grid * 3)
			spawnEnemy(gameWidth - grid * 8)
		elseif currentWave.clock >= limit + offset and currentWave.clock < limit * 2 + offset then
			spawnEnemy(grid * 3)
			spawnEnemy(grid * 8)
		end
		local topOffset = 60
		if currentWave.clock >= topStart and currentWave.clock < topStart + limit then spawnEnemy(-stage.enemyImages.fairyred.idle1:getWidth() / 2, yOffset, 0) end
		if currentWave.clock >= topStart + topOffset and currentWave.clock < topStart + limit + topOffset then spawnEnemy(gameWidth + stage.enemyImages.fairyred.idle1:getWidth() / 2, yOffset * 2, math.pi) end
		if currentWave.clock >= topStart + topOffset * 2 and currentWave.clock < topStart + limit + topOffset * 2 then spawnEnemy(-stage.enemyImages.fairyred.idle1:getWidth() / 2, yOffset * 3, 0) end
		if currentWave.clock >= topStart + limit + topOffset * 2 then
			currentWave = enemies.stageTwoWaveThree
			currentWave.clock = -1
		end
	end
end)

enemies.stageTwoWaveThree = enemyObj(function()
	local function spawnBullet(enemy)
		local speed = 1.75
		stage.spawnBullet('arrow', enemy.x, enemy.y, function(bullet)
			bullet.velocity = {
				x = math.cos(enemy.laserAngle) * speed,
				y = math.sin(enemy.laserAngle) * speed
			}
			bullet.rotation = enemy.laserAngle
		end)
	end
	local function spawnEnemy(x)
		local angle = math.pi / 2
		local speed = .75
		stage.spawnEnemy('fairyred', x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
			enemy.velocity = {
				x = math.cos(angle) * speed,
				y = math.sin(angle) * speed
			}
			enemy.health = 3
		end, function(enemy)
			local interval = 100
			local bInterval = 20
			local offset = interval / 5
			if enemy.clock % interval >= offset and enemy.clock % bInterval == 0 and enemy.y < gameHeight / 2 then
				if enemy.clock % interval == offset then
					enemy.laserPosition = {x = enemy.x, y = enemy.y}
					enemy.laserAngle = getAngle(enemy, player)
				end
				spawnBullet(enemy)
			end
		end)
	end
	local interval = 90
	if currentWave.clock % interval == 0 and currentWave.clock < interval * 5 then
		local x = math.floor(gameWidth / 3 * math.random()) + gameWidth / 6
		local sX = x + math.random() * gameWidth / 2
		local mod = grid * 5
		if sX < x + mod then sX = sX + mod end
		if sX > gameWidth - gameWidth / 6 then sX = gameWidth - gameWidth / 6 end
		spawnEnemy(x)
		spawnEnemy(sX)
	end
	prepForBoss('stageTwoBoss')
end)

enemies.stageTwoBoss = enemyObj(function()
	local attacks = {
		function(enemy)
			local function sweeper()
				local speed = 2
				local interval = 5
				local limit = interval * 10
				local max = limit * 2
				local sweepMod = math.pi / interval
				local sweepArea = math.pi - sweepMod * 2
				local function spawnBullet(opposite, mod)
					local offset = 8
					local offsetAngle = enemy.sweepAngle + math.pi / 2
					if opposite then offsetAngle = offsetAngle + math.pi end
					local x = enemy.x + math.cos(offsetAngle) * offset
					local y = enemy.y + math.sin(offsetAngle) * offset
					local speedMod = .2
					stage.spawnBullet('bullet', x, y, function(bullet)
						bullet.rotation = enemy.sweepAngle
						bullet.velocity = {
							x = math.cos(enemy.sweepAngle) * (speed + (mod * speedMod)),
							y = math.sin(enemy.sweepAngle) * (speed + (mod * speedMod))
						}
						if mod == 0 then bullet.visible = false end
					end)
					if opposite and mod == 0 then
						local angleMod = sweepArea / (interval * 2)
						if enemy.sweepDirection == 1 then enemy.sweepAngle = enemy.sweepAngle + angleMod
						else enemy.sweepAngle = enemy.sweepAngle - angleMod end
					end
				end
				if enemy.clock == 0 then enemy.sweepDirection = 1 end
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						enemy.sweepDirection = -enemy.sweepDirection
						enemy.sweepAngle = math.pi - sweepMod
						if enemy.sweepDirection == 1 then enemy.sweepAngle = sweepMod end
					end
					for i = 1, 5 do
						spawnBullet(false, i - 1)
						spawnBullet(true, i - 1)
					end
				end
			end
			local function bolts()
				local function spawnBullets(mod, opposite, otherOpposite, hidden)
					local angle = enemy.boltAngleA
					local x = enemy.x - bossOffset
					if opposite then
						x = enemy.x + bossOffset
						angle = enemy.boltAngleB
					end
					local offset = 9
					local offsetAngle = angle + math.pi / 2
					if otherOpposite then offsetAngle = offsetAngle + math.pi end
					x = x + math.cos(offsetAngle) * offset
					y = enemy.y + math.sin(offsetAngle) * offset
					local speed = 2 + mod * .3
					stage.spawnBullet('boltlight', x, y, function(bullet)
						bullet.rotation = angle
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						if hidden then bullet.visible = false end
					end)
				end
				local interval = 5
				local limit = interval * 4
				local max = limit * 3

				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						enemy.boltAngleA = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player)
						enemy.boltAngleB = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player)
					end
					local mod = enemy.clock % max / interval
					if enemy.clock % (max * 2) < max then
						if enemy.clock % max == 0 then explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true, true) end
						spawnBullets(mod, false, false, true)
						spawnBullets(mod)
						spawnBullets(mod, false, true)
					else
						if enemy.clock % max == 0 then explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true, true) end
						spawnBullets(mod, true, false, true)
						spawnBullets(mod, true)
						spawnBullets(mod, true,true)
					end
				end

			end
			sweeper()
			bolts()
		end,
		function(enemy)
			local function ring()
				local function spawnBullets()
					local angle = enemy.ringAngle
					local count = 15
					local speed = 2
					for i = 1, count do
						stage.spawnBullet('smalllight', enemy.x + bossOffset, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * speed,
								y = math.sin(angle) * speed
							}
						end)
						angle = angle + math.tau / count
					end
					enemy.ringAngle = enemy.ringAngle + .15
				end
				local interval = 25
				if enemy.clock == 0 then enemy.ringAngle = -math.pi / 2 end
				if enemy.clock % interval == 0 then spawnBullets() end
				if enemy.clock % (interval * 2) == 0 then explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true) end
			end
			local function splash()
				local interval = 6
				local limit = interval * 5
				local max = limit * 3
				local function spawnBullet(opposite, hidden)
					local speed = 2
					speed = speed + (enemy.clock % max + 1) * .05
					local offset = grid - 2
					local angle = getAngle(enemy, enemy.arrowTarget)
					local offsetAngle = angle + math.pi / 2
					if opposite then offsetAngle = offsetAngle + math.pi end
					local x = enemy.x + math.cos(offsetAngle) * offset
					local y = enemy.y + math.sin(offsetAngle) * offset
					stage.spawnBullet('big', x, y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						if hidden then bullet.visible = false end
					end)
				end
				if enemy.clock % max == 0 then enemy.arrowTarget = {x = player.x, y = player.y} end
				if enemy.clock >= max and enemy.clock % interval == 0 and enemy.clock % max < limit then
					spawnBullet(false, true)
					spawnBullet()
					spawnBullet(true)
				end
			end
			local function spray()
				local function spawnBullets()
					explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
					local count = 5
					local mod = math.pi / 9
					local angle = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player) - mod * 2
					for i = 1, count do
						local speed = 2
						for j = 1, 5 do
							local jSpeed = speed + j * .2
							stage.spawnBullet('bullet', enemy.x - bossOffset, enemy.y, function(bullet)
								bullet.velocity = {
									x = math.cos(angle) * jSpeed,
									y = math.sin(angle) * jSpeed
								}
								bullet.rotation = angle
							end)
						end
						angle = angle + mod
					end
				end
				local interval = 120
				if enemy.clock % interval == 0 and enemy.clock > interval then spawnBullets() end
			end
			ring()
			splash()
			spray()
		end,
		function(enemy)
			local function ring()
				local function spawnBullets()
					local count = 50
					local speed = 2
					local angle = getAngle(enemy, player)
					for i = 0, count do
						if i < count / 4 or i > count / 4 * 3 + 2 then
							local jCount = 5
							for j = 1, jCount do
								local jSpeed = speed + j * .2
								stage.spawnBullet('bullet', enemy.x, enemy.y, function(bullet)
									bullet.velocity = {
										x = math.cos(angle) * jSpeed,
										y = math.sin(angle) * jSpeed
									}
									bullet.rotation = angle
									if i == 0 then bullet.visible = false end
								end)
							end
						end
						if i > 0 then angle = angle + math.tau / count end
					end
				end
				local interval = 80
				if enemy.clock % interval == 0 then spawnBullets() end
			end
			local function sides()
				local function spawnBullet(x)
					local mod = .02
					angle = enemy.laserAngle - mod + mod * 2 * math.random()
					local speed = 2.5
					stage.spawnBullet('arrowlight', x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.rotation = angle
					end)
				end
				local interval = 10
				local limit = interval * 10
				local max = limit * 1.5
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					local x = enemy.x - bossOffset
					if enemy.clock % (max * 2) >= max then x = enemy.x + bossOffset end
					if enemy.clock % max == 0 then enemy.laserAngle = getAngle({x = x, y = enemy.y}, player) end
					spawnBullet(x)
					if enemy.clock % (interval * 3) == 0 then explosions.spawn({x = x, y = enemy.y}, true, true) end
				end
			end
			ring()
			sides()
		end
	}
	local moves = {}
	if currentWave.clock == 0 then
		spawnBoss('cirno', attacks, moves, function()
			stage.killBullets = true
			clearedStageClock = clearedStageLimit
		end, function(enemy)
			sideSideMove(enemy)
		end)
	end
end)


-- STAGE 3
enemies.stageThreeWaveOne = enemyObj(function()
	local function spawnShot(enemy)
		local function spawnBullet(opposite)
			local speed = 2
			local offset = 10
			local angle = enemy.shotAngle
			local offsetAngle = angle + math.pi / 2
			if opposite then offsetAngle = offsetAngle + math.pi end
			local x = enemy.shotPos.x + math.cos(offsetAngle) * offset
			local y = enemy.shotPos.y + math.sin(offsetAngle) * offset
			stage.spawnBullet('bullet', x, y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.rotation = angle
			end)
		end
		spawnBullet()
		spawnBullet(true)
	end
	local function spawnRing(enemy)
		local angle = enemy.ringAngle
		local count = 6
		local speed = 2
		for i = 1, count do
			stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.rotation = angle
			end)
			angle = angle + math.tau / count
		end
	end
	local function spawnEnemy(opposite)
		local x = -stage.enemyImages.fairyred.idle1:getWidth() / 2
		local y = gameHeight / 3
		stage.spawnEnemy('fairygreen', x, y, function(enemy)
			enemy.angle = -math.pi / 4
			enemy.speed = .75
			enemy.health = 8
			if opposite then enemy.opposite = true end
		end, function(enemy)
			enemy.velocity = {
				x = math.cos(enemy.angle) * enemy.speed,
				y = math.sin(enemy.angle) * enemy.speed
			}
			enemy.angle = enemy.angle + .0045
			if enemy.opposite then
				local interval = 15
				local limit = interval * 2
				local max = interval * 10
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						enemy.shotAngle = getAngle(enemy, player)
						enemy.shotPos = {x = enemy.x, y = enemy.y}
					end
					spawnShot(enemy)
				end
			else
				local interval = 5
				local limit = interval * 8
				local max = limit * 1.5
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if not enemy.ringAngle then
						enemy.ringAngle = getAngle(enemy, player) - math.pi / 2
						enemy.ringMod = 0.025
					end
					if enemy.clock % max == 0 then
						enemy.ringMod = enemy.ringMod * -1
					end
					spawnRing(enemy)
					enemy.ringAngle = enemy.ringAngle + enemy.ringMod
				end
			end
			if enemy.x >= gameWidth + stage.enemyImages.fairyred.idle1:getWidth() / 2 then enemy.y = gameHeight * 2 end
		end)
	end
	local interval = 100
	if currentWave.clock % interval == 0 and currentWave.clock < interval * 8 then
		spawnEnemy(currentWave.clock % (interval * 2) == 0)
	end
end)

enemies.stageThreeWaveTwo = enemyObj(function()
	local function spawnBullets(enemy)
		local count = 7
		local mod = math.pi / 15
		local angle = getAngle(enemy, player) - math.floor(count / 2) * mod
		local speed = 1.5
		for i = 1, count do
			stage.spawnBullet('bolt', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.rotation = angle
			end)
			angle = angle + mod
		end
	end
	local function spawnEnemy(opposite)
		local diff = grid * 2
		local x = (gameWidth / 2 - diff) * math.random()
		if opposite then x = x + gameWidth / 2 - diff end
		x = x + diff
		local angle = math.pi / 2
		local speed = .65
		stage.spawnEnemy('fairygreen', x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
			enemy.velocity = {
				x = math.cos(angle) * speed,
				y = math.sin(angle) * speed
			}
			enemy.health = 5
		end, function(enemy)
			local interval = 100
			if enemy.clock % interval == interval / 2 and enemy.y < gameHeight / 5 * 3 then spawnBullets(enemy) end
		end)
	end
	local interval = 90
	local limit = interval * 6
	if currentWave.clock % interval == 0 and currentWave.clock < limit then spawnEnemy(currentWave.clock % (interval * 2) == 0) end
end)

enemies.stageThreeWaveThree = enemyObj(function()
	local function spawnRing(enemy, opposite)
		local count = 5
		local angle = enemy.ringAngleA
		local offset = grid
		local offsetAngle = 0
		if opposite then
			offsetAngle = math.pi
			angle = enemy.ringAngleB
		end
		local x = enemy.x + math.cos(offsetAngle) * offset
		local y = enemy.y + math.sin(offsetAngle) * offset
		local speed = 1.5
		for i = 1, count do
			stage.spawnBullet('small', x, y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
			end)
			angle = angle + math.tau / count
		end
	end
	local function spawnLaser(enemy)
		local count = 3
		local speed = 2.5
		local mod = math.pi / 4
		local angle = enemy.laserAngle - mod
		for i = 1, count do
			stage.spawnBullet('bulletlight', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.rotation = angle
			end)
			angle = angle + mod
		end
	end
	local function spawnEnemy(opposite)
		local x = gameWidth / 4 * 3
		local img = 'fairyyellow'
		if opposite then
			x = gameWidth / 4
			img = 'fairygreen'
		end
		stage.spawnEnemy(img, x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
			enemy.speed = 2
			enemy.health = 15
			enemy.angle = math.pi / 2
			if opposite then enemy.opposite = true end
		end, function(enemy)
			if enemy.speed > .35 then
				enemy.speed = enemy.speed - .025
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
				enemy.clock = -1
			elseif enemy.y < gameHeight / 2 then
				if not enemy.ringAngleA then
					enemy.ringAngleA = math.pi / 2
					enemy.ringAngleB = math.pi / 2
				end
				local interval = 18
				if enemy.clock % interval == 0 then
					spawnRing(enemy)
					spawnRing(enemy, true)
					local mod = .125
					enemy.ringAngleA = enemy.ringAngleA + mod
					enemy.ringAngleB = enemy.ringAngleB - mod
				end
				local laserInterval = 9
				if enemy.clock % laserInterval == 0 and enemy.clock < laserInterval * 8 then
					if not enemy.laserAngle then enemy.laserAngle = getAngle(enemy, player) end
					spawnLaser(enemy)
				end
			end
		end)
	end
	local interval = 180
	if currentWave.clock == 0 then spawnEnemy() end
	if currentWave.clock == interval then spawnEnemy(true) end
	if currentWave.clock >= interval then prepForBoss('stageThreeBoss') end
end)

enemies.stageThreeBoss = enemyObj(function()
	local attacks = {
		function(enemy)
			local function laser()
				local speed = 3.25
				local function spawnBullet()
					angle = getAngle(enemy, enemy.laserTarget)
					stage.spawnBullet('bolt', enemy.x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.rotation = angle
						if i == 1 then bullet.visible = false end
					end)
				end
				local interval = 10
				local limit = interval * 10
				local max = limit * 2
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						enemy.laserTarget = {x = player.x, y = player.y}
					end
					spawnBullet()
				end
			end
			local function sides()
				local function spawnBullets()
					local angle = enemy.bulletAngle
					local x = enemy.bulletX
					local count = 45
					local speed = 2
					local diff = math.pi / 3
					for i = 1, count do
						if angle < enemy.bulletAngle + diff or angle >= enemy.bulletAngle + math.tau - diff then
							stage.spawnBullet('smalllight', x, enemy.y, function(bullet)
								bullet.velocity = {
									x = math.cos(angle) * speed,
									y = math.sin(angle) * speed
								}
							end)
						end
						angle = angle + math.tau / count
					end
				end
				local interval = 20
				local limit = interval * 2
				local max = limit * 2
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						if enemy.clock % (max * 2) < max then
							enemy.bulletAngle = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player)
							enemy.bulletX = enemy.x - bossOffset
						else
							enemy.bulletAngle = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player)
							enemy.bulletX = enemy.x + bossOffset
						end
						explosions.spawn({x = enemy.bulletX, y = enemy.y}, true, true)
					end
					spawnBullets()
				end
			end
			laser()
			sides()
		end,
		function(enemy)
			local function spawnBullets()
				local speed = 2.5
				local function spawnRay(diff)
					local baseAngle = getAngle(enemy, player)
					local angle = baseAngle - math.pi
					local raySpeed = speed + .175 * diff
					for i = 1, enemy.ringCount do
						if angle > 0 and angle < math.pi then
							stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
								bullet.velocity = {
									x = math.cos(angle) * raySpeed,
									y = math.sin(angle) * raySpeed
								}
								if diff == -1 then bullet.visible = false end
							end)
						end
						angle = angle + math.tau / enemy.ringCount
					end
				end
				for i = 1, 6 do
					spawnRay(i - 2)
				end
			end
			local interval = 40
			local max = interval * 8
			local limit = max - interval
			if enemy.clock % interval == 0 and enemy.clock % max < limit then
				if enemy.clock % max == 0 then enemy.ringCount = 25 end
				spawnBullets()
				enemy.ringCount = enemy.ringCount + 3
			end
		end,
		function(enemy)
			local function lasers()
				local function spawnBullet(opposite, other)
					local angle = enemy.bulletAngle
					local x = enemy.x + bossOffset
					if other then
						angle = enemy.bulletAngleOther
						x = enemy.x - bossOffset
					end
					local offset = 10
					local offsetAngle = angle + math.pi / 2
					if opposite then
						offsetAngle = offsetAngle + math.pi
					end
					if other then x = enemy.x - bossOffset end
					x = x + math.cos(offsetAngle) * offset
					local y = enemy.y + math.sin(offsetAngle) * offset
					local speed = 2.5
					stage.spawnBullet('bullet', x, y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.rotation = angle
					end)
				end
				local interval = 10
				local limit = interval * 5
				if enemy.clock % interval == 0 then
					local isOther = enemy.clock % (limit * 2) >= limit
					if enemy.clock % limit == 0 then
						enemy.bulletAngle = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player)
						enemy.bulletAngleOther = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player)
						local x = enemy.x + bossOffset
						if isOther then x = enemy.x - bossOffset end
						explosions.spawn({x = x, y = enemy.y}, true, true)
					end
					spawnBullet(false, isOther)
					spawnBullet(true, isOther)
				end
			end
			local function spray()
				local function spawnBullets(x)
					local speed = 1.5
					local count = 5
					local angle = math.pi * math.random()
					for i = 1, (count + 1) do
						stage.spawnBullet('biglight', x, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * speed,
								y = math.sin(angle) * speed
							}
							if i == 1 then bullet.visible = false end
						end)
						if i > 0 then angle = angle + math.tau / count end
					end
				end
				local interval = 20
				if enemy.clock % interval == 0 then
					spawnBullets(enemy.x - bossOffset)
					spawnBullets(enemy.x + bossOffset)
				end
			end
			lasers()
			spawnSecond(enemy, spray)
		end
	}
	local moves = {}
	if currentWave.clock == 0 then
		spawnBoss('cirno', attacks, moves, function()
			stage.killBullets = true
			clearedStageClock = clearedStageLimit
		end, function(enemy)
			sideSideMove(enemy)
		end)
	end
end)


-- STAGE 4

enemies.stageFourWaveOne = enemyObj(function()
	local function spawnBullet(enemy)
		local speed = 1.25
		local mod = math.pi / 4
		local angle = getAngle(enemy, player) - mod + mod * 2 * math.random()
		stage.spawnBullet('smalllight', enemy.x, enemy.y, function(bullet)
			bullet.velocity = {
				x = math.cos(angle) * speed,
				y = math.sin(angle) * speed
			}
		end)
	end
	local function spawnShots(enemy)
		local count = 7
		local mod = math.pi / 15
		local angle = enemy.shotAngle - mod * math.floor(count / 2)
		local speed = 2
		for i = 1, count do
			stage.spawnBullet('bolt', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.rotation = angle
			end)
			angle = angle + mod
		end
	end
	local function spawnLasers(enemy)
		local count = 5
		local mod = math.pi / 5
		local angle = enemy.laserAngle - mod * math.floor(count / 2)
		local speed = 2
		for i = 1, count do
			stage.spawnBullet('bulletlight', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.rotation = angle
			end)
			angle = angle + mod
		end
	end
	local function spawnSplash(enemy)
		local count = 17
		local speed = 1.25
		local angle = getAngle(enemy, player)
		for i = 1, count do
			stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
			end)
			angle = angle + math.tau / count
		end
	end
	local function spawnEnemy(opposite, other, alt)
		local x = gameWidth / 4
		local img = 'fairyred'
		if opposite then
			x = gameWidth / 2
			img = 'fairyyellow'
		elseif other then
			x = gameWidth / 4 * 3
			img = 'fairygreen'
		end
		if alt then x = gameWidth / 4 end
		stage.spawnEnemy(img, x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
			enemy.speed = 1.5
			enemy.health = 15
			enemy.angle = math.pi / 2
			if opposite then enemy.opposite = true
			elseif other then enemy.other = true end
		end, function(enemy)
			if enemy.speed > .35 then
				enemy.speed = enemy.speed - .025
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
				enemy.clock = -1
			elseif enemy.y < gameHeight / 2 then
				if enemy.opposite then
					local interval = 15
					local limit = interval * 2
					local max = limit * 3
					if enemy.clock % interval == 0 and enemy.clock % max < limit then
						if enemy.clock % max == 0 then enemy.shotAngle = getAngle(enemy, player) end
						spawnShots(enemy)
					end
				elseif enemy.other then
					local interval = 5
					local limit = interval * 10
					local max = limit * 2
					if enemy.clock % interval == 0 and enemy.clock % max < limit then
						if enemy.clock % max == 0 then
							enemy.laserAngle = getAngle(enemy, player)
							enemy.laserPos = {x = enemy.x, y = enemy.y}
						end
						spawnLasers(enemy)
					end
					local splashInterval = 90
					if enemy.clock % splashInterval == splashInterval / 2 then spawnSplash(enemy) end
				elseif enemy.clock % 4 == 0 then spawnBullet(enemy) end
			end
		end)
	end
	local interval = 120
	if currentWave.clock == 0 then spawnEnemy()
	elseif currentWave.clock == interval then spawnEnemy(true)
	elseif currentWave.clock == interval * 3 then
		spawnEnemy(false, true)
		spawnEnemy(false, true, true)
	end
end)

enemies.stageFourWaveTwo = enemyObj(function()
	local function spawnArrows(enemy)
		local function spawnBullet(shotOffset)
			local angle = enemy.arrowAngle
			local offset = 18
			local offsetAngle = angle + math.pi / 2
			if shotOffset then offsetAngle = offsetAngle + shotOffset end
			local x = enemy.x + math.cos(offsetAngle) * offset
			local y = enemy.y + math.sin(offsetAngle) * offset
			local speed = 1.5
			stage.spawnBullet('arrow', x, y, function(bullet)
				bullet.rotation = angle
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
			end)
		end
		spawnBullet()
		spawnBullet(math.pi)
		spawnBullet(-math.pi / 2)
	end
	local function spawnBurst(enemy)
		local count = 5
		local mod = math.pi / 10
		local angle = enemy.burstAngle - mod * math.floor(count / 2)
		local speed = 1.75
		for i = 1, count do
			stage.spawnBullet('boltlight', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.rotation = angle
			end)
			angle = angle + mod
		end
	end
	local function spawnEnemy(opposite)
		local x = gameWidth / 4
		if opposite then x = x + gameWidth / 2 end
		stage.spawnEnemy('fairyred', x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
			enemy.speed = 1.5
			enemy.health = 5
			enemy.angle = math.pi / 2
		end, function(enemy)
			if enemy.speed > .35 then
				enemy.speed = enemy.speed - .025
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
				enemy.clock = -1
			elseif enemy.y < gameHeight / 2 then
				if opposite then
					local interval = 20
					local limit = interval * 6
					local max = limit * 2
					if enemy.clock % interval == 0 and enemy.clock % max < limit then
						if enemy.clock % max == 0 then enemy.arrowAngle = getAngle(enemy, player) end
						spawnArrows(enemy)
					end
				else
					local interval = 20
					local limit = interval * 4
					local max = limit * 2
					if enemy.clock % interval == 0 and enemy.clock % max < limit then
						if enemy.clock % max == 0 then enemy.burstAngle = getAngle(enemy, player) end
						spawnBurst(enemy)
					end
				end
			end
		end)
	end
	local interval = 60
	if currentWave.clock % interval == 0 and currentWave.clock < interval * 8 then spawnEnemy(currentWave.clock % (interval * 2) == 0) end
end)

enemies.stageFourWaveThree = enemyObj(function()
	local function spawnBullets(enemy, opposite, isFat)
		local x = enemy.x - bossOffset
		local initAngle = enemy.initBulletAngle
		local angle = enemy.bulletAngle
		local count = 9
		local speed = 2.25
		if opposite then
			x = enemy.x + bossOffset
			initAngle = enemy.initBulletAngleOther
			angle = enemy.bulletAngleOther
		end
		angle = angle + enemy.bulletMod * count / 2
		local img = 'bullet'
		if isFat then img = 'bolt' end
		for i = 1, count do
			stage.spawnBullet(img, x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.rotation = angle
				if i == 1 then bullet.visible = false end
			end)
			angle = angle - enemy.bulletMod
		end
	end
	local function spawnEnemy()
		stage.spawnEnemy('fairyred', gameWidth / 2, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
			enemy.speed = 1.5
			enemy.health = 100
			enemy.angle = math.pi / 2
		end, function(enemy)
			if enemy.speed > 0 then
				enemy.speed = enemy.speed - .02
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
				enemy.clock = -1
			else
				if enemy.speed ~= 0 then
					enemy.speed = 0
					enemy.velocity = {x = 0, y = 0}
				end
				if enemy.clock == 0 then
					enemy.bulletAngle = getAngle({x = enemy.x - bossOffset, y = enemy.y}, {x = gameWidth * .75, y = gameHeight})
					enemy.bulletAngleOther = getAngle({x = enemy.x + bossOffset, y = enemy.y}, {x = gameWidth / 4, y = gameHeight})
					enemy.initBulletAngle = enemy.bulletAngle
					enemy.initBulletAngleOther = enemy.bulletAngleOther
					enemy.bulletDirection = false
					enemy.bulletMin = .25
					enemy.bulletMax = .4
					enemy.bulletMod = enemy.bulletMax
				end
				local interval = 10
				local limit = 120
				if enemy.clock % interval == 0 then
					local isFat = enemy.clock >= limit
					if enemy.clock % limit < limit / 5 * 4 then
						spawnBullets(enemy, false, isFat)
						spawnBullets(enemy, true, isFat)
					end
					local expoLimit = interval * 4
					if enemy.clock % expoLimit == 0 then explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
					elseif enemy.clock % expoLimit == expoLimit / 2 then explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true) end
					local modMod = .01
					if enemy.bulletDirection then
						enemy.bulletMod = enemy.bulletMod + modMod
						if enemy.bulletMod > enemy.bulletMax then enemy.bulletDirection = false end
					else
						enemy.bulletMod = enemy.bulletMod - modMod
						if enemy.bulletMod <= enemy.bulletMin then enemy.bulletDirection = true end
					end
				end
			end
		end)
	end
	if currentWave.clock == 0 then spawnEnemy() end
end)

enemies.stageFourBoss = enemyObj(function()
	local attacks = {
		function(enemy)
			local function spawnBullets()
				local distance = grid * 4.5
				local count = 6
				local angle = math.pi * 3
				local sCount = 13
				local speed = 2
				for i = 1, count do
					if i == enemy.currentSpawn then
						local x = enemy.x + math.cos(angle) * distance
						local y = enemy.y + math.sin(angle) * distance
						explosions.spawn({x = x, y = y}, true, true)
						local sAngle = enemy.bulletAngle
						for j = 1, sCount do
							stage.spawnBullet('bulletlight', x, y, function(bullet)
								bullet.velocity = {
									x = math.cos(sAngle) * speed,
									y = math.sin(sAngle) * speed
								}
								bullet.rotation = sAngle
							end)
							sAngle = sAngle + math.tau / sCount
						end
					end
					angle = angle + math.tau / count
				end
				enemy.currentSpawn = enemy.currentSpawn + 1
				if enemy.currentSpawn > count then enemy.currentSpawn = 1 end
				enemy.bulletAngle = enemy.bulletAngle + .1
			end
			local interval = 10
			if enemy.clock == 0 then
				enemy.currentSpawn = 1
				enemy.bulletAngle = math.pi * 3
			end
			if enemy.clock % interval == 0 then spawnBullets() end
		end,
		function(enemy)
			local function spawnBullets(opposite)
				local x = enemy.x - bossOffset
				local angle = enemy.bulletAngle
				if opposite then
					x = enemy.x + bossOffset
					angle = enemy.bulletAngleOther
				end
				local count = 6
				local speed = 2
				for i = 1, count do
					stage.spawnBullet('bullet', x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.rotation = angle
						-- if i == 1 then bullet.visible = false end
					end)
					angle = angle + math.tau / count
				end
			end
			local interval = 5
			local mod = .25
			if enemy.clock == 0 then
				enemy.bulletAngle = math.pi
				enemy.bulletAngleOther = math.pi
			end
			if enemy.clock % interval == 0 then
				if enemy.clock % (interval * 3) == 0 then
					explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
					explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
				end
				if enemy.clock % (interval * 2) == 0 then
					spawnBullets()
					enemy.bulletAngle = enemy.bulletAngle + mod
				else
					spawnBullets(true)
					enemy.bulletAngleOther = enemy.bulletAngleOther - mod
				end
			end
		end,
		function(enemy)
			local count = 11
			local mod = math.pi / 20
			local speed = 2.5
			local function spawnBig()
				local angle = enemy.baseAngle + math.pi
				for i = 1, count do
					stage.spawnBullet('bulletlight', enemy.x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.rotation = angle
					end)
					angle = angle + mod
				end
			end
			local function spawnSmall()
				local angle = enemy.baseAngle
				for i = 1, count do
					stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
					end)
					angle = angle + mod
				end
			end
			local interval = 17
			if enemy.clock == 0 then
				enemy.baseAngle = math.pi / 4
				enemy.baseDirection = 1
			end
			local baseMod = .225
			if enemy.clock % interval == 0 then
				spawnBig()
				spawnSmall()
				if enemy.baseDirection == 1 then
					enemy.baseAngle = enemy.baseAngle - baseMod
				else
					enemy.baseAngle = enemy.baseAngle + baseMod
				end
				if enemy.clock % (60 * 5) == 0 then enemy.baseDirection = enemy.baseDirection * -1 end
			end
		end
	}
	local moves = {}
	if currentWave.clock == 0 then
		spawnBoss('cirno', attacks, moves, function()
			stage.killBullets = true
			clearedStageClock = clearedStageLimit
		end, function(enemy)
			sideSideMove(enemy)
		end)
	end
end)


-- STAGE 5
enemies.stageFiveWaveOne = enemyObj(function()
	local function spawnRing(enemy)
		local angle = enemy.bulletAngle
		local count = 25
		local speed = 1
		for i = 1, count do
			stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
			end)
			angle = angle + math.tau / count
		end
	end
	local function spawnTurd(enemy)
		local speed = 1.25
		local mod = math.pi / 3
		local angle = enemy.turdAngle - mod + mod * 2 * math.random()
		stage.spawnBullet('smalllight', enemy.x, enemy.y, function(bullet)
			bullet.velocity = {
				x = math.cos(angle) * speed,
				y = math.sin(angle) * speed
			}
		end)
	end
	local function spawnLasers(enemy)
		local mod = math.pi / 9
		local count = 3
		local angle = enemy.bulletAngle - mod
		local speed = 2
		for i = 1, count do
			stage.spawnBullet('bulletlight', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.rotation = angle
			end)
			angle = angle + mod
		end
	end
	local function spawnBig(opposite)
		local x = gameWidth / 3 * 2
		if opposite then x = gameWidth / 3 end
		stage.spawnEnemy('fairyred', x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
			enemy.speed = 1.5
			enemy.health = 22
			enemy.angle = math.pi / 2
			if opposite then enemy.opposite = true end
		end, function(enemy)
			if enemy.speed > .35 then
				enemy.speed = enemy.speed - .015
				local mod = .01
				if enemy.opposite then mod = mod * -1 end
				enemy.angle = enemy.angle + mod
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
				enemy.clock = -1
			else
				local interval = 45
				local xLimit = grid * 3.5
				if enemy.clock == 0 then enemy.bulletAngle = math.pi * math.random() end
				if enemy.clock % interval == 0 and enemy.x > xLimit and enemy.x < gameWidth - xLimit then
					spawnRing(enemy)
					enemy.bulletAngle = enemy.bulletAngle - .15
				end
			end
		end)
	end
	local function spawnSmall(opposite)
		local x = currentWave.enemyX
		local y = -stage.enemyImages.fairyred.idle1:getHeight() / 2
		local speed = .5
		local angle = getAngle({x = x, y = y}, player)
		local img = 'fairygreen'
		if opposite then img = 'fairyyellow' end
		stage.spawnEnemy(img, x, y, function(enemy)
			enemy.health = 3
			enemy.velocity = {
				x = math.cos(angle) * speed,
				y = math.sin(angle) * speed
			}
			if opposite then enemy.opposite = true end
		end, function(enemy)
			if enemy.opposite then
				local interval = 10
				local limit = interval * 5
				local max = limit * 3
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then enemy.bulletAngle = getAngle(enemy, player) end
					spawnLasers(enemy)
				end
			else
				local interval = 5
				local limit = interval * 10
				local max = limit * 2
				if enemy.clock % interval == 0 and enemy.clock % max >= limit and enemy.clock < max * 3 then
					if enemy.clock % max == limit then enemy.turdAngle = getAngle(enemy, player) end
					spawnTurd(enemy)
				end
			end
		end)
	end
	local secondStart = 340
	if currentWave.clock == 0 then
		spawnBig()
		currentWave.enemyX = grid * 3
	elseif currentWave.clock == secondStart then
		spawnBig(true)
		currentWave.enemyX = gameWidth - grid * 3
	end
	local interval = 90
	if currentWave.clock % interval == interval / 3 and currentWave.clock % secondStart < interval * 4 and currentWave.clock < secondStart + interval * 4 then
		spawnSmall(currentWave.clock >= secondStart)
		local mod = grid
		if currentWave.clock >= secondStart then mod = mod * -1 end
		currentWave.enemyX = currentWave.enemyX + mod
	end
end)

enemies.stageFiveWaveTwo = enemyObj(function()

end)

enemies.stageFiveWaveThree = enemyObj(function()

end)

enemies.stageFiveBoss = enemyObj(function()
	local attacks = {
		function(enemy)
			local function burst()
				local function spawnBullet()
					stage.spawnBullet('smalllight', enemy.x, enemy.y, function(bullet)
						bullet.speed = 4
						bullet.angle = math.pi * math.random()
					end, function(bullet)
						if bullet.speed > .75 then
							bullet.velocity = {
								x = math.cos(bullet.angle) * (bullet.speed * .75),
								y = math.sin(bullet.angle) * bullet.speed
							}
							bullet.speed = bullet.speed - .05
						end
					end)
				end
				local limit = 5
				local max = limit * 3
				if enemy.clock % max < limit then
					spawnBullet()
					spawnBullet()
				end
			end
			local function lasers()
				local function spawnBullets(opposite)
					local target = {x = gameWidth, y = gameHeight}
					local x = enemy.x - bossOffset
					if opposite then
						x = enemy.x + bossOffset
						target.x = 0
					end
					local angle = getAngle({x = x, y = enemy.y}, target)
					local count = 7
					local mod = math.pi / 10
					angle = angle - mod * math.floor(count / 2)
					local speed = 2.25
					for i = 1, count do
						stage.spawnBullet('bullet', x, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * speed,
								y = math.sin(angle) * speed
							}
							bullet.rotation = angle
						end)
						angle = angle + mod
					end
				end
				local interval = 8
				local limit = interval * 5
				local max = limit * 2
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						local x = enemy.x + bossOffset
						if enemy.clock % (max * 2) == 0 then x = enemy.x - bossOffset end
						explosions.spawn({x = x, y = enemy.y}, true, true)
					end
					spawnBullets(enemy.clock % (max * 2) >= limit)
				end
			end
			burst()
			lasers()
		end,
		function(enemy)
			local function blast()
				local function spawnBullets()
					local count = 160
					local speed = 3
					local angle = getAngle(enemy, player)
					local frac = 10
					for i = 0, count do
						if i == 0 or (i % (count / frac) < count / frac / 2 and i < count / 4) then
							local sAngle = a
							stage.spawnBullet('smalllight', enemy.x, enemy.y, function(bullet)
								bullet.angle = angle - math.pi / 4.25
								bullet.speed = speed + math.random() * .05
								bullet.minSpeed = bullet.speed - 2
								if i == 0 then bullet.visible = false end
							end, function(bullet)
								if bullet.speed > bullet.minSpeed then
									bullet.velocity = {
										x = math.cos(bullet.angle) * bullet.speed,
										y = math.sin(bullet.angle) * bullet.speed
									}
									bullet.speed = bullet.speed - .05
								end
							end)
						end
						if i > 0 then angle = angle + math.tau / count end
					end
				end
				local interval = 75
				if enemy.clock % interval == 0 then spawnBullets() end
			end
			local function lasers()
				local function spawnBullets(opposite, first)
					local x = enemy.laserPosA.x
					local angle = enemy.laserAngleA
					if opposite then
						x = enemy.laserPosB.x
						angle = enemy.laserAngleB
					end
					local speed = 2.5
					local mod = math.pi / 11
					local count = 9
					angle = angle - mod * math.floor(count / 2)
					for i = 0, count do
						stage.spawnBullet('bullet', x, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * speed,
								y = math.sin(angle) * speed
							}
							bullet.rotation = angle
							if first or i == 0 then bullet.visible = false end
						end)
						if i > 0 then angle = angle + mod end
					end
				end
				local interval = 8
				local limit = interval * 4
				local max = limit * 2.5
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						enemy.laserPosA = {x = enemy.x - bossOffset, y = enemy.y}
						enemy.laserPosB = {x = enemy.x + bossOffset, y = enemy.y}
						enemy.laserAngleA = getAngle(enemy.laserPosA, player)
						enemy.laserAngleB = getAngle(enemy.laserPosB, player)
						explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
						explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
					end
					spawnBullets(false, enemy.clock % max == 0)
					spawnBullets(true, enemy.clock % max == 0)
				end
			end
			blast()
			lasers()
		end,
		function(enemy)
			local function sideRays()
				local function spawnBullet(x)
					local speed = 5
					stage.spawnBullet('boltlight', x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(enemy.sideAngle) * speed,
							y = math.sin(enemy.sideAngle) * speed
						}
						bullet.rotation = enemy.sideAngle
					end)
				end
				local interval = 6
				if enemy.clock % 20 == 0 then
					explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
					explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
				end
				if enemy.clock % interval == 0 then
					enemy.sideAngle = getAngle(enemy, player)
					spawnBullet(enemy.x - bossOffset)
					spawnBullet(enemy.x + bossOffset)
				end
			end
			local function ring()
				local function spawnBullets(opposite)
					local mod = math.pi / 15
					local count = 5
					local angle = getAngle(enemy, player) - mod * math.floor(count / 2)
					if opposite then angle = angle + mod / 5 * 3
					else angle = angle - mod / 5 * 3 end
					local speed = 1.75
					for i = 1, count do
						stage.spawnBullet('big', enemy.x, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * speed,
								y = math.sin(angle) * speed
							}
						end)
						angle = angle + mod
					end
				end
				local interval = 60
				if enemy.clock % interval == 0 then spawnBullets(enemy.clock % (interval * 2) == 0) end
			end
			local function centerRay()
				local function spawnBullet()
					local mod = 0.05
					local angle = getAngle(enemy, player) - mod
					angle = angle + mod * 2 * math.random()
					local speed = 1.25
					stage.spawnBullet('smalllight', enemy.x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
					end)
				end
				local interval = 30
				if enemy.clock % interval == 0 then spawnBullet() end
			end
			sideRays()
			ring()
			centerRay()
		end
	}
	local moves = {}
	if currentWave.clock == 0 then
		spawnBoss('cirno', attacks, moves, function()
			stage.killBullets = true
			clearedStageClock = clearedStageLimit
		end, function(enemy)
			sideSideMove(enemy)
		end)
	end
end)

-- STAGE 6
enemies.stageSixWaveOne = enemyObj(function()

end)

enemies.stageSixWaveTwo = enemyObj(function()

end)

enemies.stageSixWaveThree = enemyObj(function()

end)

enemies.stageSixBoss = enemyObj(function()
	local attacks = {
		function(enemy)
			local function spray()
				local function spawnBullets()
					local angle = enemy.bulletAngle
					local count = 25
					for i = 1, count do
						stage.spawnBullet('bullet', enemy.bulletPos.x, enemy.bulletPos.y, function(bullet)
							bullet.angle = angle
							bullet.speed = 1.5
							if enemy.bulletDir == 1 then bullet.opposite = true end
						end, function(bullet)
							if bullet.clock < 60 then
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
								bullet.rotation = bullet.angle
								local mod = 0.075
								if bullet.opposite then mod = mod * -1 end
								bullet.angle = bullet.angle + mod
							end
						end)
						angle = angle + math.tau / count
					end
					local mod = 0.1
					if enemy.bulletDir == 1 then mod = mod * -1 end
					enemy.bulletAngle = enemy.bulletAngle - mod
				end
				local interval = 30
				local max = interval * 10
				if enemy.clock == 0 then
					enemy.bulletAngle = 0
					enemy.bulletDir = -1
				end
				if enemy.clock % max == 0 then
					enemy.bulletPos = {x = enemy.x, y = enemy.y}
					enemy.bulletDir = enemy.bulletDir * -1
				end
				if enemy.clock % interval == 0 then spawnBullets() end
			end
			local function jolt()
				local function spawnBullets(opposite)
					local count = 100
					local angle = 0
					if opposite then angle = angle + math.pi / 2 end
					explosions.spawn({x = enemy.bulletPos.x, y = enemy.bulletPos.y}, true, true)
					for i = 1, count do
						if i % (count / 6) < 5 then
							stage.spawnBullet('biglight', enemy.bulletPos.x, enemy.bulletPos.y, function(bullet)
								bullet.angle = angle
								bullet.speed = 2
							end, function(bullet)
								if bullet.clock < 120 then
									bullet.velocity = {
										x = math.cos(bullet.angle) * bullet.speed,
										y = math.sin(bullet.angle) * bullet.speed
									}
									bullet.speed = bullet.speed - .025
								end
							end)
						end
						angle = angle + math.tau / count
					end
				end
				local interval = 60
				if enemy.clock % interval == 0 then spawnBullets(enemy.clock % (interval * 2) == 0) end
			end
			spray()
			jolt()
		end,
		function(enemy)
			local function ring()
				local function spawnBullets(other, opposite)
					local count = 30
					local angle = 0
					local speedX = 1.5
					local speedY = speedX
					local x = enemy.x - bossOffset
					if opposite then x = enemy.x + bossOffset end
					if other then speedX = speedX * .75
					else speedY = speedY * .75 end
					for i = 1, count do
						stage.spawnBullet('small', x, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * speedX,
								y = math.sin(angle) * speedY
							}
						end)
						angle = angle + math.tau / count
					end
				end
				local interval = 60
				if enemy.clock % interval == 0 then
					spawnBullets(enemy.clock % (interval * 2) < interval)
					spawnBullets(enemy.clock % (interval * 2) >= interval, true)
				end
			end
			local function laser()
				local function spawnBullet(mod, opposite)
					local speed = 1.5 + .175 * mod
					local x = enemy.x - bossOffset
					local angle = enemy.bulletAngleA
					if opposite then
						x = enemy.x + bossOffset
						angle = enemy.bulletAngleB
					end
					explosions.spawn({x = x, y = enemy.y}, true, true)
					stage.spawnBullet('biglight', x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
					end)
				end
				local interval = 10
				local limit = interval * 4
				local max = limit * 1.5
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						enemy.bulletAngleA = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player)
						enemy.bulletAngleB = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player)
					end
					local diffMod = enemy.clock % max / 10
					if enemy.clock % (max * 4) >= max * 2 then diffMod = (enemy.clock % max - 5) / 10 end
					spawnBullet(diffMod, enemy.clock % (max * 2) < max)
				end
			end
			ring()
			laser()
		end,
		function(enemy)
			local function ring()
				local count = 25
				local function spawnBullets(opposite)
					local angle = enemy.ringAngle
					if opposite then angle = angle + math.pi / count end
					local speed = 1
					for i = 1, count do
						stage.spawnBullet('biglight', enemy.x, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * speed,
								y = math.sin(angle) * speed
							}
						end)
						angle = angle + math.tau / count
					end
				end
				local interval = 50
				if enemy.clock == 0 then enemy.ringAngle = -math.pi / 2 end
				if enemy.clock % interval == 0 then spawnBullets(enemy.clock % (interval * 2) == 0) end
				enemy.ringAngle = math.pi / (count * 4)
			end
			local function balls()
				local function ball(opposite)
					local count = 20
					local angle = math.random() * math.tau
					local offset = grid * 3.25
					local x = enemy.x - bossOffset
					if opposite then x = enemy.x + bossOffset end
					for i = 1, count do
						stage.spawnBullet('bolt', x + math.cos(angle) * offset, enemy.y + math.sin(angle) * offset, function(bullet)
							bullet.axisAngle = angle
							bullet.speed = 2
							bullet.rotation = angle
						end, function(bullet)
							if not bullet.flipped then
								bullet.velocity = {
									x = math.cos(math.pi) * bullet.speed,
									y = math.sin(bullet.axisAngle)
								}
								bullet.axisAngle = bullet.axisAngle + 0.075
								bullet.speed = bullet.speed - .05
								if bullet.speed <= .5 then
									bullet.flipped = true
									local x, y = bullet:center()
									local angle = getAngle({x = x, y = y}, player)
									local speed = 3
									bullet.velocity = {
										x = math.cos(angle) * speed,
										y = math.sin(angle) * speed
									}
									bullet.rotation = angle
								end
							end
						end)
						angle = angle + math.tau / count
					end
					explosions.spawn({x = x, y = enemy.y}, true, true)
				end
				local interval = 75
				if enemy.clock % interval == 0 and enemy.clock >= interval then ball(enemy.clock % (interval * 2) == interval) end
			end
			ring()
			balls()
		end,
		function(enemy)
			local function arrows()
				local function spawnBullets()
					local angle = enemy.bulletAngle
					local speed = 2
					stage.spawnBullet('boltlight', enemy.x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.rotation = angle
					end)
				end
				local interval = 7
				local limit = interval * 20
				local max = limit * 2
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						local mod = .75
						enemy.bulletAngle = getAngle(enemy, player)
						enemy.bulletAngleMin = enemy.bulletAngle - mod
						enemy.bulletAngleMax = enemy.bulletAngle + mod
						enemy.bulletDirection = true
					end
					if enemy.bulletAngle then spawnBullets() end
					local diff = 0.15
					if enemy.bulletAngle and enemy.bulletAngleMin and enemy.bulletAngleMax then
						if enemy.bulletDirection then diff = diff * -1 end
						if enemy.bulletDirection and enemy.bulletAngle <= enemy.bulletAngleMin then enemy.bulletDirection = false
						elseif enemy.bulletAngle >= enemy.bulletAngleMax then enemy.bulletDirection = true end
						enemy.bulletAngle = enemy.bulletAngle + diff
					end
				end
			end
			local function ring()
				local function spawnBullets(opposite)
					local count = 25
					local angle = enemy.ringAngle
					local x = enemy.x - bossOffset
					if opposite then x = enemy.x + bossOffset end
					for i = 1, count do
						stage.spawnBullet('big', x, enemy.y, function(bullet)
							bullet.speed = 3
							bullet.angle = angle
						end, function(bullet)
							if bullet.speed > 1 then
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
								bullet.speed = bullet.speed - .05
							end
						end)
						angle = angle + math.tau / count
					end
					local mod = 0.05
					if opposite then mod = mod * -1 end
					enemy.ringAngle = enemy.ringAngle + mod
				end
				local interval = 75
				if enemy.clock == 0 then enemy.ringAngle = 0 end
				if enemy.clock % interval == 0 and enemy.ringAngle then
					spawnBullets()
					spawnBullets(true)
					explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
					explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
				end
			end
			arrows()
			ring()
		end,
		function(enemy)
			local function center()
				local function spawnBullets()
					local count = 5
					local angle = enemy.bulletAngle
					local speed = 1.75
					for i = 1, count do
						local bulletCount = 3
						local mod = 16
						for j = 1, bulletCount do
							local index = j - count
							local diff = grid
							local bulletAngle = angle + math.pi / 2
							local x = enemy.x + math.cos(bulletAngle) * index * diff
							local y = enemy.y + math.sin(bulletAngle) * index * diff
							stage.spawnBullet('arrow', x, y, function(bullet)
								bullet.visible = false
								bullet.velocity = {
									x = math.cos(angle) * speed,
									y = math.sin(angle) * speed
								}
								bullet.rotation = angle
							end, function(bullet)
								if bullet.clock >= 15 and not bullet.visible then bullet.visible = true end
							end)
						end
						angle = angle + math.tau / count
					end
				end
				local interval = 12
				local limit = interval * 3
				local max = limit
				local mod = math.pi / 7
				if enemy.clock == 0 then enemy.bulletAngle = math.pi - mod end
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then enemy.bulletAngle = enemy.bulletAngle + mod end
					spawnBullets()
				end
			end
			local function sides()
				local function spawnBullets(offset)
					local function spawnBullet(opposite, other)
						local x = enemy.x - bossOffset
						if other then
							x = enemy.x + bossOffset
						end
						local speed = 2
						local target = {x = enemy.bulletTarget, y = gameHeight}
						if opposite then target.x = enemy.bulletTarget + gameWidth end
						target.x = target.x + offset * (grid * 4)
						local angle = getAngle(enemy, target)
						stage.spawnBullet('bulletlight', x, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * speed,
								y = math.sin(angle) * speed
							}
							bullet.rotation = angle
						end)
					end
					spawnBullet()
					spawnBullet(true)
					spawnBullet(false, true)
					spawnBullet(true, true)
				end
				if enemy.clock == 0 then
					enemy.bulletTarget = 0
					enemy.bulletInitial = enemy.bulletTarget
					enemy.bulletCount = 2
				end
				local interval = 10
				local limit = interval * 5
				local max = limit * 3
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
						explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
					end
					local offset = math.cos(enemy.bulletCount) * grid
					local mod = 8 * dt
					enemy.bulletTarget = enemy.bulletInitial - offset
					enemy.bulletCount = enemy.bulletCount + mod
					spawnBullets(-1)
					spawnBullets(1)
				end
			end
			center()
			sides()
		end
	}
	local moves = {}
	if currentWave.clock == 0 then
		spawnBoss('cirno', attacks, moves, function()
			stage.killBullets = true
			gameOver = true
			wonGame = true
		end, function(enemy)
			sideSideMove(enemy)
		end)
	end
end)
