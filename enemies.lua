enemies = {}

local function enemyObj(func)
	return {
		clock = 0,
		func = func
	}
end

enemies.one = enemyObj(function()

	local attacks = {

		function(enemy)

			local function burst()
				local function spawnBullet()
					stage.spawnBullet('red', enemy.x, enemy.y, function(bullet)
						bullet.speed = 6
						bullet.angle = math.pi * math.random()
					end, function(bullet)
						if bullet.speed > 4 then
							bullet.velocity = {
								x = math.cos(bullet.angle) * (bullet.speed * .75),
								y = math.sin(bullet.angle) * bullet.speed
							}
							bullet.speed = bullet.speed - .1
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
			burst()

			local function lasers()
				local function laser(speedOffset, opposite)
					print(speedOffset)
					local offset = enemy.laserOffset
					if opposite then offset = offset * -1 end
					local x = enemy.x - offset
					local angle = getAngle({x = x, y = enemy.y}, player)
					local mod = math.pi / 4
					angle = angle - mod * 2
					local speed = 4 + speedOffset / 2
					local count = 5
					for i = 1, count do
						stage.spawnBullet('bluebig', x, enemy.y, function(bullet)
							bullet.velocity = {
								x = math.cos(angle) * speed,
								y = math.sin(angle) * speed
							}
							-- bullet.rotation = angle
						end)
						angle = angle + mod
					end
				end
				local interval = 5
				local limit = interval * 5
				local max = limit * 3
				if enemy.clock == 0 then enemy.laserOffset = grid * 5 end
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					laser(enemy.clock % max / interval)
					laser(enemy.clock % max / interval, true)
				end
			end
			lasers()

		end

	}

	local function spawnEnemy()
		stage.spawnEnemy('fairyred', gameWidth / 2, -stage.enemyImages.fairyred:getHeight() / 2, function(enemy)
			enemy.angle = math.pi / 2
			enemy.speed = 2.5
			enemy.currentAttack = 1
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
		end)
	end
	if currentWave.clock == 0 then spawnEnemy() end

end)