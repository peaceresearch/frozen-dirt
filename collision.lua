collision = {}

local function killPlayer()
	if player.lives == 999 then
	elseif player.invulnerableClock <= 0 then
		stage.killBullets = true
		explosions.spawn(player, true, true)
		player.dieX = player.x
		player.dieY = player.y
		player.invulnerableClock = 60 * 4
		stage.killBullets = true
		stage.killBulletTimer = 60 * 2
		player.lives = player.lives - 1
	end
end

local function collectDrop(drop)
	drop.collected = true
end

collision.check = function(collider, type, func)
  for shape, delta in pairs(collider) do
    if shape.colliderType == type then func(shape) end
  end
end

collision.update = function()
	if player.invulnerableClock <= 0 then
		collision.check(hc.collisions(player.collider), 'bullet', function(bullet)
			-- if bullet.visible then killPlayer() end
		end)
		collision.check(hc.collisions(player.collider), 'enemy', killPlayer)
		collision.check(hc.collisions(player.grazeCollider), 'bullet', function(bullet)
			if bullet.visible and not bullet.grazed then
				bullet.grazed = true
				currentGraze = currentGraze + 1
				graze.spawn({x = player.x, y = player.y}, getAngle({x = bullet.x, y = bullet.y}, player))
				currentScore = currentScore + 1
			end
		end)
		collision.check(hc.collisions(player.grazeCollider), 'drop', collectDrop)
	end
end
