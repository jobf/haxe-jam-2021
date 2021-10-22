package scenes;

import core.Data.Barracks;
import core.Data.ElementKey;
import core.Data.Global;
import core.Data.Projectiles;
import core.Data.Rounds;
import core.Launcher.TargetGroup;
import core.Player;
import echo.Body;
import echo.Echo;
import echo.data.Options.ListenerOptions;
import lime.graphics.Image;
import lime.math.Vector2;
import lime.ui.KeyCode;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.Pear;
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
		ShapeElement.init(vis.display, RECT, LORD, images[LORD]);
		ShapeElement.init(vis.display, RECT, KENNEL, images[KENNEL]);
		ShapeElement.init(vis.display, CIRCLE, DOG, images[DOG]);
		ShapeElement.init(vis.display, RECT, CAVALRY, images[CAVALRY]);

		phys.world.quadtree.max_depth = 2;
		phys.world.static_quadtree.max_depth = 3;

		var worldCollideOptions:ListenerOptions = {
			// placeholder
		};

		phys.world.listen(worldCollideOptions);

		pear.input.onMouseDown.connect((sig) -> {
			trace('mouse is clicked ${sig.x}, ${sig.y}');
			handleMouseClick();
		});

		pear.input.onKeyDown.connect((sig) -> {
			handlePlayerKeyPress(sig.key);
		});

		var playerPosA = new Vector2(0, pear.window.height);
		var playerAConfig = {
			name: "oh lord!",
			imageKey: LORD,
			waves: [
				Global.currentWaveSetup != null ? Global.currentWaveSetup : {
					launchers: [
						Barracks.Launchers[KENNEL],
					],
					maximumActiveLaunchers: 2,
				},
				{
					launchers: [
						Barracks.Launchers[CAVALRY],
						Barracks.Launchers[CAVALRY],
						Barracks.Launchers[CAVALRY],
					],
					maximumActiveLaunchers: 2,
				}
			]
		}
		playerA = new Player(0, pear, playerPosA, false, playerAConfig);
		// player is vulnerable by default, for testing we don't want that
		playerA.toggleIsVulnerable(); // todo - check this works `^_^

		var playerPosB = new Vector2(1000, pear.window.height);
		playerB = new Player(1, pear, playerPosB, true, Rounds.opponents[Global.opponentIndex]);

		isWaveOver = false;
		isRoundOver = false;
		isInProgress = true;
		Global.wonLastRound = 0;

		startNextWave();
	}

	function startNextWave() {
		playerATargets = {launchers: [], projectiles: []};
		playerBTargets = {launchers: [], projectiles: []};
		playerA.startWave(playerATargets, playerBTargets);
		playerB.startWave(playerBTargets, playerATargets);
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
			for (t in tweens) {
				// t.onStop(); todo function for cancel
				t.isLooped = false;
				t.isInProgress = false;
			}
			pear.changeScene(new RoundEnded(pear, images));
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
}
