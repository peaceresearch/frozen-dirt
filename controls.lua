controls = {
	joysticks = false,
	joystick = false,
  left = false,
  right = false,
  up = false,
  down = false,
  shoot = false,
  focus = false,
	bomb = false,
	pressingEsc = false,
	pressing5 = false
}

local function findJoystick()
	controls.joysticks = love.joystick.getJoysticks()
	for i, joystickItem in ipairs(controls.joysticks) do
		if i == 1 then controls.joystick = joystickItem end
	end
end

function loadControls()
	findJoystick()
end

local function updateKeyboard()
	if love.keyboard.isDown('left') then controls.left = true
	elseif love.keyboard.isDown('right') then controls.right = true end
	if love.keyboard.isDown('up') then controls.up = true
	elseif love.keyboard.isDown('down') then controls.down = true end
	if love.keyboard.isDown('z') then controls.shoot = true end
	if love.keyboard.isDown('x') then controls.bomb = true end
	if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then controls.focus = true end
	if love.keyboard.isDown('r') then love.event.quit('restart') end
	if love.keyboard.isDown('escape') then
		if not controls.pressingEsc then
			controls.pressingEsc = true
			if paused then paused = false
			else paused = true end
		end
	elseif controls.pressingEsc then controls.pressingEsc = false end
end

local function updateJoystick()
	if controls.joystick:getAxis(1) == -1 then controls.left = true
	elseif controls.joystick:getAxis(1) == 1 then controls.right = true end
	if controls.joystick:getAxis(2) == -1 then controls.up = true
	elseif controls.joystick:getAxis(2) == 1 then controls.down = true end
	if controls.joystick:isDown(1) then controls.shoot = true end
	if controls.joystick:isDown(2) then controls.bomb = true end
	if controls.joystick:isDown(3) then controls.focus = true end
	if controls.joystick:isDown(6) then love.event.quit('restart') end
	if controls.joystick:isDown(5) then
		if not controls.pressing5 then
			controls.pressing5 = true
			if paused then paused = false
			else paused = true end
		end
	elseif controls.pressing5 then controls.pressing5 = false end
end

function updateControls()
  controls.left = false
  controls.right = false
  controls.up = false
  controls.down = false
  controls.shoot = false
	controls.focus = false
  controls.bomb = false
	updateKeyboard()
	if controls.joystick then updateJoystick() end
end
