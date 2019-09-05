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
	if enemy.clock == 0 then
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

local function returnToCenter(enemy)
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
		local speed = 2.5
		local mod = math.pi / 15
		local angle = getAngle(enemy, player) - mod
		for i = 1, 3 do
			stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.animatedByRotation = true
			end)
			angle = angle + mod
		end
	end
	local function spawnEnemy(x, opposite)
		stage.spawnEnemy('fairyred', x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
			enemy.angle = math.pi / 2
			enemy.speed = 1.25
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
		spawnEnemy(gameWidth / 5)
		spawnEnemy(gameWidth - gameWidth / 5, true)
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
					bullet.speed = 4
					bullet.angle = angle
					bullet.animatedByRotation = true
				end, function(bullet)
					if bullet.speed > 2 then
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
			stage.spawnEnemy('fairyred', x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
				enemy.angle = math.pi / 2
				enemy.speed = 2.5
				enemy.health = 5
				enemy.bulletAngle = math.pi / 2
			end, function(enemy)
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
				local limit = .65
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
		local offset = grid * 3
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
			local speed = 3.5
			stage.spawnBullet('arrow', x, y, function(bullet)
				bullet.animatedByFlip = true
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
			stage.spawnEnemy('fairyred', x, -stage.enemyImages.fairyred.idle1:getHeight() / 2, function(enemy)
				enemy.angle = math.pi / 2
				enemy.speed = 2.75
				enemy.health = 5
			end, function(enemy)
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
				local limit = 1
				if enemy.speed > limit then
					enemy.speed = enemy.speed - .05
					enemy.clock = -1
				elseif enemy.speed <= limit then
					enemy.speed = limit
					local interval = 10
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
		local count = 25
		local angle = enemy.bulletAngle
		local speed = 2.5
		for i = 0, count do
			stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
				bullet.animatedByRotation = true
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
			enemy.speed = 3
			enemy.health = 15
		end, function(enemy)
			if enemy.speed > .5 then
				enemy.speed = enemy.speed - .075
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
				enemy.clock = -1
			else
				local interval = 10
				local limit = interval * 5
				local max = limit * 2
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
	stage.prepForBoss('stageOneBoss')
end)

enemies.stageOneBoss = enemyObj(function()

	local attacks = {
		function(enemy)
			local function snow()
				local function spawnBullet(x)
					local diff = math.pi / 10
					stage.spawnBullet('bullet', x, enemy.y, function(bullet)
						local speed = 2.75
						local angle = math.pi - diff
						angle = angle - (math.pi - diff * 2) * math.random()
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.rotation = angle
						-- bullet.animatedByRotation = true
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
					stage.spawnBullet('bolt-light', x, enemy.y, function(bullet)
						local speed = 4.75
						local angle = math.pi / 2
						local mod = math.pi / 60
						angle = angle - mod + mod * 2 * math.random()
						bullet.rotation = angle
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.animatedByFlip = true
					end)
				end
				local interval = 5
				if enemy.clock % interval == 0 then
					local diff = 4
					spawnBullet(enemy.x - bossOffset - diff)
					spawnBullet(enemy.x - bossOffset + diff)
					spawnBullet(enemy.x + bossOffset - diff)
					spawnBullet(enemy.x + bossOffset + diff)
				end
			end
			snow()
			spawnSecond(enemy, lasers)
		end,
		function(enemy)
			local function lasers()
				local function spawnBullet(x, angle)
					local mod = .015
					angle = angle - mod
					angle = angle + mod * 2 * math.random()
					local speed = 4
					stage.spawnBullet('arrow', x, enemy.y, function(bullet)
						bullet.rotation = angle
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.animatedByFlip = true
					end)
				end
				local interval = 8
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
					local count = 13
					local angle = -math.pi / 2
					local speed = 4
					for i = 1, count do
						if angle > math.pi / 10 and angle < math.pi - math.pi / 10 then
							stage.spawnBullet('big-light', x, enemy.y, function(bullet)
								bullet.angle = angle
								bullet.speed = speed
								bullet.animatedByRotation = true
							end, function(bullet)
								if bullet.speed > 2.5 then
									bullet.velocity = {
										x = math.cos(bullet.angle) * bullet.speed,
										y = math.sin(bullet.angle) * bullet.speed
									}
									bullet.speed = bullet.speed - .075
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
		end
	}

	local moves = {
		function(enemy)
			sideSideMove(enemy)
		end,
		function(enemy)
			sideSideMove(enemy)
		end
	}

	if currentWave.clock == 0 then
		spawnBoss('cirno', attacks, moves, function()
			stage.killBullets = true
			clearedStageClock = clearedStageLimit
		end)
	end

end)


-- STAGE 2
enemies.stageTwoWaveOne = enemyObj(function()
	local function spawnBullet(enemy)
		local angle = getAngle(enemy, player)
		local speed = 2.5
		stage.spawnBullet('big2', enemy.x, enemy.y, function(bullet)
			bullet.animatedByRotation = true
			bullet.velocity = {
				x = math.cos(angle) * speed,
				y = math.sin(angle) * speed
			}
			bullet.animatedByRotation = true
		end)
	end
	local function spawnEnemy(opposite)
		local x = -stage.enemyImages.fairyred.idle1:getWidth() / 2
		local y = grid * 2.5
		if opposite then
			x = gameWidth + stage.enemyImages.fairyred.idle1:getWidth() / 2
			y = grid * 6.5
		end
		stage.spawnEnemy('fairyred', x, y, function(enemy)
			local diff = math.pi / 30
			enemy.angle = 0 + diff
			if opposite then enemy.angle = math.pi - diff end
			enemy.speed = 3
			enemy.health = 3
		end, function(enemy)
			if enemy.speed > .75 then
				enemy.speed = enemy.speed - .05
				enemy.velocity = {
					x = math.cos(enemy.angle) * enemy.speed,
					y = math.sin(enemy.angle) * enemy.speed
				}
			end
			local interval = 30
			if enemy.clock % interval == 0 and enemy.clock > interval then spawnBullet(enemy) end
		end)
	end
	local interval = 65
	local limit = interval * 5
	if currentWave.clock % interval == 0 and currentWave.clock < limit then spawnEnemy() end
	if currentWave.clock % interval == 0 and currentWave.clock >= limit / 2 and currentWave.clock < limit * 1.5 then spawnEnemy(true) end
end)


--[[


		-- function(enemy)
		-- 	local function ring()
		-- 		local function spawnBullets(opposite, second)
		-- 			local count = 30
		-- 			local angle = -math.pi / 2
		-- 			local speed = 3.25
		-- 			if second then
		-- 				angle = angle + math.pi / count
		-- 				speed = speed + .75
		-- 			end
		-- 			local diff = math.tau / count * 2
		-- 			local x = enemy.x - bossOffset
		-- 			if opposite then x = enemy.x + bossOffset end
		-- 			for i = 1, count do
		-- 				if angle > diff and angle < math.pi - diff then
		-- 					stage.spawnBullet('bullet', x, enemy.y, function(bullet)
		-- 						bullet.velocity = {
		-- 							x = math.cos(angle) * speed,
		-- 							y = math.sin(angle) * speed
		-- 						}
		-- 						bullet.rotation = angle
		-- 					end)
		-- 				end
		-- 				angle = angle + math.tau / count
		-- 			end
		-- 		end
		-- 		local interval = 60
		-- 		local sInterval = 10
		-- 		if enemy.clock % interval == interval / 2 or enemy.clock % interval == interval / 2 + sInterval then
		-- 			local opposite = enemy.clock % (interval * 2) >= interval
		-- 			spawnBullets(opposite, enemy.clock % interval == interval / 2 + sInterval)
		-- 			if enemy.clock % interval == interval / 2 then
		-- 				local x = enemy.x - bossOffset
		-- 				if opposite then x = enemy.x + bossOffset end
		-- 				explosions.spawn({x = x, y = enemy.y}, true, true)
		-- 			end
		-- 		end
		-- 	end
		--
		-- 	local function shot()
		-- 		local function spawnBullets()
		-- 			local function spawnBullet(opposite, hidden)
		-- 				local angle = getAngle(enemy, player)
		-- 				local speed = 3.75
		-- 				local offset = grid
		-- 				local offsetAngle = angle + math.pi / 2
		-- 				if opposite then offsetAngle = offsetAngle + math.pi end
		-- 				local x = enemy.x + math.cos(offsetAngle) * offset
		-- 				local y = enemy.y + math.sin(offsetAngle) * offset
		-- 				stage.spawnBullet('big', x, y, function(bullet)
		-- 					bullet.velocity = {
		-- 						x = math.cos(angle) * speed,
		-- 						y = math.sin(angle) * speed
		-- 					}
		-- 					bullet.animatedByRotation = true
		-- 					if hidden then bullet.visible = false end
		-- 				end)
		-- 			end
		-- 			spawnBullet(false, true)
		-- 			spawnBullet()
		-- 			spawnBullet(true)
		-- 		end
		-- 		local interval = 60
		-- 		if enemy.clock % interval == 0 then spawnBullets() end
		-- 	end
		--
		-- 	ring()
		-- 	shot()
		--
		-- 	enemy.sidesActive = true
		-- end


	function(enemy)
		local function ring()
			local function spawnBullets()
				local angle = enemy.ringAngle
				local count = 17
				local speed = 3.25
				for i = 1, count do
					stage.spawnBullet('small', enemy.x + bossOffset, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.animatedByRotation = true
					end)
					angle = angle + math.tau / count
				end
				enemy.ringAngle = enemy.ringAngle + .15
			end
			local interval = 15
			if enemy.clock == 0 then enemy.ringAngle = -math.pi / 2 end
			if enemy.clock % interval == 0 then spawnBullets() end
			if enemy.clock % (interval * 2) == 0 then explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true) end
		end
		local function arrows()
			local interval = 5
			local limit = interval * 5
			local max = limit * 3
			local function spawnBullet(opposite, hidden)
				local speed = 3.5
				speed = speed + (enemy.clock % max + 1) * .1
				local offset = grid - 2
				local angle = getAngle(enemy, enemy.arrowTarget)
				local offsetAngle = angle + math.pi / 2
				if opposite then offsetAngle = offsetAngle + math.pi end
				local x = enemy.x + math.cos(offsetAngle) * offset
				local y = enemy.y + math.sin(offsetAngle) * offset
				stage.spawnBullet('big2', x, y, function(bullet)
					bullet.velocity = {
						x = math.cos(angle) * speed,
						y = math.sin(angle) * speed
					}
					bullet.animatedByRotation = true
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
					local speed = 3.25
					for j = 1, 5 do
						local jSpeed = speed + j * .25
						stage.spawnBullet('bullet', enemy.x - bossOffset, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * jSpeed,
								y = math.sin(angle) * jSpeed
							}
							bullet.rotation = angle
							bullet.animatedByFlip = true
						end)
					end
					angle = angle + mod
				end
			end
			local interval = 120
			if enemy.clock % interval == 0 and enemy.clock > interval then spawnBullets() end
		end
		ring()
		arrows()
		spray()
		enemy.sidesActive = true
	end,

	function(enemy)
		local function sweeper()
			local speed = 3.75
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
				local speedMod = .4
				stage.spawnBullet('bolt', x, y, function(bullet)
					bullet.rotation = enemy.sweepAngle
					bullet.velocity = {
						x = math.cos(enemy.sweepAngle) * (speed + (mod * speedMod)),
						y = math.sin(enemy.sweepAngle) * (speed + (mod * speedMod))
					}
					bullet.animatedByFlip = true
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
		local function bolts() -- change to staggered?
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
				local speed = 3.25 + mod * .5
				stage.spawnBullet('bullet', x, y, function(bullet)
					bullet.rotation = angle
					bullet.velocity = {
						x = math.cos(angle) * speed,
						y = math.sin(angle) * speed
					}
					bullet.animatedByFlip = true
					if hidden then bullet.visible = false end
				end)
			end
			local interval = 5
			local limit = interval * 5
			local max = limit * 2
			if enemy.clock % interval == 0 and enemy.clock % max < limit then
				if enemy.clock % max == 0 then
					enemy.boltAngleA = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player)
					enemy.boltAngleB = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player)
					explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
					explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
				end
				local mod = enemy.clock % max / interval
				spawnBullets(mod, false, false, true)
				spawnBullets(mod)
				spawnBullets(mod, false, true)
				spawnBullets(mod, true)
				spawnBullets(mod, true,true)
			end
		end
		sweeper()
		bolts()
		enemy.sidesActive = true
	end,

	function(enemy)
		local function ring()
			local function spawnBullets()
				local count = 65
				local speed = 3.75
				local angle = getAngle(enemy, player) - math.pi / 2 + .025
				for i = 1, count do
					if i < count / 2 then
						local jCount = 5
						for j = 1, jCount do
							local jSpeed = speed + j * .35
							stage.spawnBullet('bullet', enemy.x, enemy.y, function(bullet)
								bullet.velocity = {
									x = math.cos(angle) * jSpeed,
									y = math.sin(angle) * jSpeed
								}
								bullet.animatedByFlip = true
								bullet.rotation = angle
								if i == 1 then bullet.visible = false end
							end)
						end
					end
					angle = angle + math.tau / count
				end
			end
			local interval = 60
			if enemy.clock % interval == 0 then spawnBullets() end
		end
		local function sides() -- stagger this too?
			local function laser(opposite, shakey)
				local angle = enemy.laserAngleA
				local speed = 5.5
				local x = enemy.x - bossOffset
				if opposite then
					x = enemy.x + bossOffset
					angle = enemy.laserAngleB
				end
				if shakey then
					local mod = .05
					angle = (angle - mod) + mod * 2 * math.random()
				end
				stage.spawnBullet('bolt', x, enemy.y, function(bullet)
					bullet.velocity = {
						x = math.cos(angle) * speed,
						y = math.sin(angle) * speed
					}
					bullet.rotation = angle
				end)
			end
			local interval = 5
			local limit = interval * 10
			local max = limit * 2
			if enemy.clock % interval == 0 and enemy.clock % max < limit then
				if enemy.clock % max == 0 then
					enemy.laserAngleA = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player)
					enemy.laserAngleB = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player)
				end
				local second = enemy.clock >= max
				laser(false, second)
				laser(true, second)
				if second then
					laser(false, true)
					laser(true, true)
				end
				if enemy.clock % (interval * 4) == 0 then
					explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
					explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
				end
			end
		end
		ring()
		sides()
		enemy.sidesActive = true
	end,

	function(enemy)
		enemy.sidesActive = true
		local function spawnBullets(x)
			local mod = 5
			local angle = math.pi / 2
			local speed = 5
			local yMod = 4
			local function spawnBullet(sX)
				local y = enemy.y - yMod
				y = y + yMod * 2 * math.random()
				stage.spawnBullet('bullet', sX, y, function(bullet)
					bullet.velocity = {
						x = math.cos(angle) * speed,
						y = math.sin(angle) * speed
					}
					bullet.animatedByFlip = true
					bullet.rotation = angle
				end)
			end
			local offset = 5
			spawnBullet(x - offset)
			spawnBullet(x + offset)
		end
		local interval = 4
		local limit = interval * 2
		local max = limit * 2
		if enemy.clock % interval == 0 then
			local offset = grid * 2.25
			local pos = {
				enemy.x + bossOffset,
				enemy.x + bossOffset - offset,
				enemy.x + bossOffset - offset * 2
			}
			if enemy.clock % max >= limit then
				pos = {
					enemy.x - bossOffset,
					enemy.x - bossOffset + offset,
					enemy.x - bossOffset + offset * 2
				}
			end
			for i = 1, #pos do
				if enemy.clock % (interval * 2) == 0 then explosions.spawn({x = pos[i], y = enemy.y}, false, true) end
				spawnBullets(pos[i])
			end
		end
	end,

	function(enemy)
		local function spawnBullets()
			local speed = 4
			local function spawnRay(diff)
				local baseAngle = getAngle(enemy, player)
				local angle = baseAngle - math.pi
				local raySpeed = speed + .2 * diff
				for i = 1, enemy.ringCount do
					if angle > 0 and angle < math.pi then
						stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * raySpeed,
								y = math.sin(angle) * raySpeed
							}
							bullet.animatedByRotation = true
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
		local interval = 20
		local max = interval * 12
		local limit = max - interval
		if enemy.clock % interval == 0 and enemy.clock % max < limit then
			if enemy.clock % max == 0 then enemy.ringCount = 30 end
			spawnBullets()
			enemy.ringCount = enemy.ringCount + 3
		end
	end,

	function(enemy)
		enemy.sidesActive = true
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
			local speed = 5.5
			stage.spawnBullet('bolt', x, y, function(bullet)
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.animatedByFlip = true
				bullet.rotation = angle
			end)
		end
		local interval = 5
		local limit = interval * 3
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
	end,

	function(enemy)
		local function spawnBullets(x)
			local speed = 5
			local count = 15
			local angle = math.tau * math.random()
			for i = 1, (count + 1) do
				stage.spawnBullet('big', x, enemy.y, function(bullet)
					bullet.velocity = {
						x = math.cos(angle) * speed,
						y = math.sin(angle) * speed
					}
					bullet.animatedByRotation = true
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
		enemy.sidesActive = true
	end,

	function(enemy)
		local function laser()
			local speed = 5.25
			local function spawnBullet()
				angle = getAngle(enemy, enemy.laserTarget)
				-- local sSpeed = speed + enemy.laserCount * .25
				stage.spawnBullet('bolt', enemy.x, enemy.y, function(bullet)
					bullet.velocity = {
						x = math.cos(angle) * speed,
						y = math.sin(angle) * speed
					}
					bullet.rotation = angle
					bullet.animatedByFlip = true
					if i == 1 then bullet.visible = false end
				end)
			end
			local interval = 4
			local limit = interval * 15
			local max = interval * 25
			if enemy.clock % interval == 0 and enemy.clock % max < limit then
				if enemy.clock % max == 0 then
					enemy.laserTarget = {x = player.x, y = player.y}
					-- enemy.laserCount = 0
				end
				spawnBullet()
				-- enemy.laserCount = enemy.laserCount + 1
			end
		end
		local function sides()
			local function spawnBullets()
				local angle = enemy.bulletAngle
				local x = enemy.bulletX
				local count = 50
				local speed = 4
				local diff = math.pi / 5
				for i = 1, count do
					if angle < enemy.bulletAngle + diff or angle >= enemy.bulletAngle + math.tau - diff then
						stage.spawnBullet('small', x, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * speed,
								y = math.sin(angle) * speed
							}
							bullet.animatedByRotation = true
						end)
					end
					angle = angle + math.tau / count
				end
			end
			local interval = 10
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
		enemy.sidesActive = true
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
			local speed = 5.25
			for i = 1, count do
				stage.spawnBullet('bullet', x, enemy.y, function(bullet)
					bullet.velocity = {
						x = math.cos(angle) * speed,
						y = math.sin(angle) * speed
					}
					bullet.animatedByFlip = true
					bullet.rotation = angle
					-- if i == 1 then bullet.visible = false end
				end)
				angle = angle + math.tau / count
			end
		end
		local interval = 5
		local mod = .125
		if enemy.clock == 0 then
			enemy.bulletAngle = math.pi
			enemy.bulletAngleOther = math.pi
		end
		if enemy.clock % interval == 0 then
			if enemy.clock % (interval * 3) == 0 then
				explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
				explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
			end
			spawnBullets()
			spawnBullets(true)
			enemy.bulletAngle = enemy.bulletAngle + mod
			enemy.bulletAngleOther = enemy.bulletAngleOther - mod
		end
	end,

	function(enemy)
		local function spawnBullets()
			local distance = grid * 4.5
			local count = 5
			local angle = math.pi * 3
			local sCount = 15
			local speed = 4
			for i = 1, count do
				if i == enemy.currentSpawn then
					local x = enemy.x + math.cos(angle) * distance
					local y = enemy.y + math.sin(angle) * distance
					explosions.spawn({x = x, y = y}, true, true)
					local sAngle = enemy.bulletAngle
					for j = 1, sCount do
						stage.spawnBullet('bullet', x, y, function(bullet)
							bullet.velocity = {
								x = math.cos(sAngle) * speed,
								y = math.sin(sAngle) * speed
							}
							bullet.rotation = sAngle
							bullet.animatedByFlip = true
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
		local interval = 5
		if enemy.clock == 0 then
			enemy.currentSpawn = 1
			enemy.bulletAngle = math.pi * 3
		end
		if enemy.clock % interval == 0 then spawnBullets() end
	end,

	function(enemy)
		local function spawnBullets(opposite, isFat)
			local x = enemy.x - bossOffset
			local initAngle = enemy.initBulletAngle
			local angle = enemy.bulletAngle
			local count = 11
			local speed = 5
			local mod = math.pi / 25
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
					bullet.animatedByFlip = true
					if i == 1 then bullet.visible = false end
				end)
				angle = angle - enemy.bulletMod
			end
		end
		if enemy.clock == 0 then
			enemy.bulletAngle = getAngle({x = enemy.x - bossOffset, y = enemy.y}, {x = gameWidth * .75, y = gameHeight})
			enemy.bulletAngleOther = getAngle({x = enemy.x + bossOffset, y = enemy.y}, {x = gameWidth / 4, y = gameHeight})
			enemy.initBulletAngle = enemy.bulletAngle
			enemy.initBulletAngleOther = enemy.bulletAngleOther
			enemy.bulletDirection = false
			enemy.bulletMin = .135
			enemy.bulletMax = .215
			enemy.bulletMod = enemy.bulletMax
		end
		local interval = 5
		local limit = 60
		if enemy.clock % interval == 0 then
			local isFat = enemy.clock >= limit
			spawnBullets(false, isFat)
			spawnBullets(true, isFat)
			local expoLimit = interval * 4
			if enemy.clock % expoLimit == 0 then explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
			elseif enemy.clock % expoLimit == expoLimit / 2 then explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true) end

			local modMod = .005
			if enemy.bulletDirection then
				enemy.bulletMod = enemy.bulletMod + modMod
				if enemy.bulletMod > enemy.bulletMax then enemy.bulletDirection = false end
			else
				enemy.bulletMod = enemy.bulletMod - modMod
				if enemy.bulletMod <= enemy.bulletMin then enemy.bulletDirection = true end
			end

		end
	end,

	function(enemy)
		local count = 13
		local mod = math.pi / 20
		local speed = 5
		local function spawnBig()
			local angle = enemy.baseAngle + math.pi
			for i = 1, count do
				stage.spawnBullet('bolt', enemy.x, enemy.y, function(bullet)
					bullet.velocity = {
						x = math.cos(angle) * speed,
						y = math.sin(angle) * speed
					}
					bullet.rotation = angle
					bullet.animatedByFlip = true
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
					bullet.animatedByRotation = true
				end)
				angle = angle + mod
			end
		end
		local interval = 12
		if enemy.clock == 0 then
			enemy.baseAngle = math.pi / 4
			enemy.baseDirection = 1
		end
		local baseMod = .2
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
	end,

	function(enemy)
		local function blast()
			local function spawnBullets()
				local count = 160
				local speed = 4
				local angle = getAngle(enemy, player)
				local frac = 10
				for i = 0, count do
					if i == 0 or (i % (count / frac) < count / frac / 2 and i < count / 4) then
						local sAngle = a
						stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
							bullet.angle = angle - math.pi / 4.25
							bullet.speed = speed + math.random() * .05
							bullet.minSpeed = bullet.speed - 2
							bullet.animatedByRotation = true
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
			local interval = 60
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
				local speed = 3.5
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
						bullet.animatedByFlip = true
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
		local function ring()
			local function spawnBullets(opposite)
				local count = 45
				local angle = enemy.ringAngle - math.pi / 90
				local speed = 3
				if opposite then
					speed = 4.25
					angle = angle + math.pi / count
				end
				local diff = 1
				for i = 1, count do
					 -- and (i < count / 4 - diff or i > count / 4 + diff) and (opposite or (not opposite and (i > count / 4 + diff * 2 or i < count / 4 - diff)))
					if i < count / 2 then
						stage.spawnBullet('small', enemy.ringPos.x, enemy.ringPos.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * speed,
								y = math.sin(angle) * speed
							}
							bullet.animatedByRotation = true
							if i == 1 or (not opposite and i == 2) then bullet.visible = false end
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
					enemy.ringAngle = getAngle(enemy, player) - math.pi / 2
					enemy.ringPos = {x = enemy.x, y = enemy.y}
				end
				spawnBullets(enemy.clock % max > 0)
			end
		end
		local function ray()
			local function spawnBullets()
				local mod = math.pi / 15
				local count = 13
				local angle = enemy.ringAngle + math.pi / 2 - mod * math.floor(count / 2)
				local speed = 5
				for i = 1, count do
					stage.spawnBullet('bullet', enemy.ringPos.x, enemy.ringPos.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.rotation = angle
						bullet.animatedByFlip = true
					end)
					angle = angle + mod
				end
			end
			local interval = 5
			local limit = interval * 8
			local max = 20 * 2 * 2
			local start = interval * 2
			if enemy.clock % interval == 0 and enemy.clock % max < limit and enemy.clock % max >= start then
				spawnBullets()
			end
		end
		ring()
		ray()
	end,

	function(enemy)
		local function sideRays()
			local function spawnBullet(x)
				local speed = 6.5
				stage.spawnBullet('bolt', x, enemy.y, function(bullet)
					bullet.velocity = {
						x = math.cos(enemy.sideAngle) * speed,
						y = math.sin(enemy.sideAngle) * speed
					}
					bullet.rotation = enemy.sideAngle
					bullet.animatedByFlip = true
				end)
			end
			local interval = 5
			if enemy.clock % 15 == 0 then
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
				local speed = 3.5
				for i = 1, count do
					stage.spawnBullet('big', enemy.x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.animatedByRotation = true
					end)
					angle = angle + mod
				end
			end
			local interval = 40
			if enemy.clock % interval == 0 then spawnBullets(enemy.clock % (interval * 2) == 0) end
		end
		local function centerRay()
			local function spawnBullet()
				local mod = 0.035
				local angle = getAngle(enemy, player) - mod
				angle = angle + mod * 2 * math.random()
				local speed = 3
				stage.spawnBullet('small', enemy.x, enemy.y, function(bullet)
					bullet.velocity = {
						x = math.cos(angle) * speed,
						y = math.sin(angle) * speed
					}
					bullet.animatedByRotation = true
				end)
			end
			local interval = 20
			if enemy.clock % interval == 0 then spawnBullet() end
		end
		sideRays()
		ring()
		centerRay()
	end,

	function(enemy)
	end,

	function(enemy)
	end,

	function(enemy)
	end


]]



--[[



-- function(enemy)
-- 	returnToCenter(enemy)
-- end



	function(enemy)
		sideSideMove(enemy)
	end,

	function(enemy)
		sideSideMove(enemy)
	end,

	function(enemy)
		returnToCenter(enemy)
	end,

	function(enemy)
		sideSideMove(enemy, true)
	end,

	function(enemy)
		returnToCenter(enemy)
	end,

	function(enemy)
		returnToCenter(enemy)
	end,

	function(enemy)
		sideSideMove(enemy)
	end,

	function(enemy)
		sideSideMove(enemy, true)
	end,

	function(enemy)
		returnToCenter(enemy)
	end,

	function(enemy)
		sideSideMove(enemy)
	end,

	function(enemy)
		returnToCenter(enemy)
	end,

	function(enemy)
		sideSideMove(enemy)
	end,

	function(enemy)
		sideSideMove(enemy)
	end,

	function(enemy)
		sideSideMove(enemy)
	end,

	function(enemy)
		sideSideMove(enemy)
	end,

	function(enemy)
	end,

	function(enemy)
	end,

	function(enemy)
	end
]]
