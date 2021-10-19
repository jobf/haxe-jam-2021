package scenes;

import core.Data.Barracks;
import core.Data.ElementKey;
import core.Launcher;
import core.Player;
import echo.Body;
import echo.data.Options.ListenerOptions;
import lime.graphics.Image;
import lime.math.Vector2;
import lime.ui.KeyCode;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.Pear;
import ob.pear.Sprites.ShapeElement;
import utils.Loader;

using ob.pear.Delay.DelayExtensions;

enum Direction {
	Up;
	Right;
	Down;
	Left;
}

class ScorchedEarth extends BaseScene {
	var pieces:Array<IGamePiece> = [];
	var playerA:Player;
	var playerB:Player;

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
		pear.onUpdate = pearUpdate;

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
		});

		pear.input.onKeyDown.connect((sig) -> {
			handlePlayerKeyPress(sig.key);
		});

		var playerPosA = new Vector2(0, pear.window.height);
		playerA = new Player(pear, playerPosA, false);

		var playerPosB = new Vector2(1000, pear.window.height);
		playerB = new Player(pear, playerPosB, true);

		var launchersA = {
			launcher: Barracks.Launchers[KENNEL],
			projectile: Barracks.Projectiles[DOG]
		};

		var launcherB:LauncherConfig = {
			launcher: Barracks.Launchers[CAVALRY],
			projectile: Barracks.Projectiles[DOG]
		};
		// playerB is facing opposie direction
		launcherB.launcher.isFlippedX = true;
		launcherB.launcher.trajectory.x *= -1;
		var launchersB = [launcherB, launcherB, launcherB];

		var playerATargets:Array<Body> = [];
		var playerBTargets:Array<Body> = [];

		playerA.startWave({
			launchers: [launchersA],
			maximumActiveLaunchers: 1,
			waveCenter: new Vector2(190, 330)
		}, playerBTargets);

		playerB.startWave({
			launchers: launchersB,
			maximumActiveLaunchers: 3,
			waveCenter: new Vector2(pear.window.width - 190, 330)
		}, playerATargets);
	}

	function pearUpdate(dt:Int, p:Pear) {
		var deltaMs = phys.update(dt);
		playerA.update(deltaMs);
		playerB.update(deltaMs);
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
			// playerA.launcher.alterTrajectory(playerAKeys[key]);
		}
		// else if(playerBKeys.exists(key)){
		// 	playerB.alterTrajectory(playerBKeys[key]);
		// }
	}
}
