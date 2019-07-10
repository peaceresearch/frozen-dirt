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

		end,

		function(enemy)
			local function circle()
				local function spawnBullets()
					local count = 9
					local angle = enemy.bulletAngle
					for i = 1, count + 1 do
						stage.spawnBullet('redbig', enemy.x, enemy.y, function(bullet)
							bullet.angle = angle
							bullet.speed = 7
						end, function(bullet)
							if bullet.speed > 5 then
								bullet.speed = bullet.speed - .05
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
							end
						end)
						angle = angle + math.tau / count
					end
					enemy.bulletAngle = enemy.bulletAngle + enemy.bulletMod
				end
				local interval = 3
				local limit = interval * 12
				local max = limit * 2
				if enemy.clock == 0 then
					enemy.bulletAngle = -math.pi / 2
					enemy.bulletMod = 0.02
				end
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						enemy.bulletAngle = enemy.bulletAngle + .25
					end
					if enemy.clock % max == limit / 2 then enemy.bulletMod = enemy.bulletMod * -1 end
					spawnBullets()
				end
			end
			circle()
			local function spray()
				local function spawnBullets()
					local count = 15
					local angle = -math.pi / 2
					for i = 1, count do
						stage.spawnBullet('bluebig', enemy.x, enemy.y, function(bullet)
							bullet.angle = angle
							bullet.speed = 6.5
							bullet.speedMod = .2 - math.random() * .075
						end, function(bullet)
							if not bullet.flipped then
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
								bullet.speed = bullet.speed - bullet.speedMod;
								if bullet.speed <= 0 then
									bullet.speed = 0
									bullet.clock = -1
									bullet.velocity = false
									bullet.flipped = true
								end
							elseif bullet.clock >= 60 then
								if bullet.clock == 60 then
									bullet.angle = getAngle(bullet, player)
								end
								if bullet.speed < 5.25 then
									bullet.velocity = {
										x = math.cos(bullet.angle) * bullet.speed,
										y = math.sin(bullet.angle) * bullet.speed
									}
									bullet.speed = bullet.speed + 0.1
								end
							end
						end)
						angle = angle + math.tau / count
					end
				end
				local interval = 60 * 4
				if enemy.clock % interval == interval / 4 then spawnBullets() end
			end
			spray()
			local function arrows()
				local function spawnBullets(opposite)
					local count = 15
					local angle = getAngle(enemy, player) - math.pi / 2
					for i = 1, count + 1 do
						stage.spawnBullet('bluearrow', enemy.x, enemy.y, function(bullet)
							bullet.angle = angle
							bullet.speed = 3.5
							bullet.initial = angle
							if opposite then bullet.opposite = true end
							if i == 1 then bullet.visible = false end
						end, function(bullet)
							if bullet.flipped and bullet.clock == 60 then
								bullet.speed = 3.5
								if bullet.opposite then
									bullet.angle = bullet.angle + math.pi
								else
									bullet.angle = bullet.angle + bullet.mod
								end
							elseif not bullet.flipped then
								local limit = bullet.initial + math.pi
								if bullet.angle < limit then
									bullet.mod = math.pi / 30
									bullet.angle = bullet.angle + bullet.mod
								elseif bullet.angle >= limit then
									bullet.angle = limit
									bullet.speed = 0
									bullet.flipped = true
									bullet.clock = -1
								end
							end
							bullet.velocity = {
								x = math.cos(bullet.angle) * bullet.speed,
								y = math.sin(bullet.angle) * bullet.speed
							}
							bullet.rotation = bullet.angle
						end)
						angle = angle + math.tau / count
					end
				end
				local interval = 60
				if enemy.clock % interval == 0 then
					spawnBullets()
					spawnBullets(true)
				end
			end
			arrows()
		end,

		function(enemy)
			local function curvy()
				local function spawnBullets()
					local angle = enemy.curvyAngle
					local count = 11
					for i = 1, count do
						stage.spawnBullet('redarrow', enemy.x, enemy.y, function(bullet)
							bullet.initial = angle
							bullet.angle = angle
							bullet.count = 0
							bullet.speed = 11
						end, function(bullet)
							bullet.angle = bullet.initial + math.sin(bullet.count * 2)
							bullet.count = bullet.count + 0.035
							bullet.rotation = bullet.angle
							if bullet.speed > 4 then bullet.speed = bullet.speed - .5 end
							bullet.velocity = {
								x = math.cos(bullet.angle) * bullet.speed,
								y = math.sin(bullet.angle) * bullet.speed
							}
						end)
						angle = angle + math.tau / count
					end
				end
				local interval = 5
				local limit = interval * 10
				local max = limit * 2
				if enemy.clock == 0 then enemy.curvyAngle = -math.pi / 2 end
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then enemy.curvyAngle = enemy.curvyAngle + .15 end
					spawnBullets()
				end
			end
			local function circle()
				local function spawnBullets()
					local angle = math.tau * math.random()
					local count = 25
					for i = 1, count do
						stage.spawnBullet('bluebig', enemy.x, enemy.y, function(bullet)
							bullet.speed = 5
							bullet.angle = angle
						end, function(bullet)
							if bullet.speed > 3 then
								bullet.speed = bullet.speed - .1
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
							end
						end)
						angle = angle + math.tau / count
					end
				end
				local interval = 25
				local limit = interval * 3
				local max = interval * 5
				if enemy.clock % interval == 0 and enemy.clock % max < limit then spawnBullets() end
			end
			curvy()
			circle()
		end,

		function(enemy)
			local function circle()
				local function spawnBullets(opposite, other)
					local angle = -math.pi / 2
					local count = 20
					local speed = 6
					local x = enemy.x - bossOffset
					if other then
						speed = speed - 1.25
						angle = angle + math.pi / count
					end
					if opposite then
						x = enemy.x + bossOffset
					end
					for i = 1, count do
						stage.spawnBullet('bluebig', x, enemy.y, function(bullet)
							bullet.speed = speed
							bullet.speedMin = speed - 2
							bullet.angle = angle
						end, function(bullet)
							if bullet.speed > bullet.speedMin then
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
								bullet.speed = bullet.speed - .15
							end
						end)
						angle = angle + math.tau / count
					end
				end
				local interval = 30
				if enemy.clock % interval == 0 then
					local explosionX = enemy.x - bossOffset
					if enemy.clock % (interval * 2) == 0 then explosionX = enemy.x + bossOffset end
					explosions.spawn({x = explosionX, y = enemy.y}, true, true, false, true)
					spawnBullets(enemy.clock % (interval * 2) == 0, enemy.clock % (interval * 4) < interval * 2)
				end
			end
			circle()
			local function arrows()
				local function spawnBullets()
					local mod = .38
					local angle = enemy.bulletAngle - mod * 2
					for i = 1, 5 do
						stage.spawnBullet('redarrow', enemy.x, enemy.y, function(bullet)
							bullet.speed = 5
							bullet.angle = angle
							bullet.velocity = {
								x = math.cos(bullet.angle) * bullet.speed,
								y = math.sin(bullet.angle) * bullet.speed
							}
							bullet.rotation = angle
						end)
						angle = angle + mod
					end
				end
				local interval = 4
				local limit = interval * 20
				if enemy.clock % limit >= limit / 2 and enemy.clock % limit < limit * .75 and enemy.clock % interval == 0 then
					if enemy.clock % limit == limit / 2 then enemy.bulletAngle = getAngle(enemy, player) end
					spawnBullets()
				end
			end
			arrows()
		end,

		function(enemy)
			local function splash()
				local function spawnBullet(opposite)
					local count = 20
					local angle = enemy.splashAngle
					local x = enemy.x - bossOffset
					if opposite then x = enemy.x + bossOffset end
					for i = 1, count do
						stage.spawnBullet('blue', x, enemy.y, function(bullet)
							bullet.speed = 6
							bullet.angle = angle
						end, function(bullet)
							if bullet.speed > 4 then
								bullet.speed = bullet.speed - .1
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
							end
						end)
						angle = angle + math.tau / count
					end
				end
				local interval = 3
				local limit = interval * 6
				local max = limit * 2.5
				if enemy.clock == 0 then enemy.splashAngle = -math.pi / 2 end
				if enemy.clock % max == 0 then
					enemy.splashAngle = enemy.splashAngle + .1
					explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true, false, true)
					explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true, false, true)
				end
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					spawnBullet()
					spawnBullet(true)
				end
			end
			local function barf()
				local function spawnBullets()
					local count = 50
					local angle = math.tau * math.random()
					for i = 1, count do
						if angle % math.tau < math.pi then
							local img = 'red'
							if math.random() >= .75 then img = 'redbig' end
							stage.spawnBullet(img, enemy.x, enemy.y, function(bullet)
								bullet.speedMod = math.random()
								bullet.speed = 4 + bullet.speedMod
								bullet.angle = angle
							end, function(bullet)
								if bullet.speed > 1.5 + bullet.speedMod then
									bullet.speed = bullet.speed - .1
									bullet.velocity = {
										x = math.cos(bullet.angle) * bullet.speed,
										y = math.sin(bullet.angle) * bullet.speed
									}
								end
							end)
						end
						angle = angle + math.pi * math.random()
					end
				end
				local interval = 90
				if enemy.clock % interval == 0 then spawnBullets() end
			end
			splash()
			barf()
		end,

		function(enemy)
			local maxSpeed = 4
			local minSpeed = 1.5
			local speedMod = .035
			local function spawnBig()
				local function spawnBullet()
					if enemy.bulletAngle % math.tau >= 0 and enemy.bulletAngle % math.tau < math.pi then
						stage.spawnBullet('bluebig', enemy.x, enemy.y, function(bullet)
							bullet.speed = maxSpeed
							bullet.angle = enemy.bulletAngle
						end, function(bullet)
							if bullet.speed > minSpeed then
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
								bullet.speed = bullet.speed - speedMod
							end
						end)
					end
					enemy.bulletAngle = enemy.bulletAngle + math.pi * math.random()
				end
				if enemy.clock == 0 then enemy.bulletAngle = 0 end
				if enemy.clock % 2 == 0 then spawnBullet() end
			end
			local function spawnSmall()
				local function spawnBullet(opposite)
					if enemy.bulletAngle % math.tau >= 0 and enemy.bulletAngle % math.tau < math.pi then
						local x = enemy.x - bossOffset
						if opposite then x = enemy.x + bossOffset end
						stage.spawnBullet('blue', x, enemy.y, function(bullet)
							bullet.speed = maxSpeed
							bullet.angle = enemy.bulletAngle
						end, function(bullet)
							if bullet.speed > minSpeed then
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
								bullet.speed = bullet.speed - speedMod
							end
						end)
					end
					enemy.bulletAngle = enemy.bulletAngle + math.pi * math.random()
				end
				if enemy.clock == 0 then enemy.bulletAngle = math.tau * math.random() end
				if enemy.clock % 2 == 0 then
					spawnBullet()
					spawnBullet(true)
				end
				if enemy.clock % 15 == 0 then
					explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true, false, true)
					explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true, false, true)
				end
			end
			spawnBig()
			spawnSmall()
		end,

		function(enemy)
			local function worm()
				local function spawnBullet(xOffset, yOffset)
					local mod = 16
					local x = enemy.x + mod * xOffset
					local y = enemy.y + mod * yOffset
					local source = {
						x = x, y = y
					}
					local target = {
						x = player.x - mod * xOffset,
						y = player.y - mod * yOffset
					}
					local angle = getAngle(enemy, player)
					local speed = enemy.bulletSpeed
					stage.spawnBullet('redbig', x, y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
					end)
				end
				local function ring()
					local count = 80
					local angle = math.tau * math.random()
					for i = 1, count do
						local bulletType = 'red'
						if i % 4 == 0 then bulletType = 'redbig' end
						if angle % math.tau > 0 and angle % math.tau < math.pi then
							stage.spawnBullet(bulletType, enemy.x, enemy.y, function(bullet)
								bullet.diff = 1 * math.random()
								bullet.speed = bullet.diff + 4
								bullet.angle = angle
							end, function(bullet)
								if bullet.speed > bullet.diff + 1.5 then
									bullet.velocity = {
										x = math.cos(bullet.angle) * bullet.speed,
										y = math.sin(bullet.angle) * bullet.speed
									}
									bullet.speed = bullet.speed - 0.1
								end
							end)
						end
						angle = angle + math.tau * math.random()
					end
				end
				local interval = 4
				local max = 204
				if enemy.clock % interval == 0 and enemy.clock % max >= math.floor(max / 3 * 2) then
					if enemy.clock % max == math.floor(max / 3 * 2) then
						enemy.bulletSpeed = 2.5
						ring()
					end
					if enemy.clock % max < max - 40 and enemy.bulletSpeed then
						spawnBullet(-1, 0)
						spawnBullet(0, 1)
						spawnBullet(0, -1)
						spawnBullet(1, 0)
						spawnBullet(0, 0)
						enemy.bulletSpeed = enemy.bulletSpeed + .3
					end
				end
			end
			local function arrows(other)
				local y = enemy.y
				local x = enemy.x - bossOffset
				if other then x = enemy.x + bossOffset end
				local function spawnBullets(opposite)
					local count = 3
					local angle = enemy.bulletAngleA
					if other then angle = enemy.bulletAngleB end
					local mod = 0.15
					angle = angle - mod * ((count - 1) / 2)
					if opposite then angle = angle + mod / 2 end
					local function spawnGroup(offset)
						local sAngle = angle
						local sMod = math.pi / 4
						sAngle = sAngle + sMod * offset
						local sCount = 3
						for i = 1, sCount do
							stage.spawnBullet('bluearrow', x, y, function(bullet)
								bullet.speed = 5.5
								bullet.rotation = sAngle
								bullet.angle = sAngle
							end, function(bullet)
								if bullet.speed > 2.5 then
									bullet.speed = bullet.speed - .1
									bullet.velocity = {
										x = math.cos(bullet.angle) * bullet.speed,
										y = math.sin(bullet.angle) * bullet.speed
									}
								end
							end)
							sAngle = sAngle + mod
						end
					end
					spawnGroup(-1)
					spawnGroup(1)
					spawnGroup(0)
				end
				local interval = 5
				local max = 200
				local offset = 40
				if enemy.clock % max == offset and other then explosions.spawn({x = x, y = y}, true, true, false, true)
				elseif enemy.clock % max == max / 2 and not other then explosions.spawn({x = x, y = y}, true, true, false, true) end
				if enemy.clock % interval == 0 then
					if other and enemy.clock % max < math.floor(max / 3) - offset / 2 then
						if enemy.clock % max == 0 then
							enemy.bulletAngleA = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player)
							enemy.bulletAngleB = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player)
						end
						if enemy.clock % interval == 0 and enemy.clock % max > offset / 2 then
							spawnBullets(enemy.clock % (interval * 2) == 0)
						end
					elseif not other and enemy.clock % max >= math.floor(max / 3) and enemy.clock % max < math.floor(max / 3 * 2) - offset / 2 then
						if enemy.clock % max == math.floor(max / 3) then
							enemy.bulletAngleA = getAngle({x = enemy.x - bossOffset, y = enemy.y}, player)
							enemy.bulletAngleB = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player)
						end
						if enemy.clock % interval == 0 and enemy.clock % max > math.floor(max / 3) + offset / 2 then
							spawnBullets(enemy.clock % (interval * 2) == 0)
						end
					end
				end
			end
			worm()
			arrows()
			arrows(true)
		end,

		function(enemy)
			local function rings()
				local count = 15
				local angle = enemy.bulletAngle
				local mod = 0.0067
				local limit = 1.5
				local function ringRed()
					for i = 1, count do
						stage.spawnBullet('redbig', enemy.x, enemy.y, function(bullet)
							bullet.speed = 3
							bullet.angle = angle
							bullet.initAngle = angle
							if enemy.bulletDir == 1 then bullet.opposite = true end
						end, function(bullet)
							bullet.velocity = {
								x = math.cos(bullet.angle) * bullet.speed,
								y = math.sin(bullet.angle) * bullet.speed
							}
							bullet.rotation = bullet.angle
							if bullet.opposite and bullet.angle < bullet.initAngle + limit then
								bullet.angle = bullet.angle + mod
							elseif not bullet.opposite and bullet.angle > bullet.initAngle - limit then
								bullet.angle = bullet.angle - mod
							end
						end)
						angle = angle + math.tau / count
					end
				end
				local function ringBlue()
						for i = 1, count do
							stage.spawnBullet('bluebig', enemy.x, enemy.y, function(bullet)
								bullet.speed = enemy.bulletBaseSpeed
								bullet.angle = angle
								bullet.initAngle = angle
								if enemy.bulletDir == 1 then bullet.opposite = true end
							end, function(bullet)
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
								if not bullet.opposite and bullet.angle < bullet.initAngle + limit then
									bullet.angle = bullet.angle + mod
								elseif bullet.opposite and bullet.angle > bullet.initAngle - limit then
									bullet.angle = bullet.angle - mod
								end
							end)
							angle = angle + math.tau / count
						end
						enemy.bulletBaseSpeed = enemy.bulletBaseSpeed + .33
				end
				ringRed()
				ringBlue()
			end
			local interval = 10
			local limit = interval * 5
			local max = limit * 2
			if enemy.clock == 0 then enemy.bulletDir = 1 end
			if enemy.clock % interval == 0 then
				if enemy.clock % max == 0 and enemy.bulletDir then
					enemy.bulletDir = enemy.bulletDir * -1
					enemy.bulletAngle = getAngle(enemy, player) + math.tau * math.random()
					enemy.bulletBaseSpeed = 2
				end
				if enemy.clock % max < limit and enemy.bulletBaseSpeed and enemy.bulletAngle then rings() end
			end
		end,

		function(enemy)
			local function spawnRing()
				local interval = 90
				local offset = 10
				local limit = offset * 4
				local function ring(opposite)
					local count = 60
					local angle = enemy.bulletAngle
					local diff = 12
					for i = 1, count do
						if i % 6 < 3 then
							stage.spawnBullet('redbig', enemy.x, enemy.y, function(bullet)
								bullet.angle = angle
								bullet.angleInit = angle
								bullet.speed = 5
								bullet.limit = 3
								bullet.mod = .1
								bullet.angleMod = 0.0125
								if opposite then
									bullet.angleMod = bullet.angleMod * -1
									bullet.opposite = true
								end
							end, function(bullet)
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
								if bullet.speed > bullet.limit then bullet.speed = bullet.speed - bullet.mod
								elseif bullet.speed < bullet.limit then bullet.speed = bullet.limit end
								if (bullet.angle < bullet.angleInit + 1 and not bullet.opposite) or (bullet.angle > bullet.angleInit - 1 and bullet.opposite) then
									bullet.angle = bullet.angle + bullet.angleMod
								end
							end)
						end
						angle = angle + math.tau / count
					end
				end
				if enemy.clock % interval == 0 then enemy.bulletAngle = getAngle(enemy, player) - math.pi end
				if enemy.clock % interval <= limit / 2 and enemy.clock % offset == 0 and enemy.clock >= interval then
					ring(enemy.clock % (interval * 2) >= interval)
				end
			end
			local function spawnArrows()
					local interval = 80
					local offset = 8
					local limit = offset * 4
					local function arrows(enemy, opposite)
						local count = 5
						local x = enemy.x
						local y = enemy.y
						if opposite then x = x + bossOffset
						else x = x - bossOffset end
						explosions.spawn({x = x, y = y}, true, true, false, true)
						local mod = 0.25
						local angle = getAngle({x = x, y = y}, enemy.arrowTarget)
						angle = angle - mod * 2
						for i = 1, count do
							stage.spawnBullet('bluearrow', x, y, function(bullet)
								if enemy.opposite then bullet.angle = angle + enemy.arrowOffset
								else 	bullet.angle = angle - enemy.arrowOffset end
								bullet.velocity = {
									x = math.cos(bullet.angle) * enemy.arrowSpeed,
									y = math.sin(bullet.angle) * enemy.arrowSpeed
								}
								bullet.rotation = bullet.angle
							end, function(bullet)
							end)
							angle = angle + mod
						end
						enemy.arrowSpeed = enemy.arrowSpeed + .3
						enemy.arrowOffset = enemy.arrowOffset + 0.01
					end
					if enemy.clock % offset == 0 then
						if enemy.clock % interval == 0 or enemy.clock % interval == interval / 2 then
							enemy.arrowTarget = {x = player.x, y = player.y}
							enemy.arrowSpeed = 2.5
							enemy.arrowOffset = 0
						end
						if enemy.clock % interval < limit then arrows(enemy, enemy.clock % (interval * 2) >= interval) end
					end
			end
			spawnRing()
			spawnArrows()
		end,

		function(enemy)
			local function burst()
				local function spawnBullet()
					stage.spawnBullet('red', enemy.x, enemy.y, function(bullet)
						bullet.speed = 6
						bullet.angle = math.pi / 8 * 6 * math.random() + math.pi / 8
					end, function(bullet)
						if bullet.speed > 3 then
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
				end
			end
			local function lasers()
				local function laser(speedOffset, opposite, bulletOpposite)
					local x = enemy.x - bossOffset
					local bulletMod = math.pi / 4
					if opposite then
						x = enemy.x + bossOffset
					end
					local angle = getAngle({x = x, y = enemy.y}, player) - bulletMod
					for i = 1, 3 do
						stage.spawnBullet('bluebig', x, enemy.y, function(bullet)
							bullet.speed = 3 + speedOffset / 4
							bullet.velocity = {
								x = math.cos(angle) * bullet.speed,
								y = math.sin(angle) * bullet.speed
							}
						end)
						angle = angle + bulletMod
					end
				end
				local interval = 5
				local limit = interval * 5
				local max = limit * 3
				if enemy.clock % max == 0 then
					explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true, false, true)
					explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true, false, true)
				end
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					laser(enemy.clock % max / interval, false, enemy.clock % (max * 2) < max)
					laser(enemy.clock % max / interval, true, enemy.clock % (max * 2) >= max)
				end
			end
			burst()
			lasers()
		end,

		function(enemy)
			local function spawnBullets(opposite, other)
				local angle = enemy.bulletAngleA
				local x = enemy.x - bossOffset
				local img = 'redarrow'
				if other then
					angle = enemy.bulletAngleB
					x = enemy.x + grid * 8
					img = 'bluearrow'
				end
				explosions.spawn({x = x, y = enemy.y}, other, true, false, true)
				local mod = math.pi / 15
				angle = angle - mod * math.floor(enemy.bulletCount / 2)
				if opposite then angle = angle + mod / 2 end
				for i = 1, enemy.bulletCount do
					stage.spawnBullet(img, x, enemy.y, function(bullet)
						bullet.rotation = angle
						bullet.angle = angle
						bullet.speed = 5
					end, function(bullet)
						if bullet.speed > 1.75 then
							bullet.velocity = {
								x = math.cos(bullet.angle) * bullet.speed,
								y = math.sin(bullet.angle) * bullet.speed
							}
							bullet.speed = bullet.speed - .033
						end
					end)
					angle = angle + mod
				end
				if enemy.bulletCount < 15 then enemy.bulletCount = enemy.bulletCount + 1 end
			end
			if enemy.clock == 0 then
				enemy.bulletCount = 5
				enemy.bulletAngleA = getAngle({x = enemy.x - bossOffset, y = enemy.y}, {x = gameWidth, y = gameHeight})
				enemy.bulletAngleB = getAngle({x = enemy.x + bossOffset, y = enemy.y}, {x = 0, y = gameHeight})
			end
			local interval = 25
			if enemy.clock % interval == 0 then
				spawnBullets(enemy.clock % (interval * 2) == 0)
				spawnBullets(enemy.clock % (interval * 2) == 0, true)
			end
		end,

		function(enemy)
			local function spawnCenter()
				local function triangle()
					local count = 5
					local angle = enemy.bulletAngle
					local speed = 3.75
					for i = 1, count do
						local bulletCount = 4
						for j = 1, bulletCount do
							local index = j - count
							local diff = 26
							local bulletAngle = angle + math.pi / 2
							local x = enemy.x + math.cos(bulletAngle) * index * diff
							local y = enemy.y + math.sin(bulletAngle) * index * diff
							stage.spawnBullet('bluearrow', x, y, function(bullet)
								bullet.velocity = {
									x = math.cos(angle) * speed,
									y = math.sin(angle) * speed
								}
								bullet.rotation = angle
								if j == 1 then bullet.visible = false end
							end)
						end
						angle = angle + math.tau / count
					end
				end
				local shotInterval = 6
				local limit = shotInterval * 5
				local interval = shotInterval * 8
				local mod = math.pi / 8
				if enemy.clock == 0 then enemy.bulletAngle = math.pi - mod end
				if enemy.clock % interval < limit and enemy.clock % shotInterval == 0 then
					if enemy.clock % interval == 0 and enemy.bulletAngle then
						enemy.bulletAngle = enemy.bulletAngle + mod
					end
					if enemy.bulletAngle then triangle() end
				end
			end
			local function spawnSides()
				local function spawnBullets()
					local function spawnBullet(x)
						stage.spawnBullet('red', x, enemy.y, function(bullet)
							bullet.angle = math.pi * math.random()
							bullet.speed = 6
						end, function(bullet)
							if bullet.speed > 3 then
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
								bullet.speed = bullet.speed - .1
							end
						end)
					end
					spawnBullet(enemy.x - bossOffset)
					spawnBullet(enemy.x + bossOffset)
				end
				local interval = 5
				local limit = interval * 6
				local max = limit * 2
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % (interval * 2) == 0 then
						explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, false, true, false, true)
						explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, false, true, false, true)
					end
					spawnBullets()
					spawnBullets()
					spawnBullets()
				end
			end
			spawnCenter()
			spawnSides()
		end,

		function(enemy)
			local function arrows()
				local function spawnBullets()
					local angle = enemy.bulletAngle
					local speed = 3
					stage.spawnBullet('redarrow', enemy.x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speed,
							y = math.sin(angle) * speed
						}
						bullet.rotation = angle
					end)
				end
				local interval = 5
				local limit = interval * 20
				local max = limit * 1.5
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then
						local mod = .6
						enemy.bulletAngle = getAngle(enemy, player)
						enemy.bulletAngleMin = enemy.bulletAngle - mod
						enemy.bulletAngleMax = enemy.bulletAngle + mod
						enemy.bulletDirection = true
					end
					if enemy.bulletAngle then spawnBullets() end
					local diff = 0.3
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
					local x = enemy.x - grid * 8
					if opposite then x = enemy.x + grid * 8 end
					for i = 1, count do
						stage.spawnBullet('bluebig', x, enemy.y, function(bullet)
							bullet.speed = 5
							bullet.angle = angle
						end, function(bullet)
							if bullet.speed > 2 then
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
								bullet.speed = bullet.speed - .1
							end
						end)
						angle = angle + math.tau / count
					end
					local mod = 0.05
					if opposite then mod = mod * -1 end
					enemy.ringAngle = enemy.ringAngle + mod
				end
				local interval = 60
				if enemy.clock == 0 then enemy.ringAngle = 0 end
				if enemy.clock % interval == 0 and enemy.ringAngle then
					spawnBullets()
					spawnBullets(true)
				end
			end
			arrows()
			ring()
		end,

		function(enemy)
			local function spawnBeam(opposite, explode, offset)
				local pos = {x = enemy.x - bossOffset, y = enemy.y}
				if opposite then pos.x = enemy.x + bossOffset end
				if explode then explosions.spawn(pos, opposite, true, false, true) end
				local img = 'redbig'
				if opposite then img = 'bluebig' end
				stage.spawnBullet(img, pos.x, enemy.y, function(bullet)
					bullet.angle = getAngle(pos, enemy.bulletTarget)
					bullet.speed = 2 + offset * .15
				end, function(bullet)
					if bullet.stopped then
						if bullet.clock >= 30 and bullet.speed < 5 then
							bullet.speed = bullet.speed + .05
						end
					else
						bullet.speed = bullet.speed - .1
						if bullet.speed <= 0 then
							bullet.clock = 0
							bullet.speed = 0
							bullet.stopped = true
							bullet.angle = math.tau * math.random()
						end
					end
					bullet.velocity = {
						x = math.cos(bullet.angle) * bullet.speed,
						y = math.sin(bullet.angle) * bullet.speed
					}
				end)
			end
			local interval = 2
			local limit = 90
			local max = limit * 2.25
			if enemy.clock % interval == 0 and enemy.clock % max < limit then
				if enemy.clock % max == 0 then enemy.bulletTarget = {x = player.x, y = player.y} end
				spawnBeam(enemy.clock % (max * 2) >= max, enemy.clock % (interval * 2) == 0, enemy.clock % max / interval)
			end
		end,

		function(enemy)
			local function swash()
				local function spawnBullets(opposite)
					local count = 40
					local angle = math.pi / 2
					if opposite then angle = angle - math.pi / 2 end
					for i = 1, count / 4 do
						stage.spawnBullet('redbig', enemy.x, enemy.y, function(bullet)
							bullet.speed = 6
							bullet.angle = angle
						end, function(bullet)
							if bullet.speed > 3.5 then
								bullet.speed = bullet.speed - .1
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
							end
						end)
						angle = angle + math.tau / count
					end
				end
				local interval = 90
				if enemy.clock % interval == 0 then spawnBullets(enemy.clock % (interval * 2) == 0) end
			end
			local function arrows()
				local function spawnBullets(first)
					local function spawnBullet(opposite, hidden)
						local speed = 5
						local offset = grid
						local posOffset = grid
						local x = enemy.x + bossOffset
						local y = enemy.y
						local angleOffset = math.pi / 2
						if opposite then
							x = x + math.cos(enemy.bulletAngleB - angleOffset) * posOffset
							y = y + math.sin(enemy.bulletAngleB - angleOffset) * posOffset
						else
							x = x + math.cos(enemy.bulletAngleB + angleOffset) * posOffset
							y = y + math.sin(enemy.bulletAngleB + angleOffset) * posOffset
						end
						stage.spawnBullet('bluearrow', x, y, function(bullet)
							bullet.velocity = {
								x = math.cos(enemy.bulletAngleB) * speed,
								y = math.sin(enemy.bulletAngleB) * speed
							}
							bullet.rotation = enemy.bulletAngleB
							if hidden then bullet.visible = false end
						end)
					end
					spawnBullet(true, true)
					spawnBullet(true)
					spawnBullet()
				end
				local interval = 5
				local limit = interval * 10
				local max = limit * 2
				if enemy.clock % interval == 0 and enemy.clock % max < limit then
					if enemy.clock % max == 0 then enemy.bulletAngleB = getAngle({x = enemy.x + bossOffset, y = enemy.y}, player) end
					if enemy.clock % (interval * 2) == 0 then explosions.spawn({x = enemy.x + bossOffset, y = enemy.y}, true, true, false, true) end
					spawnBullets(enemy.clock % max == 0)
				end
			end
			local function spray()
				local function spawnBullets(opposite)
					local speed = 3
					local count = 30
					local angle = enemy.bulletAngleA
					if opposite then angle = angle + math.pi / count end
					for i = 1, count do
						if angle > 0 and angle < math.pi then
							stage.spawnBullet('blue', enemy.x - bossOffset, enemy.y, function(bullet)
								bullet.velocity = {
									x = math.cos(angle) * speed,
									y = math.sin(angle) * speed
								}
								-- bullet.rotation = angle
							end)
						end
						angle = angle + math.tau / count
					end
				end
				local interval = 30
				if enemy.clock == 0 then enemy.bulletAngleA = 0 end
				if enemy.clock % interval == 0 then
					local mod = 0.1
					enemy.bulletAngleA = enemy.bulletAngleA - mod / 2
					enemy.bulletAngleA = enemy.bulletAngleA + mod * math.random()
					spawnBullets(enemy.clock % (interval * 2) == interval)
					explosions.spawn({x = enemy.x - bossOffset, y = enemy.y}, true, true, false, true)
				end
			end
			swash()
			arrows()
			spray()
		end,

		function(enemy)
			local function ring()
				local function spawnBullets(opposite)
					local count = 35
					local angle = -math.pi / 2
					if opposite then angle = angle + math.pi / count end
					for i = 1, count do
						stage.spawnBullet('redbig', enemy.x, enemy.y, function(bullet)
							bullet.speed = 5
							bullet.angle = angle
						end, function(bullet)
							if bullet.speed > 3 then
								bullet.speed = bullet.speed - .1
								bullet.velocity = {
									x = math.cos(bullet.angle) * bullet.speed,
									y = math.sin(bullet.angle) * bullet.speed
								}
							end
						end)
						angle = angle + math.tau / count
					end
				end
				local interval = 30
				if enemy.clock % interval == 0 then spawnBullets(enemy.clock % (interval * 2) == 0) end
			end
			ring()
			local function balls()
				local function ball(opposite)
					local count = 25
					local angle = math.random() * math.tau
					local offset = grid * 4
					local x = enemy.x - bossOffset
					if opposite then x = enemy.x + bossOffset end
					for i = 1, count + 1 do
						stage.spawnBullet('bluearrow', x + math.cos(angle) * offset, enemy.y + math.sin(angle) * offset, function(bullet)
							bullet.axisAngle = angle
							bullet.speed = 3
							bullet.rotation = angle
							if i == 1 then bullet.visible = false end
						end, function(bullet)
							if not bullet.flipped then
								bullet.velocity = {
									y = math.sin(bullet.axisAngle) + bullet.speed,
									x = math.cos(bullet.axisAngle)
								}
								bullet.axisAngle = bullet.axisAngle + 0.075
								bullet.speed = bullet.speed - .1
								if bullet.speed <= .1 then
									bullet.flipped = true
									local angle = getAngle({x = bullet.x, y = bullet.y}, player)
									local speed = 4.5
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
					explosions.spawn({x = x, y = enemy.y}, true, true, false, true)
				end
				local interval = 80
				if enemy.clock % interval == 0 then ball(enemy.clock % (interval * 2) == interval) end
			end
			balls()
		end,

		function(enemy)
			local function ring(opposite, other)
				local count = 32
				local angle = 0
				local speedX = 3
				local speedY = speedX
				if other then speedY = speedY * .75
				else speedX = speedX * .75 end
				local x = enemy.x - enemy.moveOffset
				if other then x = enemy.x + enemy.moveOffset end
				explosions.spawn({x = x, y = enemy.y}, false, true, false, true)
				for i = 1, count do
					stage.spawnBullet('red', x, enemy.y, function(bullet)
						bullet.velocity = {
							x = math.cos(angle) * speedX,
							y = math.sin(angle) * speedY
						}
					end)
					angle = angle + math.tau / count
				end
			end
			local function laser(mod, opposite, other)
				local speed = 3 + mod / 2
				-- local speed = 3
				local x = enemy.x + enemy.moveOffset
				if other then x = enemy.x - enemy.moveOffset end
				explosions.spawn({x = x, y = enemy.y}, true)
				stage.spawnBullet('bluebig', x, enemy.y, function(bullet)
					bullet.speed = 4 + mod / 2
					bullet.minSpeed = bullet.speed - 2
					bullet.angle = enemy.bulletAngle
				end, function(bullet)
					if bullet.speed > bullet.minSpeed then
						bullet.speed = bullet.speed - .1
						bullet.velocity = {
							x = math.cos(bullet.angle) * bullet.speed,
							y = math.sin(bullet.angle) * bullet.speed
						}
					end
				end)
			end
			enemy = moveEnemySides(enemy)
			local interval = 30
			if enemy.clock % (interval * 2) == 0 then
				ring(enemy.clock % (interval * 4) < interval * 2)
				ring(enemy.clock % (interval * 4) < interval * 2, true)
			end
			local laserInterval = 10
			local limit = laserInterval * 4
			local max = limit * 2
			if enemy.clock % laserInterval == 0 and enemy.clock % max < limit then
				if enemy.clock % max == 0 then enemy.bulletAngle = getAngle(enemy, player) end
				if enemy.clock % (max * 2) < max and enemy.bulletAngle then
					laser(enemy.clock % max / 10)
					laser(enemy.clock % max / 10, false, true)
				end
				if enemy.clock % (max * 2) >= max and enemy.bulletAngle then
					laser((enemy.clock % max - 5) / 10, true)
					laser((enemy.clock % max - 5) / 10, true, true)
				end
			end
		end,

		function(enemy)

			local function spray()
				local angle = enemy.bulletAngle
				local count = 35
				for i = 1, count do
					stage.spawnBullet('redarrow', enemy.x, enemy.y, function(bullet)
						bullet.angle = angle
						bullet.speed = 3
					end, function(bullet)
						if bullet.clock < 60 then
							bullet.velocity = {
								x = math.cos(bullet.angle) * bullet.speed,
								y = math.sin(bullet.angle) * bullet.speed
							}
							bullet.rotation = bullet.angle
							bullet.angle = bullet.angle + 0.075
						end
					end)
					angle = angle + math.tau / count
				end
				enemy.bulletAngle = enemy.bulletAngle + 0.05
			end
			local function jolt(opposite)
				local count = 80
				local angle = math.pi / 4
				if opposite then angle = angle + math.pi / 2 end
				for i = 1, count do
					if i % (count / 6) < 5 then
						stage.spawnBullet('bluebig', enemy.x, enemy.y, function(bullet)
							bullet.angle = angle
							bullet.speed = 4.5
						end, function(bullet)
							if bullet.clock < 80 then
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
			local joltInterval = 60
			if enemy.clock == 0 then enemy.bulletAngle = 0 end
			if enemy.clock % 30 == 0 and enemy.bulletAngle then spray() end
			if enemy.clock % joltInterval == 0 and enemy.bulletAngle and enemy.clock > 0 then jolt(enemy.clock % (joltInterval * 2) == 0) end
		end

	}

	local function spawnEnemy()
		print(#attacks)
		stage.spawnEnemy('chen', gameWidth / 2, -stage.enemyImages.chen.idle1:getHeight() / 2, function(enemy)
			enemy.angle = math.pi / 2
			enemy.speed = 3
			enemy.currentAttack = 1
			enemy.health = 1500
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
			local current = 1
			for i = 1, #attacks do
				if enemy.health >= bossHealthInit / #attacks * (i - 1) then
					current = #attacks - i + 1
				end
			end
			if enemy.currentAttack ~= current then
				stage.killBullets = true
				enemy.clock = -60
				enemy.lastHealth = enemy.health
				enemy.currentAttack = current
			end
			if enemy.clock >= 0 then attacks[enemy.currentAttack](enemy)
			elseif enemy.clock < 0 and enemy.lastHealth then
				enemy.health = enemy.lastHealth
			end
			bossHealth = enemy.health
		end)
	end
	if currentWave.clock == 0 then spawnEnemy() end

end)
