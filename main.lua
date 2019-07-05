math.tau = math.pi * 2
hc = require 'lib/hc'

winWidth = 640
winHeight = 480
gameScale = 2
grid = 16
gameWidth = grid * 24
gameHeight = grid * 28
gameX = winWidth / 2 - gameWidth / 2
gameY = grid

colors = {
	black = '222034',
	purple = '45283c',
	purpleLight = '76428a',
	pink = 'd77bba',
	red = 'ac3232',
	redLight = 'd95763',

	blue = '30346d',
	grayDark = '4e4a4e',
	brown = '854c30',
	green = '346524',
	gray = '757161',
	blue = '597dce',
	orange = 'd27d2c',
	grayLight = '8595a1',
	greenLight = '6daa2c',
	peach = 'd2aa99',
	blueLight = '5fcde4',
	yellow = 'dad45e',
	white = 'ffffff'
}

gameClock = 0
highScore = 0
currentScore = 0
paused = false
gameOver = false
started = true
aniTime = 10

dt = 0
frameLimit = 1 / 60

fontBig = love.graphics.newFont('fonts/goldbox-big.ttf', 13)
font = love.graphics.newFont('fonts/goldbox.ttf', 8)

mask = love.graphics.newImage('img/masks/mask.png')
maskShader = love.graphics.newShader[[
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
			if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
				// a discarded pixel wont be applied as the stencil.
				discard;
			}
			return vec4(1.0);
		}
	]]
function setStencilMask()
   love.graphics.setShader(maskShader)
   love.graphics.draw(mask, 0, 0)
   love.graphics.setShader()
end

bossHealthInit = 0
bossHealth = 0

require('controls')
require('background')
require('player')
require('enemies')
require('stage')
require('explosions')
require('collision')
require('chrome')

local function setupColors()
	for color, v in pairs(colors) do
		_,_,r,g,b,a = colors[color]:find('(%x%x)(%x%x)(%x%x)')
		colors[color] = {tonumber(r,16) / 255, tonumber(g,16) / 255, tonumber(b,16) / 255, 1}
	end
end

function getAngle(b, a)
	return math.atan2(a.y - b.y, a.x - b.x)
end

function love.load()
	love.window.setTitle('frozen dirt')
	container = love.graphics.newCanvas(winWidth, winHeight)
	container:setFilter('nearest', 'nearest')
	love.window.setMode(winWidth * gameScale, winHeight * gameScale)
	love.graphics.setLineStyle('rough')
	love.graphics.setLineWidth(1)
	font:setFilter('nearest', 'nearest')
	fontBig:setFilter('nearest', 'nearest')
	love.graphics.setFont(fontBig)
	setupColors()
	background.load()
	player.load()
	stage.load()
	explosions.load()
end

function love.update(d)
	dt = d
	controls.update()
	background.update()
	player.update()
	stage.update()
	explosions.update()
	collision.update()
	chrome.update()
end

function love.draw()
	container:renderTo(function()
		love.graphics.clear()
	end)
	love.graphics.setCanvas({container, stencil = true})
	love.graphics.stencil(setStencilMask, 'replace', 1)
	background.draw()
	player.draw()
	stage.draw()
	explosions.draw()
	chrome.draw()
	love.graphics.setCanvas()
	local windowX = 0
	love.graphics.draw(container, windowX, 0, 0, gameScale, gameScale)
	gameClock = gameClock + 1
	if dt < frameLimit then
		love.timer.sleep(frameLimit - dt)
	end
end
