enemies = {}

local function enemyObj(func)
	return {
		clock = 0,
		func = func
	}
end

enemies.one = enemyObj(function()
	local function spawnEnemy()
		stage.spawnEnemy('fairyred', gameWidth / 2, -stage.enemyImages.fairyred:getHeight() / 2, function(enemy)
			enemy.angle = math.pi / 2
			enemy.speed = 2.5
		end, function(enemy)
			if enemy.speed > 0 then enemy.speed = enemy.speed - .05 end
			if enemy.speed < 0 then
				enemy.speed = 0
				enemy.y = math.floor(enemy.y)
			end
			enemy.velocity = {
				x = math.cos(enemy.angle) * enemy.speed,
				y = math.sin(enemy.angle) * enemy.speed
			}
		end)
	end
	if currentWave.clock == 0 then spawnEnemy() end
end)