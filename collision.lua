collision = {}

function collision.check(collider, type, func)
	for shape, delta in pairs(collider) do
		if shape.colliderType == type then func(shape) end
	end
end

function collision.update()

	if player.invulnerableClock <= 0 then

		-- collision.check(hc.collisions(player.collider), 'bullet', function(bullet)
		-- 	if bullet.visible then
		-- 		local x, y = bullet:center()
		-- 		explosions.spawn({x = x, y = y}, bullet.color == 'blue')
		-- 		bullet:moveTo(-globals.gameWidth, - globals.gameHeight)
		-- 		-- player.health = player.health - 20
		-- 		stage.killBullets = true
		-- 		player.invulnerableClock = 60 * 4
		-- 		player.graze = 0
		-- 		if player.health <= 0 then
		-- 			globals.gameOver = true
		-- 			globals.badEnding = true
		-- 			sound.stopBgm()
		-- 		end
		-- 	end
		-- end)
		--
		-- collision.check(hc.collisions(player.collider), 'enemy', function(enemy)
		-- 	explosions.spawn({x = player.x, y = player.y})
		-- 	enemy.health = enemy.health - 1
		-- 	-- player.health = player.health - 20
		-- 	stage.killBullets = true
		-- 	player.invulnerableClock = 60 * 4
		-- 	player.graze = 0
		-- 	if player.health <= 0 then
		-- 		globals.gameOver = true
		-- 		globals.badEnding = true
		-- 		sound.stopBgm()
		-- 	end
		-- end)

	end

	-- collision.check(hc.collisions(player.grazeCollider), 'bullet', function(bullet)
	-- 	if bullet.visible then
	-- 		if not bullet.grazed and not player.releasing then
	-- 			bullet.grazed = true
	-- 			local x, y = bullet:center()
	-- 			graze.spawn({x = player.x, y = player.y}, globals.getAngle({x = x, y = y}, player), bullet.color)
	-- 			player.graze = player.graze + 1
	-- 			player.score = player.score + 0.001
	-- 		end
	-- 	end
	-- end)
	--
	-- if player.releasing then
	-- 	collision.check(hc.collisions(player.releaseCollider), 'bullet', function(bullet)
	-- 		local x, y = bullet:center()
	-- 		explosions.spawn({x = x, y = y}, bullet.color == 'blue')
	-- 		bullet:moveTo(-globals.gameWidth, - globals.gameHeight)
	-- 	end)
	-- end

end
