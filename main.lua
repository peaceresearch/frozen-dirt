math.tau = math.pi * 2
hc = require 'HC'

winWidth = 640
winHeight = 480
gameScale = 1
grid = 16
gameWidth = grid * 24
gameHeight = grid * 28
gameX = grid * 2
gameY = grid

colors = {
	black = '140c1c',
	purple = '442434',
	blue = '30346d',
	grayDark = '4e4a4e',
	brown = '854c30',
	green = '346524',
	red = 'd04648',
	gray = '757161',
	blue = '597dce',
	orange = 'd27d2c',
	grayLight = '8595a1',
	greenLight = '6daa2c',
	peach = 'd2aa99',
	blueLight = '6dc2ca',
	yellow = 'dad45e',
	light = 'deeed6',
	white = 'ffffff'
}

gameClock = 0
highScore = 0
currentScore = 0
paused = false
gameOver = false
started = true

dt = 0
frameLimit = 1 / 60

require('controls')
require('background')
require('player')
require('chrome')

local function setupColors()
	for color, v in pairs(colors) do
		_,_,r,g,b,a = colors[color]:find('(%x%x)(%x%x)(%x%x)')
		colors[color] = {tonumber(r,16) / 255, tonumber(g,16) / 255, tonumber(b,16) / 255, 1}
	end
end

function love.load()
	love.window.setTitle('frozen dirt')
	container = love.graphics.newCanvas(winWidth, winHeight)
	container:setFilter('nearest', 'nearest')
	love.window.setMode(winWidth * gameScale, winHeight * gameScale)
	love.graphics.setLineStyle('rough')
	love.graphics.setLineWidth(1)
	setupColors()
	background.load()
	player.load()
end

function love.update(d)
	dt = d
	controls.update()
	background.update()
	player.update()
	chrome.update()
end

function love.draw()
	background.draw()
	player.draw()
	chrome.draw()
	if dt < frameLimit then love.timer.sleep(frameLimit - dt) end
end