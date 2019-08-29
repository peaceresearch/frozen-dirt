math.tau = math.pi * 2
hc = require('lib/hc')
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
  peach = 'eec39a',
  blueLightest = 'cbdbfc',
	blueLight = '5fcde4',
  blueMid = '639bff',
	blueDark = '306082',
	blueDarkest = '3f3f74',
  blue = '5b6ee1',
  brown = '854c30',
  green = '346524',
  greenLight = '6daa2c',
  blue = '597dce',
  orange = 'd27d2c',
  gray = '757161',
  grayLight = '8595a1',
	grayLightest = '9badb7',
  grayDark = '4e4a4e',
  yellow = 'dad45e',
  white = 'ffffff'
}
gameClock = 0
highScore = 0
currentScore = 0
paused = false
gameOver = false
started = true
aniTime = 20
dt = 0
frameLimit = 1 / 60
fontBig = love.graphics.newFont('fonts/goldbox-big.ttf', 13)
font = love.graphics.newFont('fonts/goldbox.ttf', 8)
masks = {
  half = love.graphics.newImage('img/masks/half.png'),
  quarter = love.graphics.newImage('img/masks/quarter.png')
}
maskShader = love.graphics.newShader([[	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
		discard;
	}
	return vec4(1.0);
	}
	]])
currentStencil = false
setStencilMask = function()
  love.graphics.setShader(maskShader)
  love.graphics.draw(currentStencil, 0, 0)
  return love.graphics.setShader()
end

bossHealthInit = 0
bossHealth = 0
bossName = ''
bossSpell = ''

require('controls')
require('background')
require('player')
require('enemies')
require('stage')
require('explosions')
require('collision')
require('chrome')
local setupColors
setupColors = function()
  for color, v in pairs(colors) do
    local _, r, g, b, a
    _, _, r, g, b, a = colors[color]:find('(%x%x)(%x%x)(%x%x)')
    colors[color] = {
      tonumber(r, 16) / 255,
      tonumber(g, 16) / 255,
      tonumber(b, 16) / 255,
      1
    }
  end
end
getAngle = function(b, a)
  return math.atan2(a.y - b.y, a.x - b.x)
end
love.load = function()
  love.window.setTitle('FROZEN DIRT')
  container = love.graphics.newCanvas(winWidth, winHeight)
  container:setFilter('nearest', 'nearest')
  love.window.setMode(winWidth * gameScale, winHeight * gameScale)
  love.graphics.setLineStyle('rough')
  love.graphics.setLineWidth(1)
  font:setFilter('nearest', 'nearest')
  fontBig:setFilter('nearest', 'nearest')
  love.graphics.setFont(font)
  setupColors()
  background.load()
  player.load()
  stage.load()
	chrome.load()
  return explosions.load()
end
love.update = function(d)
  dt = d
  controls.update()
  background.update()
  player.update()
  stage.update()
  explosions.update()
  collision.update()
  return chrome.update()
end
love.draw = function()
  container:renderTo(love.graphics.clear)
  love.graphics.setCanvas({
    container,
    stencil = true
  })
  currentStencil = masks.half
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
    return love.timer.sleep(frameLimit - dt)
  end
end
