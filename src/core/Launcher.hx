package core;

import core.Data.ElementKey;
import core.Projectile.ProjectileStats;
import echo.Body;
import echo.Listener;
import echo.data.Types.ShapeType;
import lime.math.Vector2;
import ob.pear.Delay;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Pear;
import peote.view.Color;
import scenes.ScorchedEarth.Direction;

using ob.pear.Delay.DelayExtensions;
using ob.pear.Delay.TweenExtensions;

enum LauncherState {
	Idle;
	Prepare;
	Shoot;
	TakeDamage;
	Expired;
}


typedef Movement = {
	velocity:Vector2,
	durationMs:Float
};

typedef LauncherStats = {
	imageKey:ElementKey,
	shape:ShapeType,
	bodySize:Vector2,
	?visualSize:Vector2,
	health:Float,
	states:Map<LauncherState, Float>,
	?maxProjectiles:Int,
	trajectory:Vector2,
	movements:Array<Movement>,
	heightMinMax: Vector2,
	?color:Color
};

typedef LauncherConfig = {
	launcher:LauncherStats,
	projectile:ProjectileStats
}

class Launcher extends ShapePiece {
	var pear:Pear;

	public var stats(default, null):LauncherStats;

	var projectile:ProjectileStats;
	var trajectory:Vector2;

	public var projectiles(default, null):Array<Projectile> = [];

	var projectileBodies:Array<Body> = [];
	var opponentTargets:Array<Body>;
	var worldListener:Listener;
	var status:LauncherState;

	var rateLimiter:Delay;
	var prepareShot:Delay;
	var madeShot:Delay;
	var recoverFromHit:Delay;
	var isVulnerable:Bool;
	var tag:String;
	public var hp(default, null):Float;
	var isFlippedX:Bool;

	public function new(pear_:Pear, config:LauncherConfig, opponentTargets_:Array<Body>, position:Vector2, tag_:String, isFlippedX_:Bool) {
		pear = pear_;
		tag = tag_;
		isFlippedX = isFlippedX_;
		stats = config.launcher;
		projectile = config.projectile;
		trajectory = stats.trajectory.clone();
		if(isFlippedX){
			trajectory.x *= -1;
		}
		hp = stats.health;
		opponentTargets = opponentTargets_;

		// ensure optionals are not null
		if (stats.visualSize == null)
			stats.visualSize = stats.bodySize;
		if (projectile.visualSize == null)
			projectile.visualSize = new Vector2(projectile.bodyOptions.shape.width, projectile.bodyOptions.shape.height);
		if (stats.maxProjectiles == null)
			stats.maxProjectiles = 999999;
		
		// position is center of entity so adjust to fit.
		position.x += stats.bodySize.x * 0.5; // nudge towards right of screen by 50% of size
		position.y -= stats.bodySize.y * 0.5; // nudge towards top of screen by 50% of size
		var bodyOptions = {
			x: position.x,
			y: position.y,
			elasticity: 0.0,
			kinematic: true,
			rotational_velocity: 0.0,
			shape: {
				type: RECT,
				// radius: size * 0.5,
				width: stats.bodySize.x,
				height: stats.bodySize.y,
				solid: false,
			}
		};
		var body = pear_.scene.phys.world.make(bodyOptions);
		body.data.owner = this; // todo consolidate use of owner to gamePiece elsewhere
		body.data.gamePiece = this;
		var color = stats.color == null ? Color.CYAN : stats.color;
		super(stats.imageKey, color, stats.visualSize.x, stats.visualSize.y, body, isFlippedX);

		isVulnerable = true;
		status = Idle;
		var movementIndex = 0;

		// set up movement pattern
		if (stats.movements.length > 0) {
			pear.scene.tweens.push({
				data: new Vector2(0, 0),
				target: this,
				stepMs: 0.32,
				isLooped: true,
				onStart: (launcher, data) -> {
					launcher.body.velocity.x = stats.movements[movementIndex].velocity.x;
					launcher.body.velocity.y = stats.movements[movementIndex].velocity.y;
				},
				onCheck: (launcher:Launcher, totalMs:Float, data:Vector2) -> {
					return totalMs >= stats.movements[movementIndex].durationMs;
				},
				onTrue: (launcher, data:Vector2) -> {
					movementIndex++;
					if (movementIndex > stats.movements.length - 1) {
						movementIndex = 0;
					}
					launcher.body.velocity.x = stats.movements[movementIndex].velocity.x;
				},
			});
		}
		// validate state times exist
		for (s in [Idle, Prepare, Shoot, TakeDamage]) {
			if (!stats.states.exists(s)) {
				throw 'Launcher must have state time defined for $s';
			}
		}

		// init timers
		rateLimiter = pear.delayFactory.Default(stats.states[Idle], true, true);
		prepareShot = pear.delayFactory.Default(stats.states[Prepare], true, false);
		madeShot = pear.delayFactory.Default(stats.states[Shoot], true, false);
		recoverFromHit = pear.delayFactory.Default(stats.states[TakeDamage]);
		
		
		// set up projectile collisions 
		worldListener = pear.scene.phys.world.listen(opponentTargets, projectileBodies, {
			enter: (target, projectile, collisions) -> {
				var launcher:Launcher = cast target.data.gamePiece;
				if(launcher != null){
					launcher.takeDamage(projectile);
				}
			}
		});

		#if debug
		trace('new launcher at $position');
		#end
	}

	public function initProjectile():Projectile {
		var behaviourCheckFrequency = 0.064; // 4 frames?
		var behaviour = pear.delayFactory.Default(behaviourCheckFrequency, true, true);
		var piece = new Projectile(pear.scene.phys, body.x, body.y, projectile, behaviour, isFlippedX);
		projectiles.push(piece);
		projectileBodies.push(piece.body);
		return piece;
	}

	public function launchProjectile(projectile:ShapePiece) {
		projectile.body.velocity.set(trajectory.x, trajectory.y);
	}

	public function takeDamage(projectileBody:Body) {
		if (isVulnerable) {
			var log = '$tag launcher was hit';
			recoverFromHit.isInProgress = true;
			// setColor(Color.RED);
			cloth.rotation += 30;
			var projectileData:ProjectileStats = projectileBody.data.projectileData;
			if (projectileData != null) {
				log += ' by ${projectileBody.data.tag} projectile causing damaged ${projectileData.damagePower}';
				hp -= projectileData.damagePower;
			}
			trace(log);
		}
	}

	var isSelected:Bool;

	public function toggleSelected() {
		isSelected = !isSelected;
		cloth.isSelected = isSelected ? 1.0 : 0.0;
	}

	public function toggleIsVulnerable() {
		isVulnerable = !isVulnerable;
		trace('isisVulnerable ? $isVulnerable');
	}

	function setNewState(nextState:LauncherState) {
		switch (nextState) {
			default:
		}
	}

	public function destroy() {
		trace('$tag launcher destroyed');
		setColor(Color.RED);
		pear.scene.phys.world.listeners.remove(worldListener);
		remove();
	}

	function onPrepareShotFinish() {
		// trace('shoot!');
		status = Shoot;
		// cloth.w = Std.int(stats.visualSize.x + 10);
		updateElement();
		var p = initProjectile();
		launchProjectile(p);
		madeShot.start();
	}

	function onMadeShotFinish() {
		// trace('idle..');
		status = Idle;
		cloth.rotation = 0;
		// todo - better srhink/grow
		// cloth.w = Std.int(stats.visualSize.x);
		updateElement();
	}

	function onRecoverFromHit() {
		// trace('...aim...');
		status = Idle;
		recoverFromHit.isInProgress = false;
		cloth.rotation = 0.0;
		// cloth.rotation -= 5;
		// // cloth.w = Std.int(stats.visualSize.x - 20);
		// updateElement();
		// prepareShot.start();
	}


	function onRateLimitFinish() {
		// trace('...aim...');
		status = Prepare;
		cloth.rotation -= 5;
		// cloth.w = Std.int(stats.visualSize.x - 20);
		updateElement();
		prepareShot.start();
	}

	var tween:Tween<Launcher>;
	var mouseFollow:Vector2 -> Void;
	override function click() {
		if(mouseFollow == null){
			mouseFollow = pear.followMouse(this);
		}
		else{
			pear.input.onMouseMove.disconnect(mouseFollow);
			mouseFollow = null;
		}
	}
	override public function update(dt:Float) {
		super.update(dt);
		// if (stats.health <= 0) {
		// 	destroy();
		// }

		if (projectiles.length < stats.maxProjectiles) {
			rateLimiter.wait(dt, onRateLimitFinish);
			prepareShot.wait(dt, onPrepareShotFinish);
			madeShot.wait(dt, onMadeShotFinish);
		}
		recoverFromHit.wait(dt, onRecoverFromHit);

		for (p in projectiles) {
			
			 // !!! todo
			p.update(dt);


			if (pear.scene.phys.isOutOfBounds(p.body)) {
				// // stop
				// p.body.velocity.set(0, 0);
				// // reset posiiton
				// p.body.set_position(position.x, position.y);
				// // launch again
				// launchProjectile(p);

				// todo - recycle projectiles?
				projectiles.remove(p);
				p.remove();
			}
		}
	}

	public function moveTo(speed:Float, moveBy:Vector2) {
		// todo tween this
		body.velocity.x = speed;
		// body.active = true;
		trace('ent velocity ${body.velocity}');
		body.set_position(pear.window.width * 0.5, pear.window.height * 0.5);
		// body.set_position(body.x + moveBy.x, body.y + moveBy.y);
	}

	var amount = 10;

	public function alterTrajectory(direction:Direction) {
		switch (direction) {
			case Up:
				trajectory.y -= amount;
			case Down:
				trajectory.y += amount;
			case Left:
				trajectory.x -= amount;
			case Right:
				trajectory.y += amount;
			case _:
				return;
		}
	}
}
