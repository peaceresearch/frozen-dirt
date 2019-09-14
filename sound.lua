sound = {
	sfx = {
		bullet1 = love.audio.newSource('sfx/bullet1.wav', 'static'),
		bullet2 = love.audio.newSource('sfx/bullet2.wav', 'static'),
		playerbullet = love.audio.newSource('sfx/playerbullet.wav', 'static'),
		graze = love.audio.newSource('sfx/graze.wav', 'static'),
		release = love.audio.newSource('sfx/release.wav', 'static'),
		bomb = love.audio.newSource('sfx/bomb.wav', 'static'),
		startgame = love.audio.newSource('sfx/startgame.wav', 'static'),
		changeselect = love.audio.newSource('sfx/changeselect.wav', 'static'),
		gameover = love.audio.newSource('sfx/gameover.wav', 'static'),
	},
	bgm = {
		title = love.audio.newSource('bgm/title.mp3', 'static'),
		level1 = love.audio.newSource('bgm/level1.mp3', 'static'),
		level2 = love.audio.newSource('bgm/level2.mp3', 'static'),
		boss1 = love.audio.newSource('bgm/boss1.mp3', 'static'),
		boss2 = love.audio.newSource('bgm/boss2.mp3', 'static')
	},
	sfxVolume = .7,
	bgmVolume = .75
}

function sound.load()
	for k, v in pairs(sound.sfx) do
		sound.sfx[k]:setVolume(sound.sfxVolume)
		sound.sfx[k]:setVolume(0)
	end
	for k, v in pairs(sound.bgm) do
		sound.bgm[k]:setVolume(sound.bgmVolume)
		sound.bgm[k]:setLooping(true)
		sound.bgm[k]:setVolume(0)
	end
	-- sound.sfx.playerbullet:setVolume(.25)
	-- sound.sfx.gameover:setVolume(1)
	-- sound.sfx.graze:setVolume(.25)
end

function sound.playSfx(sfx)
	sfx = sound.sfx[sfx]
	if sfx:isPlaying() then sfx:seek(0)
	else sfx:play() end
end

function sound.playBgm(bgm)
	for k, v in pairs(sound.bgm) do
		if sound.bgm[k]:isPlaying() then sound.bgm[k]:stop() end
	end
	sound.bgm[bgm]:play()
end

function sound.stopBgm()
	for k, v in pairs(sound.bgm) do
		if sound.bgm[k]:isPlaying() then sound.bgm[k]:stop() end
	end
end
