package core;

import core.Data.Barracks;
import core.Launcher.LauncherConfig;
import echo.Body;
import lime.math.Vector2;
import ob.pear.Delay;
import ob.pear.Pear;
import ob.pear.Random;
import scenes.ScorchedEarth.Direction;

using ob.pear.Delay.DelayExtensions;

typedef WaveStats = {
	launchers:Array<LauncherConfig>,
	maximumActiveLaunchers:Int
};

class Wave {
	var pear:Pear;
	var stats:WaveStats;
	var launcherLimiter:Delay;
	var activeLaunchers:Array<Launcher> = [];
	var targets:Array<Body>;
	var opponentTargets:Array<Body>;
	var tag:String;
	var launcherIndex:Int = 0;
	var numLaunchersRemaining:Int;
	public var isDefeated(default, null):Bool;
	var isFlippedX:Bool;

	public function new(pear_:Pear, stats_:WaveStats, targets_:Array<Body>, opponentTargets_:Array<Body>, tag_:String, isFlippedX_:Bool) {
		pear = pear_;
		stats = stats_;
		targets = targets_;
		opponentTargets = opponentTargets_;
		launcherLimiter = pear.delayFactory.Default(0.5, true, true);
		tag = tag_;
		isFlippedX = isFlippedX_;
		numLaunchersRemaining = stats.launchers.length;
		isDefeated = false;
	}

	public function update(dt:Float) {
		if(isDefeated) return;
		
		launcherLimiter.wait(dt, onLauncherLimitFinish);
		
		for (l in activeLaunchers) {
			l.update(dt);
			if (l.hp <= 0) {
				activeLaunchers.remove(l);
				l.destroy();
				numLaunchersRemaining--;
			}
		}

		isDefeated = numLaunchersRemaining <= 0;

	}

	var selected:Launcher;

	public function selectLauncher(id:Int) {
		trace('look for launcher with id $id');
		if (selected != null && selected.entity.body.id == id) {
			// trying to select the already selected launcher
			// so it must be not selected now
			selected.toggleSelected();
			selected = null;
		} else {
			// otherwise make a selection
			for (l in activeLaunchers) {
				if (l.entity.body.id == id) {
					selected = l;
				}
			}
			if (selected != null) {
				selected.toggleSelected();
			}
		}
	}

	public function toggleIsVulnerable() {
		for (l in activeLaunchers) {
			l.toggleIsVulnerable();
		}
	}

	public function alterSelectedLauncherTrajectory(direction:Direction) {
		if (selected != null) {
			selected.alterTrajectory(direction);
		}
	}
	function onLauncherLimitFinish() {
		if(stats.launchers.length == 0) {
			trace('$tag has no launchers');
			return;
		};

		if (activeLaunchers.length < stats.maximumActiveLaunchers && launcherIndex < stats.launchers.length) {
			var next = stats.launchers[launcherIndex];
			var heightPercent = Random.range(next.launcher.heightMinMax.x, next.launcher.heightMinMax.y);
			var widthOffset = 10;
			if (isFlippedX) {
				widthOffset *= -1;
			}
			var launcherPos = new Vector2(widthOffset, heightPercent * pear.window.height);
			var launcher = new Launcher(pear, next, opponentTargets, launcherPos, tag, isFlippedX);
			activeLaunchers.push(launcher);
			targets.push(launcher.entity.body);
			launcherIndex++;
			#if debug
			trace('launcher entered  ${launcher.entity.body.x}, ${launcher.entity.body.y}\n${next.launcher}');
			#end
		}
	}
}
