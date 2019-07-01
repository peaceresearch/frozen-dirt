player = {
	speed = 5,
	startingX = gameWidth / 2,
	startingY = gameHeight - grid * 4,
	images = {
		idle1 = love.graphics.newImage('img/player/marisa-idle-1.png'),
		idle2 = love.graphics.newImage('img/player/marisa-idle-2.png'),
		idle3 = love.graphics.newImage('img/player/marisa-idle-3.png'),
		left1 = love.graphics.newImage('img/player/marisa-left-1.png'),
		left2 = love.graphics.newImage('img/player/marisa-left-2.png'),
		right1 = love.graphics.newImage('img/player/marisa-right-1.png'),
		right2 = love.graphics.newImage('img/player/marisa-right-2.png'),
		hitbox = love.graphics.newImage('img/player/hitbox.png')
	},
	grazeSize = grid * 1.75
}

function player.animateImage()
	return player.images.idle1
end

function player.load()
	for type, img in pairs(player.images) do
		player.images[type]:setFilter('nearest', 'nearest')
		player.images[type]:setWrap('repeat', 'repeat')
	end
	player.x = player.startingX
	player.y = player.startingY
	player.collider = hc.circle(player.x, player.y, 0)
	player.grazeCollider = hc.circle(player.x, player.y, player.grazeSize)
end

function player.update()
	local speed = player.speed
	if controls.focus then speed = 2 end

	if controls.left then player.x = player.x - speed
	elseif controls.right then player.x = player.x + speed end
	if controls.up then player.y = player.y - speed
	elseif controls.down then player.y = player.y + speed end

	if player.x <= player.images.hitbox:getWidth() / 2 then player.x = player.images.hitbox:getWidth() / 2
	elseif player.x >= gameWidth - player.images.hitbox:getWidth() / 2 then player.x = gameWidth - player.images.hitbox:getWidth() / 2 end
	if player.y <= player.images.hitbox:getHeight() / 2 then player.y = player.images.hitbox:getHeight() / 2
	elseif player.y >= gameHeight - player.images.hitbox:getHeight() / 2 then player.y = gameHeight - player.images.hitbox:getHeight() / 2 end

	player.collider:moveTo(player.x, player.y)
	player.grazeCollider:moveTo(player.x, player.y)
end

function player.draw()
	love.graphics.draw(player.animateImage(), player.x + gameX, player.y + gameY - 1, 0, 1, 1, player.animateImage():getWidth() / 2, player.animateImage():getHeight() / 2)
	love.graphics.draw(player.images.hitbox, player.x + gameX, player.y + gameY, 0, 1, 1, player.images.hitbox:getWidth() / 2, player.images.hitbox:getHeight() / 2)
end