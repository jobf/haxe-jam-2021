package scenes;

import core.Launcher.TargetGroup;
import core.Player;
import core.Wave.WaveStats;
import data.Barracks;
import data.Projectiles;
import data.Rounds;
import echo.Body;
import echo.Echo;
import echo.data.Options.ListenerOptions;
import lime.graphics.Image;
import lime.math.Vector2;
import lime.ui.KeyCode;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.Sprites.ShapeElement;

using ob.pear.Delay.DelayExtensions;

enum Direction {
	Up;
	Right;
	Down;
	Left;
}

class ScorchedEarth extends BaseScene {
	var pieces:Array<IGamePiece> = [];
	var playerATargets:TargetGroup;
	var playerBTargets:TargetGroup;
	var playerA:Player;
	var playerB:Player;
	var isWaveOver:Bool;
	var isRoundOver:Bool;
	var isInProgress:Bool;

	override public function new(pear:Pear, images:Map<ElementKey, Image>) {
		super(pear, {
			width: pear.window.width,
			height: pear.window.height,
			gravity_y: 100,
			iterations: 5,
			history: 1
		}, images);
	}

	override function init() {
		super.init();

		for(l in Barracks.Launchers.keyValueIterator()){
			ShapeElement.init(vis.display, l.value.shape, l.value.imageKey, images[l.value.imageKey]);
			ShapeElement.init(vis.display, l.value.projectileStats.shape, l.value.projectileStats.imageKey, images[l.value.projectileStats.imageKey]);
		}
		
		phys.world.quadtree.max_depth = 2;
		phys.world.static_quadtree.max_depth = 3;

		var worldCollideOptions:ListenerOptions = {
			// placeholder
		};

		phys.world.listen(worldCollideOptions);

		pear.input.onMouseDown.connect((sig) -> {
			#if debug
			trace('mouse is clicked ${sig.x}, ${sig.y}');
			#end
			handleMouseClick();
		});

		pear.input.onMouseWheel.connect((sig) -> {
			// trace('mouse is scroll ${sig.x}, ${sig.y}');
			handleMouseScroll(sig);
		});

		
		pear.input.onKeyDown.connect((sig) -> {
			handlePlayerKeyPress(sig.key);
		});

		var playerPosA = new Vector2(0, pear.window.height);
		var playerAConfig:OpponentConfig = {
			name: "player",
			imageKey: BOB,
			waves: [
				Global.currentWaveSetup != null ? Global.currentWaveSetup 
				: {
					launchers: [
						{pos: null, stats: Barracks.Launchers[lFOWLER]}
					],
					maximumActiveLaunchers: 2,
				}
			]
		};
		
		playerA = new Player(PlayerId.A, pear, playerPosA, false, playerAConfig);
		// player is vulnerable by default, for testing we don't want that
		playerA.toggleIsVulnerable(); // todo - check this works `^_^

		var playerPosB = new Vector2(1000, pear.window.height);
		playerB = new Player(PlayerId.B, pear, playerPosB, true, Rounds.opponents[Global.opponentIndex]);

		isWaveOver = false;
		isRoundOver = false;
		isInProgress = true;
		Global.whoWonLastRound = 0;
		var title = vis.text.write("click toggles select, scroll alters trajectory!", pear.window.width * 0.5, Global.margin * 4, Global.textBgColor);
		startNextWave();
	}

	function startNextWave() {
		playerATargets = {launchers: [], projectiles: []};
		playerBTargets = {launchers: [], projectiles: []};
		playerA.startWave(playerATargets, playerBTargets);
		playerB.startWave(playerBTargets, playerATargets);
	}

	function endRound(){
		for (t in tweens) {
			// t.onStop(); todo function for cancel
			t.isLooped = false;
			t.isInProgress = false;
		}
		
		Global.whoWonLastRound = playerB.isDefeated ? PlayerId.A : PlayerId.B;

		for(l in playerB.defeatedLaunchers){
			trace('extra launcher available ${l.stats.tag}');
			Global.availableLaunchers.push(l.stats);
		}

		if(PlayerId.A == Global.whoWonLastRound){
			Global.opponentIndex++;
		}

		pear.changeScene(new RoundEnded(pear, images));
	}

	override function update(deltaMs:Float) {
		super.update(deltaMs);

		if (!isInProgress)
			return;

		playerA.update(deltaMs);
		playerB.update(deltaMs);

		isRoundOver = playerA.isDefeated || playerB.isDefeated;
		if (isRoundOver) {
			trace('round over player defeated ? ${playerA.isWaveDefeated} cpu defeated ? ${playerB.isWaveDefeated}');
			isInProgress = false;
			endRound();
		} else {
			isWaveOver = playerB.isWaveDefeated || playerA.isWaveDefeated;
			if (isWaveOver) {
				startNextWave();
			}
		}
	}

	var playerAKeys:Map<KeyCode, Direction> = [W => Up, A => Left, S => Down, D => Right];

	// var playerBKeys:Map<KeyCode,Direction> = [
	// 	U => Up,
	// 	H => Left,
	// 	J => Down,
	// 	L => Right
	// ];

	function handlePlayerKeyPress(key:KeyCode) {
		if (playerAKeys.exists(key)) {
			// todo ui for this
			playerA.alterSelectedLauncherTrajectory(playerAKeys[key]);
		}
		// else if(playerBKeys.exists(key)){
		// 	playerB.alterTrajectory(playerBKeys[key]);
		// }
	}

	function handleMouseClick() {
		Echo.check(phys.world, cursor.body, playerATargets.launchers, {
			enter: (cursor, launcher, collisions) -> {
				playerA.selectLauncher(launcher.id);
			},
		});
	}

	function handleMouseScroll(scroll:Vector2) {
		if(playerA.isLauncherSelected()){
			playerA.alterSelectedLauncherTrajectory(scroll.y < 0 ? Down : Up);
		}
	}
}
