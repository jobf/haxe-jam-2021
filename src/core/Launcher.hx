package core;

import core.Data.ElementKey;
import echo.Body;
import echo.Listener;
import echo.data.Types.ShapeType;
import lime.math.Vector2;
import ob.pear.Delay;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Pear;
import peote.view.Color;
import scenes.ScorchedEarth.Direction;

using ob.pear.Delay.DelayExtensions;

enum LauncherState {
	Idle;
	Prepare;
	Shoot;
	TakeDamage;
	Expired;
}

typedef ProjectileStats = {
	color:Int,
	imageKey:ElementKey,
	shape:ShapeType,
	bodySize:Vector2,
	?visualSize:Vector2,
	damagePower:Float
};

typedef LauncherStats = {
	imageKey:ElementKey,
	isFlippedX:Bool,
	shape:ShapeType,
	bodySize:Vector2,
	?visualSize:Vector2,
	health:Float,
	states:Map<LauncherState, Float>,
	?maxProjectiles:Int,
	trajectory:Vector2,
	distanceFromWaveMax:Vector2,
	distanceFromWaveMin:Vector2
};

typedef LauncherConfig = {
	launcher:LauncherStats,
	projectile:ProjectileStats
}

class Launcher {
	var pear:Pear;
	var stats:LauncherStats;
	var projectile:ProjectileStats;
	var trajectory:Vector2;

	public var projectiles(default, null):Array<ShapePiece> = [];
	public var entity:ShapePiece;

	var projectileBodies:Array<Body> = [];
	var opponentTargets:Array<Body>;
	var worldListener:Listener;
	var status:LauncherState;

	var rateLimiter:Delay;
	var prepareShot:Delay;
	var madeShot:Delay;

	public function new(pear_:Pear, config:LauncherConfig, opponentTargets_:Array<Body>, position:Vector2) {
		pear = pear_;
		stats = config.launcher;
		projectile = config.projectile;
		trajectory = stats.trajectory.clone();
		opponentTargets = opponentTargets_;

		// ensure optionals are not null
		if (stats.visualSize == null)
			stats.visualSize = stats.bodySize;
		if (projectile.visualSize == null)
			projectile.visualSize = projectile.bodySize;
		if (stats.maxProjectiles == null)
			stats.maxProjectiles = 999999;

		status = Idle;

		// validate state times exist
		for (s in [Idle, Prepare, Shoot]) {
			if (!stats.states.exists(s)) {
				throw 'Launcher must have state time defined for $s';
			}
		}

		// init timers
		rateLimiter = pear.delayFactory.Default(stats.states[Idle], true, true);
		prepareShot = pear.delayFactory.Default(stats.states[Prepare], true, false);
		madeShot = pear.delayFactory.Default(stats.states[Shoot], true, false);

		// position is center of entity so adjust to fit.
		position.x += stats.bodySize.x * 0.5; // nudge towards right of screen by 50% of size
		position.y -= stats.bodySize.y * 0.5; // nudge towards top of screen by 50% of size

		// too more opponent entities and collide them

		entity = pear.initShape(stats.imageKey, Color.CYAN, {
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
		}, {vWidth: stats.visualSize.x, vHeight: stats.visualSize.y}, stats.isFlippedX);

		entity.cloth.z = -1;

		worldListener = pear.scene.phys.world.listen(opponentTargets, projectileBodies, {
			enter: (entity, projectile, collisions) -> {
				takeDamage(projectile);
			}
		});

		#if debug
		trace('new launcher at $position');
		#end
	}

	public function initProjectile():ShapePiece {
		var piece = pear.initShape(projectile.imageKey, projectile.color, {
			x: entity.body.x,
			y: entity.body.y,
			elasticity: 0.3,
			rotational_velocity: 8, // Math.abs(Random.range(300, 360)),
			max_rotational_velocity: 10,
			shape: {
				type: projectile.shape,
				radius: projectile.bodySize.y * 0.5,
				width: projectile.bodySize.x,
				height: projectile.bodySize.y,
				solid: false,
			}
		}, {vWidth: projectile.visualSize.x, vHeight: projectile.visualSize.y},
			stats.isFlippedX);

		projectiles.push(piece);
		piece.body.data.projectileData = projectile;
		piece.cloth.z = -15;
		projectileBodies.push(piece.body);
		return piece;
	}

	public function launchProjectile(projectile:ShapePiece) {
		projectile.body.velocity.set(trajectory.x, trajectory.y);
	}

	public function takeDamage(body:Body) {
		trace("hit");
		var projectileData:ProjectileStats = body.data.projectileData;
		if (projectileData != null) {
			trace('damage ${projectileData.damagePower}');
			stats.health -= projectileData.damagePower;
		}
	}

	public function setSelectedStatus(setIsSelectedTo:Bool) {
		trace('highlighted $setIsSelectedTo');
		if (setIsSelectedTo) {
			// highlight
		} else {
			// turn off highlight
		}
	}

	function setNewState(nextState:LauncherState) {
		switch (nextState) {
			default:
		}
	}

	function destroy() {
		entity.setColor(Color.RED);
		pear.scene.phys.world.listeners.remove(worldListener);
	}

	function onPrepareShotFinish() {
		// trace('shoot!');
		status = Shoot;
		// entity.cloth.w = Std.int(stats.visualSize.x + 10);
		entity.updateElement();
		var p = initProjectile();
		launchProjectile(p);
		madeShot.start();
	}

	function onMadeShotFinish() {
		// trace('idle..');
		status = Idle;
		entity.cloth.rotation = 0;
		// todo - better srhink/grow
		// entity.cloth.w = Std.int(stats.visualSize.x);
		entity.updateElement();
	}

	function onRateLimitFinish() {
		// trace('...aim...');
		status = Prepare;
		entity.cloth.rotation -= 5;
		// entity.cloth.w = Std.int(stats.visualSize.x - 20);
		entity.updateElement();
		prepareShot.start();
	}

	public function update(dt:Float) {
		if (stats.health <= 0) {
			destroy();
		}

		if (projectiles.length < stats.maxProjectiles) {
			rateLimiter.update(dt, onRateLimitFinish);
			prepareShot.update(dt, onPrepareShotFinish);
			madeShot.update(dt, onMadeShotFinish);
		}

		for (p in projectiles) {
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
		entity.body.velocity.x = speed;
		// entity.body.active = true;
		trace('ent velocity ${entity.body.velocity}');
		entity.body.set_position(pear.window.width * 0.5, pear.window.height * 0.5);
		// entity.body.set_position(entity.body.x + moveBy.x, entity.body.y + moveBy.y);
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
