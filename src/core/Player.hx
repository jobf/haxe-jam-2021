package core;

import core.Launcher.LauncherStats;
import core.Launcher.TargetGroup;
import core.Wave.WaveStats;
import data.Global.ElementKey;
import data.Rounds.OpponentConfig;
import echo.Body;
import lime.math.Vector2;
import ob.pear.GamePiece.ShapePiece;
import peote.view.Color;
import scenes.ScorchedEarth.Direction;

using ob.pear.Delay.DelayExtensions;

class Player {
	// public var lord(default, null):ShapePiece;

	var isFlippedX:Bool;
	var playerId:PlayerId;
	var pear:Pear;
	var wave:Wave;
	var isWaveInProgress:Bool = false;
	var config:OpponentConfig;
	var tag:String;
	var waveIndex = 0;
	public var defeatedLaunchers(default, null):Array<Launcher> = [];
	public var isWaveDefeated(default, null):Bool = false;
	public var isDefeated(default, null):Bool = false;

	public function new(playerId_:PlayerId, pear_:Pear, position:Vector2, flipX:Bool, config_:OpponentConfig) {
		playerId = playerId_;
		pear = pear_;
		config = config_;
		isFlippedX = flipX;
		tag = config.name;
		// lord = pear.initShape(ElementKey.LORD, Color.CYAN, {
		// 	x: position.x + 100,
		// 	y: position.y,
		// 	elasticity: 0.0,
		// 	rotational_velocity: 0.0,
		// 	kinematic: true,
		// 	shape: {
		// 		type: RECT,
		// 		// radius: size * 0.5,
		// 		width: 270,
		// 		height: 666,
		// 		solid: false,
		// 	}
		// }, isFlippedX);
		// lord.cloth.z = Layers.IMAGES;
	}

	public function startWave(targets:TargetGroup, opponentTargets:TargetGroup) {
		var waveConfig = config.waves[waveIndex];
		#if debug
		trace('\n [waveConfig] \n\n $waveConfig \n\n');
		#end
		wave = new Wave(playerId, pear, waveConfig, targets, opponentTargets, tag, isFlippedX);
		isWaveDefeated = false;
		isWaveInProgress = true;
	}

	function endWave(){
		waveIndex++;
		isWaveDefeated = true;
		isWaveInProgress = false;
		if(waveIndex > config.waves.length - 1){
			trace('$tag wave was defeated');
			isDefeated = true;
		}
		for(l in wave.defeatedLaunchers){
			trace('add to player defeated ${l.stats.tag}');
			defeatedLaunchers.push(l);
		}
	}

	public function update(dt:Float) {
		if (isWaveInProgress) {
			wave.update(dt);
			if(wave.isDefeated){
				endWave();
			}
		}
	}

	public function toggleIsVulnerable() {
		if(wave != null){
			wave.toggleIsVulnerable();
		}
	}

	public function selectLauncher(id:Int) {
		wave.selectLauncher(id);
	}

	public function isLauncherSelected():Bool{
		return wave.isLauncherSelected();	
	}

	public function alterSelectedLauncherTrajectory(direction:Direction) {
		wave.alterSelectedLauncherTrajectory(direction);
	}
}
