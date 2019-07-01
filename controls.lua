controls = {
	left = false,
	right = false,
	up = false,
	down = false,
	shoot = false,
	focus = false,
}

function controls.load()

end

function controls.update()
	controls.left = false
	controls.right = false
	controls.up = false
	controls.down = false
	controls.shoot = false
	controls.focus = false
	if love.keyboard.isDown('left') then controls.left = true
	elseif love.keyboard.isDown('right') then controls.right = true end
	if love.keyboard.isDown('up') then controls.up = true
	elseif love.keyboard.isDown('down') then controls.down = true end
	if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then controls.focus = true end
	if love.keyboard.isDown('r') then love.event.quit('restart') end
end
