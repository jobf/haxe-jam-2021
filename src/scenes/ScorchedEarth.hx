package scenes;

import lime.ui.KeyCode;
import echo.Body;
import peote.view.Color;
import ob.pear.Delay;
import echo.data.Options.ListenerOptions;
import ob.pear.Pear;
import hxmath.math.Vector2;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.Scene;
import echo.data.Types.ShapeType;

using ob.pear.Delay.DelayExtensions;

enum Direction{
	Up;
	Right;
	Down;
	Left;
}

class ScorchedEarth extends Scene {
	var cursor:IGamePiece;
	var pieces:Array<IGamePiece> = [];
	var playerA:Launcher;
	var playerB:Launcher;

	override public function new(pear:Pear) {
		super(pear, {
			width: pear.window.width,
			height: pear.window.height,
			gravity_y: 100,
			iterations: 5,
			history: 1
		});

		var playerPosA = new Vector2(0, pear.window.height);
		var playerTrajectoryA = new Vector2(130, -130);
		playerA = new Launcher(pear, playerPosA, playerTrajectoryA);

		var bSize = pear.window.width * 0.2;
		var playerPosB = new Vector2(pear.window.width - bSize, pear.window.height);
		var playerTrajectoryB = new Vector2(-130, -130);
		playerB = new Launcher(pear, playerPosB, playerTrajectoryB);

		phys.world.quadtree.max_depth = 2;
		phys.world.static_quadtree.max_depth = 3;

		var worldCollideOptions:ListenerOptions = {
			// placeholder
		};
		phys.world.listen(worldCollideOptions);

		
		phys.world.listen(playerA.entity.body, playerB.projectileBodies, {
			enter: (entity, projectile, collisions) -> {
				playerA.takeDamage(projectile);
			}
		});

		phys.world.listen(playerB.entity.body, playerA.projectileBodies, {
			enter: (entity, projectile, collisions) -> {
				playerB.takeDamage(projectile);
			}
		});
		
		var cursorSize = pear.window.height * 0.07;
		cursor = phys.initShape(0x44ff44aa, {
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
		playerB.update(deltaMs);
	}

	var playerAKeys:Map<KeyCode,Direction> = [
		W => Up,
		A => Left,
		S => Down,
		D => Right
	];

	var playerBKeys:Map<KeyCode,Direction> = [
		U => Up,
		H => Left,
		J => Down,
		L => Right
	];

	function handlePlayerKeyPress(key:KeyCode) {
		if(playerAKeys.exists(key)){
			playerA.alterTrajectory(playerAKeys[key]);
		}
		else if(playerBKeys.exists(key)){
			playerB.alterTrajectory(playerBKeys[key]);
		}
	}
}

typedef Projectile = {color:Int, shape:ShapeType, height:Float, width:Float, damagePower:Float};

class Launcher {
	var pear:Pear;
	var projectile:Projectile = {
		color: 0xffffffdd,
		shape: CIRCLE,
		width: 16,
		height: 16,
		damagePower: 20
	};
	var health:Float;
	public var position(default, null):Vector2;
	public var trajectory(default, null):Vector2;
	public var projectiles(default, null):Array<IGamePiece> = [];
	public var projectileBodies(default, null):Array<Body> = [];
	
	public var entity:IGamePiece;

	var timer:Float = 0;
	var maxProjectiles = 20;
	var rateLimiter:Delay;

	public function new(pear_:Pear, position_:Vector2 = null, trajectory_:Vector2 = null) {
		pear = pear_;
		rateLimiter = pear.delayFactory.Default(1, true, true);
		trace(rateLimiter);
		health = 100;
		var size = pear.window.width * 0.2;

		position = position_ != null ? position_ : new Vector2(0, 0);
		// position is center of entity so adjust to fit.
		position.x += size * 0.5; // nudge towards right of screen by 50% of size
		position.y -= size * 0.5; // nudge towards top of screen by 50% of size

		trajectory = trajectory_ != null ? trajectory_ : new Vector2(0, 0);
		
		entity = pear.initShape(Color.CYAN, {
			x: position.x,
			y: position.y,
			elasticity: 0.0,
			rotational_velocity: 0.0,
			shape: {
				type: RECT,
				// radius: size * 0.5,
				width: size,
				height: size,
				solid: false,
			}
		});
	}

	public function initProjectile():IGamePiece {
		var piece = pear.initShape(this.projectile.color, {
			x: position.x,
			y: position.y,
			elasticity: 0.3,
			rotational_velocity: 0.0,
			shape: {
				type: this.projectile.shape,
				radius: this.projectile.height * 0.5,
				width: this.projectile.width,
				height: this.projectile.height,
				solid: false,
			}
		});

		projectiles.push(piece);
		piece.body.data.projectileData = projectile;
		projectileBodies.push(piece.body);
		return piece;
	}

	public function launchProjectile(projectile:IGamePiece) {
		projectile.body.velocity.set(trajectory.x, trajectory.y);
	}

	public function takeDamage(body:Body){
		trace("hit");
		var projectileData:Projectile = body.data.projectileData;
		if(projectileData != null){
			trace('damage ${projectileData.damagePower}');
			health -= projectileData.damagePower;
		}
	}

	function destroy(){
		entity.body.remove();
		entity.setColor(Color.RED);
	}

	function onRateLimitFinish() {
		var p = initProjectile();
		launchProjectile(p);
	}

	public function update(dt:Float) {
		if(health <= 0){
			destroy();
		}
		if (projectiles.length < maxProjectiles) {
			rateLimiter.update(dt, onRateLimitFinish);
		}

		for (p in projectiles) {
			if (pear.scene.phys.isOutOfBounds(p.body)) {
				// stop
				p.body.velocity.set(0, 0);
				// reset posiiton
				p.body.set_position(position.x, position.y);
				// launch again
				launchProjectile(p);
			}
		}
	}

	var amount = 10;
	public function alterTrajectory(direction:Direction){
		switch (direction){
			case Up: trajectory.y -= amount;
			case Down: trajectory.y += amount;
			case Left: trajectory.x -= amount;
			case Right: trajectory.y += amount;
			case _:return;
		}
	}
}
