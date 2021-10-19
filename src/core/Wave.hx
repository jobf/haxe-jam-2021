package core;

import core.Launcher.LauncherConfig;
import echo.Body;
import ob.pear.Delay;
import ob.pear.Pear;
import ob.pear.Random;
import scenes.ScorchedEarth.Direction;

using ob.pear.Delay.DelayExtensions;

typedef WaveStats = {
	launchers:Array<LauncherConfig>,
	maximumActiveLaunchers:Int,
	waveCenter:lime.math.Vector2
};

class Wave {
	var pear:Pear;
	var stats:WaveStats;
	var launcherLimiter:Delay;
	var activeLaunchers:Array<Launcher> = [];
	var targets:Array<Body>;
	var opponentTargets:Array<Body>;

	public function new(pear_:Pear, stats_:WaveStats, targets_:Array<Body>, opponentTargets_:Array<Body>) {
		pear = pear_;
		stats = stats_;
		targets = targets_;
		opponentTargets = opponentTargets_;
		launcherLimiter = pear.delayFactory.Default(0.5, true, true);
	}

	public function update(dt:Float) {
		launcherLimiter.update(dt, onLauncherLimitFinish);
		for (l in activeLaunchers) {
			l.update(dt);
		}
	}

	var selected:Launcher;

	public function selectLauncher(id:Int) {
		trace('look for launcher with id $id');
		for (l in activeLaunchers) {
			l.setSelectedStatus(false);
			if (l.entity.body.id == id) {
				selected = l;
			}
		}
		if (selected != null) {
			selected.setSelectedStatus(true);
		}
	}

	public function alterSelectedLauncherTrajectory(direction:Direction) {
		if (selected != null) {
			selected.alterTrajectory(direction);
		}
	}

	function onLauncherLimitFinish() {
		// if(activeLaunchers.length > 0){
		// 	trace('ent bod ${activeLaunchers[0].entity.body.x}');
		// 	trace('ent cloth ${activeLaunchers[0].entity.cloth.x}');
		// }
		if (activeLaunchers.length < stats.maximumActiveLaunchers && stats.launchers.length > 0) {
			var next = stats.launchers[0];
			// var launcherPos = new Vector2(1130,600);

			var positionOffset = Random.range_vector2(next.launcher.distanceFromWaveMin, next.launcher.distanceFromWaveMax);
			if (next.launcher.isFlippedX) {
				positionOffset.x *= -1;
			}
			var launcherPos = stats.waveCenter.add(positionOffset);
			// new Vector2(599, 361);

			// var launcherTraj = new Vector2(-130, -130);
			var launcher = new Launcher(pear, next, opponentTargets, launcherPos);
			// var speed = -300;
			// var moveBy = new Vector2(-800, 0);
			// next.moveTo(speed, moveBy);
			activeLaunchers.push(launcher);
			targets.push(launcher.entity.body);
			#if debug
			trace('launcher entered  ${launcher.entity.body.x}, ${launcher.entity.body.y}\n${next.launcher}');
			#end
		}
	}
}
