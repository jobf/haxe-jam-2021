package scenes;

import pieces.Launcher;
import ob.pear.GamePiece.ShapePiece;
import utils.Loader;
import ob.pear.Sprites.ShapeElement;
import lime.graphics.Image;
import lime.ui.KeyCode;
import peote.view.Color;
import echo.data.Options.ListenerOptions;
import ob.pear.Pear;
import hxmath.math.Vector2;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.Scene;

using ob.pear.Delay.DelayExtensions;


enum Direction{
	Up;
	Right;
	Down;
	Left;
}


@:enum abstract ElementKey(Int) from Int to Int {
	var RECT;
	var CIRCLE;
	var POLYGON;
	var LORD;
	var KENNEL;
	var DOG;
	var CAVALRY;
  }

class Preload{
	public static function letsGo(pathMap:Map<ElementKey, String>, onLoadAll:Map<ElementKey, Image>->Void){
		var keyValues = [for (_ in pathMap.keyValueIterator()) _];
        Loader.imageArray([for (kv in keyValues) kv.value], (images)->{
			var imageMap:Map<ElementKey,Image> = [];
			for(i => kv in keyValues){
				imageMap[kv.key] = images[i];
			}
			onLoadAll(imageMap);
		});
    }
}

  
class ScorchedEarth extends Scene {	
	var pieces:Array<IGamePiece> = [];
	var playerA:Player;
	// var playerB:Launcher;
	var cursor:IGamePiece;
	
	public static var assetPaths(default, null):Map<ElementKey, String> = [
		LORD => 'assets/png/templord.png',
		KENNEL => 'assets/png/beasthouse.png',
		DOG => 'assets/png/dog.png',
		CAVALRY => 'assets/png/cavalry.png'
	];
	
	override public function new(pear:Pear, images:Map<ElementKey, Image>) {
		super(pear, {
			width: pear.window.width,
			height: pear.window.height,
			gravity_y: 100,
			iterations: 5,
			history: 1
		});

		ShapeElement.init(vis.display, RECT, LORD, images[LORD]);
		ShapeElement.init(vis.display, RECT, KENNEL, images[KENNEL]);
		ShapeElement.init(vis.display, CIRCLE, DOG, images[DOG]);
		ShapeElement.init(vis.display, RECT, CAVALRY, images[CAVALRY]);

		var playerPosA = new Vector2(0, pear.window.height);
		playerA = new Player(pear, playerPosA, true);

		// var bSize = pear.window.width * 0.2;
		// var playerPosB = new Vector2(pear.window.width - bSize, pear.window.height);
		// var playerTrajectoryB = new Vector2(-130, -130);
		// playerB = new Launcher(pear, playerPosB, playerTrajectoryB);

		phys.world.quadtree.max_depth = 2;
		phys.world.static_quadtree.max_depth = 3;

		var worldCollideOptions:ListenerOptions = {
			// placeholder
		};

		phys.world.listen(worldCollideOptions);

		// too more opponent entities and collide them
		// phys.world.listen(playerA.lord.body, playerB.projectileBodies, {
		// 	enter: (entity, projectile, collisions) -> {
		// 		playerA.launcher.takeDamage(projectile);
		// 	}
		// });

		// phys.world.listen(playerB.entity.body, playerA.launcher.projectileBodies, {
		// 	enter: (entity, projectile, collisions) -> {
		// 		playerB.takeDamage(projectile);
		// 	}
		// });
		
		var cursorSize = pear.window.height * 0.07;
		cursor = phys.initShape(ElementKey.CIRCLE, 0x44ff44aa, {
			x: pear.window.width * 0.5,
			y: pear.window.height * 0.5,
			velocity_y: 0,
			velocity_x: 0,
			max_velocity_y: 0,
			max_velocity_x: 0,
			kinematic: true,
			shape: {
				type: CIRCLE,
				radius: cursorSize * 0.5,
				width: cursorSize,
				height: cursorSize,
				solid: false
			}
		});

		pear.followMouse(cursor);

		pear.input.onMouseDown.connect((sig) -> {
			// placeholder
		});

		pear.input.onKeyDown.connect((sig) -> {
			handlePlayerKeyPress(sig.key);
		});

		pear.onUpdate = pearUpdate;
	}

	function pearUpdate(dt:Int, p:Pear) {
		var deltaMs = phys.update(dt);
		playerA.update(deltaMs);
		// playerB.update(deltaMs);
	}

	var playerAKeys:Map<KeyCode,Direction> = [
		W => Up,
		A => Left,
		S => Down,
		D => Right
	];

	// var playerBKeys:Map<KeyCode,Direction> = [
	// 	U => Up,
	// 	H => Left,
	// 	J => Down,
	// 	L => Right
	// ];

	function handlePlayerKeyPress(key:KeyCode) {
		if(playerAKeys.exists(key)){
			playerA.launcher.alterTrajectory(playerAKeys[key]);
		}
		// else if(playerBKeys.exists(key)){
		// 	playerB.alterTrajectory(playerBKeys[key]);
		// }
	}
}

class Player{
	public var lord(default, null):ShapePiece;
	public var launcher(default, null):Launcher;
	var pear:Pear;
	public function new(pear_:Pear, position:Vector2, flipX:Bool = false) {
		pear = pear_;
		var xTrajectory:Float = flipX ? 130 : -130;
		var trajectory = new Vector2(xTrajectory, -130);
		lord =  pear.initShape(ElementKey.LORD, Color.CYAN, {
			x: position.x + 100,
			y: position.y,
			elasticity: 0.0,
			rotational_velocity: 0.0,
			shape: {
				type: RECT,
				// radius: size * 0.5,
				width: 270,
				height: 666,
				solid: false,
			}
		});
		lord.cloth.z = -30;
		var launcherPos = new Vector2(position.x, position.y + 30);
		launcher = new Launcher(pear, Barracks.Launchers["KENNEL"], Barracks.Projectiles["DOG"], launcherPos, trajectory);
	}

	public function update(dt:Float) {
		launcher.update(dt);
	}
}

class Barracks{
	public static var Launchers:Map<String, LauncherStats> = [
		"KENNEL" => {
			imageKey:KENNEL,
			shape: RECT,
			bodySize: new Vector2(150, 150),
			visualSize: new Vector2(180, 180),
			health: 100,
			states: [
				Idle => 0.7,
				Prepare => 0.2,
				Shoot => 0.1
			]
		},
		"CAVALRY" => {
			imageKey:CAVALRY,
			shape: RECT,
			bodySize: new Vector2(340, 120),
			visualSize: new Vector2(520, 280),
			health: 50,
			states: [
				Idle => 0.7,
				Prepare => 0.2,
				Shoot => 0.1
			]
		},
	];
	public static var Projectiles:Map<String, ProjectileStats> = [
		"DOG" => {
			color: 0xffffffdd,
			imageKey: DOG,
			shape: CIRCLE,
			bodySize: new Vector2(16, 16),
			visualSize: new Vector2(90, 90),
			damagePower: 20
		}
	];
}