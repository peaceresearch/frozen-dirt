collision = {}

local function killPlayer()
	stage.killBullets = true
	explosions.spawn(player, true, true)
	player.invulnerableClock = 60 * 4
	stage.killBullets = true
	stage.killBulletTimer = 60 * 2
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
		collision.check(hc.collisions(player.grazeCollider), 'bullet', function(bullet)
			if bullet.visible and not bullet.grazed then
				bullet.grazed = true
				currentGraze = currentGraze + 1
			end
		end)
		collision.check(hc.collisions(player.collider), 'enemy', killPlayer)
	end
end
