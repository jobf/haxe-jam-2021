package core;

import core.Launcher.LauncherStats;
import core.Launcher.TargetGroup;
import lime.math.Vector2;
import ob.pear.Delay;
import ob.pear.Random;
import scenes.ScorchedEarth.Direction;

using ob.pear.Delay.DelayExtensions;

typedef WaveStats = {
	launchers:Array<{pos:Vector2, stats:LauncherStats}>,
	maximumActiveLaunchers:Int
};

class Wave {
	var pear:Pear;
	var stats:WaveStats;
	var launcherLimiter:Delay;
	var activeLaunchers:Array<Launcher> = [];
	public var defeatedLaunchers(default, null):Array<Launcher> = [];
	var targets:TargetGroup;
	var opponentTargets:TargetGroup;
	var tag:String;
	var launcherIndex:Int = 0;
	var numLaunchersRemaining:Int;
	public var isDefeated(default, null):Bool;
	var isFlippedX:Bool;
	var playerId:Int;

	public function new(playerId_:Int, pear_:Pear, stats_:WaveStats, targets_:TargetGroup, opponentTargets_:TargetGroup, tag_:String, isFlippedX_:Bool) {
		playerId = playerId_;
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
		
		for (launcher in activeLaunchers) {
			launcher.update(dt);

			if (launcher.hp <= 0) {
				activeLaunchers.remove(launcher);
				trace('collecting ${launcher.stats.tag}');
				defeatedLaunchers.push(launcher);
				launcher.destroy();
				numLaunchersRemaining--;
			}

			if(launcher.isExpiring && !launcher.isExpired){
				launcher.isExpired = true;
				launcher.dispose();
			}
		}

		isDefeated = numLaunchersRemaining <= 0;
	}

	var selected:Launcher;

	public function selectLauncher(id:Int) {
		trace('look for launcher with id $id');
		if (selected != null && selected.body.id == id) {
			// trying to select the already selected launcher
			// so it must be not selected now
			selected.toggleSelected();
			selected = null;
		} else {
			// otherwise make a selection
			for (l in activeLaunchers) {
				if (l.body.id == id) {
					selected = l;
				}
			}
			if (selected != null) {
				selected.toggleSelected();
			}
		}
	}

	public function isLauncherSelected():Bool{
		return selected != null;	
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
			var launcherPos:Vector2;
			if(next.pos == null){
				var heightPercent = Random.range(next.stats.heightMinMax.x, next.stats.heightMinMax.y);
				var x = isFlippedX ? pear.window.width - 10 : 10;
				launcherPos = new Vector2(x, heightPercent * pear.window.height);
			}
			else{
				launcherPos = next.pos.clone();
			}
			
			var launcher = new Launcher(playerId, pear, next.stats, targets, opponentTargets, launcherPos, tag, isFlippedX);
			activeLaunchers.push(launcher);
			targets.launchers.push(launcher.body);
			launcherIndex++;
		}
	}
}

