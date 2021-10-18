package pieces;

import scenes.ScorchedEarth.Direction;
import peote.view.Color;
import scenes.ScorchedEarth.ElementKey;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Pear;
import hxmath.math.Vector2;
import echo.Body;
import ob.pear.Delay;
import echo.data.Types.ShapeType;

using ob.pear.Delay.DelayExtensions;

enum LauncherState{
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
	bodySize: Vector2,
	?visualSize:Vector2,
	damagePower:Float
};

typedef LauncherStats = {
	imageKey:ElementKey,
	shape: ShapeType,
	bodySize: Vector2,
	?visualSize:Vector2,
	health:Float,
	states:Map<LauncherState,Float>
};

class Launcher {

	var pear:Pear;
	var stats:LauncherStats;
	var projectile:ProjectileStats;
	public var position(default, null):Vector2;
	public var trajectory(default, null):Vector2;
	public var projectiles(default, null):Array<ShapePiece> = [];
	public var projectileBodies(default, null):Array<Body> = [];
	
	public var entity:ShapePiece;

	var timer:Float = 0;
	var maxProjectiles = Math.POSITIVE_INFINITY;
	var status:LauncherState;
	var rateLimiter:Delay;
	var prepareShot:Delay;
	var madeShot:Delay;
	public function new(pear_:Pear, stats_:LauncherStats, projectile_:ProjectileStats, position_:Vector2 = null, trajectory_:Vector2 = null) {
		pear = pear_;
		stats = stats_;
		projectile = projectile_;
		if(stats.visualSize == null) stats.visualSize = stats.bodySize;
		if(projectile.visualSize == null) projectile.visualSize = projectile.bodySize;
		
		status = Idle;

		// validate state times exist
		for(s in [Idle, Prepare, Shoot]){
			if(!stats.states.exists(s)){
				throw 'Launcher must have state time defined for $s';
			}
		}

		// init timers
		rateLimiter = pear.delayFactory.Default(stats.states[Idle], true, true);
		prepareShot = pear.delayFactory.Default(stats.states[Prepare], true, false);
		madeShot = pear.delayFactory.Default(stats.states[Shoot], true, false);

		position = position_ != null ? position_ : new Vector2(0, 0);
		// position is center of entity so adjust to fit.
		position.x += stats.bodySize.x * 0.5; // nudge towards right of screen by 50% of size
		position.y -= stats.bodySize.y * 0.5; // nudge towards top of screen by 50% of size

		trajectory = trajectory_ != null ? trajectory_ : new Vector2(0, 0);
		
		entity = pear.initShape(stats.imageKey, Color.CYAN, {
			x: position.x,
			y: position.y,
			elasticity: 0.0,
			rotational_velocity: 0.0,
			shape: {
				type: RECT,
				// radius: size * 0.5,
				width: stats.bodySize.x,
				height: stats.bodySize.y,
				solid: false,
			}
		}, {vWidth: stats.visualSize.x, vHeight: stats.visualSize.y});
		entity.cloth.z = -1;
	}

	public function initProjectile():ShapePiece {
		var piece = pear.initShape(projectile.imageKey, projectile.color, {
			x: position.x,
			y: position.y,
			elasticity: 0.3,
			rotational_velocity: 8,//Math.abs(Random.range(300, 360)),
			max_rotational_velocity: 10,
			shape: {
				type: projectile.shape,
				radius: projectile.bodySize.y * 0.5,
				width: projectile.bodySize.x,
				height: projectile.bodySize.y,
				solid: false,
			}
		}, {vWidth: projectile.visualSize.x, vHeight: projectile.visualSize.y});

		projectiles.push(piece);
		piece.body.data.projectileData = projectile;
		piece.cloth.z = -15;
		projectileBodies.push(piece.body);
		return piece;
	}

	public function launchProjectile(projectile:ShapePiece) {
		projectile.body.velocity.set(trajectory.x, trajectory.y);
	}

	public function takeDamage(body:Body){
		trace("hit");
		var projectileData:ProjectileStats = body.data.projectileData;
		if(projectileData != null){
			trace('damage ${projectileData.damagePower}');
			stats.health -= projectileData.damagePower;
		}
	}

	function setNewState(nextState:LauncherState){
		switch (nextState){
			default:
		}

	}

	function destroy(){
		entity.setColor(Color.RED);
	}

	function onPrepareShotFinish() {
		trace('shoot!');
		status = Shoot;
		entity.cloth.w = Std.int(stats.visualSize.x + 10);
		entity.updateElement();
		var p = initProjectile();
		launchProjectile(p);
		madeShot.start();
	}

	function onMadeShotFinish() {
		trace('idle..');
		status = Idle;
		entity.cloth.rotation = 0;
		entity.cloth.w = Std.int(stats.visualSize.x);
		entity.updateElement();
	}

	function onRateLimitFinish() {
		trace('...aim...');
		status = Prepare;
		entity.cloth.rotation -= 5;
		entity.cloth.w = Std.int(stats.visualSize.x - 20);
		entity.updateElement();
		prepareShot.start();
	}

	public function update(dt:Float) {
		if(stats.health <= 0){
			destroy();
		}
		if (projectiles.length < maxProjectiles) {
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
