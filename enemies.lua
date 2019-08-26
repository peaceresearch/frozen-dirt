enemies = {}

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

enemies.one = enemyObj(function()

	local function iceOneSnow(enemy)
		local function spawnBullet(x)
			local diff = math.pi / 6
			stage.spawnBullet('small', x, enemy.y, function(bullet)
				local speed = 2.75
				local angle = math.pi - diff
				angle = angle - (math.pi - diff * 2) * math.random()
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.animatedByRotation = true
			end)
		end
		local interval = 4
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

	local function iceTwoIcicles(enemy)
		local function spawnBullet(x, angle)
			local speed = 5.5
			stage.spawnBullet('arrow', x, enemy.y, function(bullet)
				bullet.rotation = angle
				bullet.velocity = {
					x = math.cos(angle) * speed,
					y = math.sin(angle) * speed
				}
				bullet.animatedByFlip = true
			end)
		end
		local interval = 5
		local limit = interval * 5
		local max = limit * 2
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
		enemy.sidesActive = true
	end

	local attacks = {

		-- function(enemy)
		-- 	iceOneSnow(enemy)
		-- 	enemy.sidesActive = true
		-- end,

		-- function(enemy)
		-- 	iceOneSnow(enemy)
		-- 	local function spawnBullet(x)
		-- 		local diff = math.pi / 6
		-- 		stage.spawnBullet('bullet', x, enemy.y, function(bullet)
		-- 			local speed = 5
		-- 			local angle = math.pi / 2
		-- 			local mod = math.pi / 60
		-- 			angle = angle - mod + mod * 2 * math.random()
		-- 			bullet.rotation = angle
		-- 			bullet.velocity = {
		-- 				x = math.cos(angle) * speed,
		-- 				y = math.sin(angle) * speed
		-- 			}
		-- 			bullet.animatedByFlip = true
		-- 		end)
		-- 	end
		-- 	local interval = 2
		-- 	local limit = interval * 30
		-- 	local max = limit * 2
		-- 	if enemy.clock % interval == 0 and enemy.clock % max < limit then
		-- 		local diff = 4
		-- 		spawnBullet(enemy.x - bossOffset - diff)
		-- 		spawnBullet(enemy.x - bossOffset + diff)
		-- 		spawnBullet(enemy.x + bossOffset - diff)
		-- 		spawnBullet(enemy.x + bossOffset + diff)
		-- 	end
		-- 	enemy.sidesActive = true
		-- end,

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

		-- 	ring()
		-- 	shot()

		-- 	enemy.sidesActive = true
		-- end,

		-- function(enemy)
		-- 	iceTwoIcicles(enemy)
		-- end,

		-- function(enemy)
		-- 	local function spawnBullets(x)
		-- 		explosions.spawn({x = x, y = enemy.y}, true, true)
		-- 		local count = 15
		-- 		local angle = -math.pi / 2
		-- 		local speed = 3.25
		-- 		for i = 1, count do
		-- 			if angle > math.pi / 10 and angle < math.pi - math.pi / 10 then
		-- 				stage.spawnBullet('big2', x, enemy.y, function(bullet)
		-- 					bullet.velocity = {
		-- 						x = math.cos(angle) * speed,
		-- 						y = math.sin(angle) * speed
		-- 					}
		-- 					bullet.animatedByRotation = true
		-- 				end)
		-- 			end
		-- 			angle = angle + math.tau / count
		-- 		end
		-- 	end
		-- 	local interval = 60
		-- 	if enemy.clock % interval == 0 then
		-- 		spawnBullets(enemy.x - bossOffset)
		-- 		spawnBullets(enemy.x + bossOffset)
		-- 	end
		-- 	if enemy.clock >= 5 * 5 * 3 then iceTwoIcicles(enemy) end
		-- end,

		-- function(enemy)
		-- 	local function spawnBullets(x)
		-- 		local count = 31
		-- 		local angle = -math.pi / 2
		-- 		local speed = 3.5
		-- 		for i = 1, count do
		-- 			if angle > math.pi / 10 and angle < math.pi - math.pi / 10 then
		-- 				stage.spawnBullet('big', enemy.x, enemy.y, function(bullet)
		-- 					bullet.velocity = {
		-- 						x = math.cos(angle) * speed,
		-- 						y = math.sin(angle) * speed
		-- 					}
		-- 					bullet.animatedByRotation = true
		-- 				end)
		-- 			end
		-- 			angle = angle + math.tau / count
		-- 		end
		-- 	end
		-- 	local interval = 30
		-- 	if enemy.clock % interval == 0 then spawnBullets() end
		-- 	if enemy.clock >= 5 * 5 * 3 then iceTwoIcicles(enemy) end
		-- end,

		-- function(enemy)
		-- 	local function ring()
		-- 		local function spawnBullets()
		-- 			local angle = enemy.ringAngle
		-- 			local count = 17
		-- 			local speed = 3.25
		-- 			for i = 1, count do
		-- 				stage.spawnBullet('small', enemy.x + bossOffset, enemy.y, function(bullet)
		-- 					bullet.velocity = {
		-- 						x = math.cos(angle) * speed,
		-- 						y = math.sin(angle) * speed
		-- 					}
		-- 					bullet.animatedByRotation = true
		-- 				end)
		-- 				angle = angle + math.tau / count
		-- 			end
		-- 			enemy.ringAngle = enemy.ringAngle + .15
		-- 		end
		-- 		local interval = 15
		-- 		if enemy.clock == 0 then enemy.ringAngle = -math.pi / 2 end
		-- 		if enemy.clock % interval == 0 then spawnBullets() end
		-- 		if enemy.clock % (interval * 2) == 0 then explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true) end
		-- 	end
		-- 	local function arrows()
		-- 		local interval = 5
		-- 		local limit = interval * 5
		-- 		local max = limit * 3
		-- 		local function spawnBullet(opposite, hidden)
		-- 			local speed = 3.5
		-- 			speed = speed + (enemy.clock % max + 1) * .1
		-- 			local offset = grid - 2
		-- 			local angle = getAngle(enemy, enemy.arrowTarget)
		-- 			local offsetAngle = angle + math.pi / 2
		-- 			if opposite then offsetAngle = offsetAngle + math.pi end
		-- 			local x = enemy.x + math.cos(offsetAngle) * offset
		-- 			local y = enemy.y + math.sin(offsetAngle) * offset
		-- 			stage.spawnBullet('big2', x, y, function(bullet)
		-- 				bullet.velocity = {
		-- 					x = math.cos(angle) * speed,
		-- 					y = math.sin(angle) * speed
		-- 				}
		-- 				bullet.animatedByRotation = true
		-- 				if hidden then bullet.visible = false end
		-- 			end)
		-- 		end
		-- 		if enemy.clock % max == 0 then enemy.arrowTarget = {x = player.x, y = player.y} end
		-- 		if enemy.clock >= max and enemy.clock % interval == 0 and enemy.clock % max < limit then
		-- 			spawnBullet(false, true)
		-- 			spawnBullet()
		-- 			spawnBullet(true)
		-- 		end
		-- 	end
		-- 	local function spray()
		-- 		local function spawnBullets()
		-- 			explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
		-- 			local count = 5
		-- 			local mod = math.pi / 9
		-- 			local angle = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player) - mod * 2
		-- 			for i = 1, count do
		-- 				local speed = 3.25
		-- 				for j = 1, 5 do
		-- 					local jSpeed = speed + j * .25
		-- 					stage.spawnBullet('bullet', enemy.x - bossOffset, enemy.y, function(bullet)
		-- 						bullet.velocity = {
		-- 							x = math.cos(angle) * jSpeed,
		-- 							y = math.sin(angle) * jSpeed
		-- 						}
		-- 						bullet.rotation = angle
		-- 						bullet.animatedByFlip = true
		-- 					end)
		-- 				end
		-- 				angle = angle + mod
		-- 			end
		-- 		end
		-- 		local interval = 120
		-- 		if enemy.clock % interval == 0 and enemy.clock > interval then spawnBullets() end
		-- 	end
		-- 	ring()
		-- 	arrows()
		-- 	spray()
		-- 	enemy.sidesActive = true
		-- end,

		-- function(enemy)
		-- 	local function sweeper()
		-- 		local speed = 3.75
		-- 		local interval = 5
		-- 		local limit = interval * 10
		-- 		local max = limit * 2
		-- 		local sweepMod = math.pi / interval
		-- 		local sweepArea = math.pi - sweepMod * 2
		-- 		local function spawnBullet(opposite, mod)
		-- 			local offset = 8
		-- 			local offsetAngle = enemy.sweepAngle + math.pi / 2
		-- 			if opposite then offsetAngle = offsetAngle + math.pi end
		-- 			local x = enemy.x + math.cos(offsetAngle) * offset
		-- 			local y = enemy.y + math.sin(offsetAngle) * offset
		-- 			local speedMod = .4
		-- 			stage.spawnBullet('bolt', x, y, function(bullet)
		-- 				bullet.rotation = enemy.sweepAngle
		-- 				bullet.velocity = {
		-- 					x = math.cos(enemy.sweepAngle) * (speed + (mod * speedMod)),
		-- 					y = math.sin(enemy.sweepAngle) * (speed + (mod * speedMod))
		-- 				}
		-- 				bullet.animatedByFlip = true
		-- 				if mod == 0 then bullet.visible = false end
		-- 			end)
		-- 			if opposite and mod == 0 then
		-- 				local angleMod = sweepArea / (interval * 2)
		-- 				if enemy.sweepDirection == 1 then enemy.sweepAngle = enemy.sweepAngle + angleMod
		-- 				else enemy.sweepAngle = enemy.sweepAngle - angleMod end
		-- 			end
		-- 		end
		-- 		if enemy.clock == 0 then enemy.sweepDirection = 1 end
		-- 		if enemy.clock % interval == 0 and enemy.clock % max < limit then
		-- 			if enemy.clock % max == 0 then
		-- 				enemy.sweepDirection = -enemy.sweepDirection
		-- 				enemy.sweepAngle = math.pi - sweepMod
		-- 				if enemy.sweepDirection == 1 then enemy.sweepAngle = sweepMod end
		-- 			end
		-- 			for i = 1, 5 do
		-- 				spawnBullet(false, i - 1)
		-- 				spawnBullet(true, i - 1)
		-- 			end
		-- 		end
		-- 	end
		-- 	local function bolts() -- change to staggered?
		-- 		local function spawnBullets(mod, opposite, otherOpposite, hidden)
		-- 			local angle = enemy.boltAngleA
		-- 			local x = enemy.x - bossOffset
		-- 			if opposite then
		-- 				x = enemy.x + bossOffset
		-- 				angle = enemy.boltAngleB
		-- 			end
		-- 			local offset = 9
		-- 			local offsetAngle = angle + math.pi / 2
		-- 			if otherOpposite then offsetAngle = offsetAngle + math.pi end
		-- 			x = x + math.cos(offsetAngle) * offset
		-- 			y = enemy.y + math.sin(offsetAngle) * offset
		-- 			local speed = 3.25 + mod * .5
		-- 			stage.spawnBullet('bullet', x, y, function(bullet)
		-- 				bullet.rotation = angle
		-- 				bullet.velocity = {
		-- 					x = math.cos(angle) * speed,
		-- 					y = math.sin(angle) * speed
		-- 				}
		-- 				bullet.animatedByFlip = true
		-- 				if hidden then bullet.visible = false end
		-- 			end)
		-- 		end
		-- 		local interval = 5
		-- 		local limit = interval * 5
		-- 		local max = limit * 2
		-- 		if enemy.clock % interval == 0 and enemy.clock % max < limit then
		-- 			if enemy.clock % max == 0 then
		-- 				enemy.boltAngleA = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player)
		-- 				enemy.boltAngleB = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player)
		-- 				explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
		-- 				explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
		-- 			end
		-- 			local mod = enemy.clock % max / interval
		-- 			spawnBullets(mod, false, false, true)
		-- 			spawnBullets(mod)
		-- 			spawnBullets(mod, false, true)
		-- 			spawnBullets(mod, true)
		-- 			spawnBullets(mod, true,true)
		-- 		end
		-- 	end
		-- 	sweeper()
		-- 	bolts()
		-- 	enemy.sidesActive = true
		-- end,

		-- function(enemy)
		-- 	local function ring()
		-- 		local function spawnBullets()
		-- 			local count = 65
		-- 			local speed = 3.75
		-- 			local angle = getAngle(enemy, player) - math.pi / 2 + .025
		-- 			for i = 1, count do
		-- 				if i < count / 2 then
		-- 					local jCount = 5
		-- 					for j = 1, jCount do
		-- 						local jSpeed = speed + j * .35
		-- 						stage.spawnBullet('bullet', enemy.x, enemy.y, function(bullet)
		-- 							bullet.velocity = {
		-- 								x = math.cos(angle) * jSpeed,
		-- 								y = math.sin(angle) * jSpeed
		-- 							}
		-- 							bullet.animatedByFlip = true
		-- 							bullet.rotation = angle
		-- 							if i == 1 then bullet.visible = false end
		-- 						end)
		-- 					end
		-- 				end
		-- 				angle = angle + math.tau / count
		-- 			end
		-- 		end
		-- 		local interval = 60
		-- 		if enemy.clock % interval == 0 then spawnBullets() end
		-- 	end
		-- 	local function sides() -- stagger this too?
		-- 		local function laser(opposite, shakey)
		-- 			local angle = enemy.laserAngleA
		-- 			local speed = 5.5
		-- 			local x = enemy.x - bossOffset
		-- 			if opposite then
		-- 				x = enemy.x + bossOffset
		-- 				angle = enemy.laserAngleB
		-- 			end
		-- 			if shakey then
		-- 				local mod = .05
		-- 				angle = (angle - mod) + mod * 2 * math.random()
		-- 			end
		-- 			stage.spawnBullet('bolt', x, enemy.y, function(bullet)
		-- 				bullet.velocity = {
		-- 					x = math.cos(angle) * speed,
		-- 					y = math.sin(angle) * speed
		-- 				}
		-- 				bullet.rotation = angle
		-- 			end)
		-- 		end
		-- 		local interval = 5
		-- 		local limit = interval * 10
		-- 		local max = limit * 2
		-- 		if enemy.clock % interval == 0 and enemy.clock % max < limit then
		-- 			if enemy.clock % max == 0 then
		-- 				enemy.laserAngleA = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player)
		-- 				enemy.laserAngleB = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player)
		-- 			end
		-- 			local second = enemy.clock >= max
		-- 			laser(false, second)
		-- 			laser(true, second)
		-- 			if second then
		-- 				laser(false, true)
		-- 				laser(true, true)
		-- 			end
		-- 			if enemy.clock % (interval * 4) == 0 then
		-- 				explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true)
		-- 				explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true)
		-- 			end
		-- 		end
		-- 	end
		-- 	ring()
		-- 	sides()
		-- 	enemy.sidesActive = true
		-- end,
		-- 
		-- function(enemy)
		-- 	enemy.sidesActive = true
		-- 	local function spawnBullets(x)
		-- 		local mod = 5
		-- 		local angle = math.pi / 2
		-- 		local speed = 5
		-- 		local yMod = 4
		-- 		local function spawnBullet(sX)
		-- 			local y = enemy.y - yMod
		-- 			y = y + yMod * 2 * math.random()
		-- 			stage.spawnBullet('bullet', sX, y, function(bullet)
		-- 				bullet.velocity = {
		-- 					x = math.cos(angle) * speed,
		-- 					y = math.sin(angle) * speed
		-- 				}
		-- 				bullet.animatedByFlip = true
		-- 				bullet.rotation = angle
		-- 			end)
		-- 		end
		-- 		local offset = 5
		-- 		spawnBullet(x - offset)
		-- 		spawnBullet(x + offset)
		-- 	end
		-- 	local interval = 4
		-- 	local limit = interval * 2
		-- 	local max = limit * 2
		-- 	if enemy.clock % interval == 0 then
		-- 		local offset = grid * 2.25
		-- 		local pos = {
		-- 			enemy.x + bossOffset,
		-- 			enemy.x + bossOffset - offset,
		-- 			enemy.x + bossOffset - offset * 2
		-- 		}
		-- 		if enemy.clock % max >= limit then
		-- 			pos = {
		-- 				enemy.x - bossOffset,
		-- 				enemy.x - bossOffset + offset,
		-- 				enemy.x - bossOffset + offset * 2
		-- 			}
		-- 		end
		-- 		for i = 1, #pos do
		-- 			if enemy.clock % (interval * 2) == 0 then explosions.spawn({x = pos[i], y = enemy.y}, false, true) end
		-- 			spawnBullets(pos[i])
		-- 		end
		-- 	end
		-- end,
		
		function(enemy)
			local function spawnBullets()
				local speed = 3.5
				local function spawnRay(diff)
					local angle = -math.pi / 2
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
			local interval = 25
			if enemy.clock % interval == 0 then
				if enemy.clock == 0 then enemy.ringCount = 30 end
				spawnBullets()
				enemy.ringCount = enemy.ringCount + 1
			end
		end

	}

	local moves = {

		-- function(enemy)
		-- 	sideSideMove(enemy) 
		-- end,

		-- function(enemy)
		-- 	sideSideMove(enemy)
		-- end,

		-- function(enemy)
		-- 	returnToCenter(enemy)
		-- end,

		-- function(enemy)
		-- 	sideSideMove(enemy)
		-- end,

		-- function(enemy)
		-- 	sideSideMove(enemy)
		-- end,

		-- function(enemy)
		-- 	sideSideMove(enemy)
		-- end,

		-- function(enemy)
		-- 	sideSideMove(enemy)
		-- end,

		-- function(enemy)
		-- 	sideSideMove(enemy)
		-- end,

		-- function(enemy)
		-- 	returnToCenter(enemy)
		-- end,

		-- function(enemy)
		-- 	sideSideMove(enemy, true)
		-- end,

		function(enemy)
		end

	}

	if currentWave.clock == 0 then spawnBoss('cirno', attacks, moves) end

end)
