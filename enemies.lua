enemies = {}

local function enemyObj(func)
	return {
		clock = 0,
		func = func
	}
end

enemies.one = enemyObj(function()
	local function spawnEnemy()
		local angle = math.pi / 2
		local speed = 2
		stage.spawnEnemy('fairyred', gameWidth / 2, gameHeight / 2, function(enemy)
			enemy.velocity = {
				x = math.cos(angle) * speed,
				y = math.sin(angle) * speed
			}
			print(enemy.velocity.x, enemy.velocity.y)
		end)
	end
	if currentWave.clock == 0 then spawnEnemy() end
end)