package core;

import core.Data.ElementKey;
import core.Pieces;
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

using core.Pieces.BodyExtensions;
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
	?position:Vector2,
	?visualSize:Vector2,
	health:Float,
	states:Map<LauncherState, Float>,
	?maxProjectiles:Int,
	trajectory:Vector2,
	movements:Array<Movement>,
	heightMinMax:Vector2,
	?color:Color,
	tag:String,
	projectileStats:ProjectileStats
};

typedef LauncherConfig = {
	launcher:LauncherStats,
	projectile:ProjectileStats
}

typedef TargetGroup = {launchers:Array<Body>, projectiles:Array<Body>}

class Launcher extends OverlordPiece {
	var pear:Pear;

	public var stats(default, null):LauncherStats;

	var projectile:ProjectileStats;
	var trajectory:Vector2;

	public var projectiles(default, null):Array<Projectile> = [];

	// var projectileBodies:Array<Body> = [];
	var targets:TargetGroup;
	var opponentTargets:TargetGroup;
	var worldListeners:Array<Listener> = [];
	var status:LauncherState;

	var rateLimiter:Delay;
	var prepareShot:Delay;
	var madeShot:Delay;
	var recoverFromHit:Delay;
	var isVulnerable:Bool;
	var tag:String;

	public var hp(default, null):Float;

	public function new(playerId:Int, pear_:Pear, stats_:LauncherStats, targets_:TargetGroup, opponentTargets_:TargetGroup, position:Vector2, tag_:String,
			isFlippedX_:Bool) {
		pear = pear_;
		tag = tag_;
		isFlippedX = isFlippedX_;
		flipFactorX = isFlippedX ? -1 : 1;
		stats = stats_;
		projectile = stats.projectileStats;
		trajectory = stats.trajectory.clone();
		if (isFlippedX) {
			trajectory.x *= -1;
		}
		hp = stats.health;
		targets = targets_;
		opponentTargets = opponentTargets_;

		// ensure optionals are not null
		if (stats.visualSize == null)
			stats.visualSize = stats.bodySize;
		if (projectile.visualSize == null)
			projectile.visualSize = new Vector2(projectile.bodyOptions.shape.width, projectile.bodyOptions.shape.height);
		if (stats.maxProjectiles == null)
			stats.maxProjectiles = 999999;

		// position is center of entity so adjust to fit.
		position.x += (stats.bodySize.x * 0.5) * flipFactorX; // nudge towards right of screen by 50% of size
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
		trace('launcher at ${position.x} ${position.y}');
		var body = pear_.scene.phys.world.make(bodyOptions);
		body.data.owner = this; // todo consolidate use of owner to gamePiece elsewhere
		body.data.gamePiece = this;
		var color = stats.color == null ? Color.CYAN : stats.color;
		super(stats.imageKey, {player: playerId, pieceType: LAUNCHER}, color, stats.visualSize.x, stats.visualSize.y, body, isFlippedX);

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
					launcher.body.velocity.x = stats.movements[movementIndex].velocity.x * flipFactorX;
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
					launcher.body.velocity.x = stats.movements[movementIndex].velocity.x * flipFactorX;
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
		worldListeners.push(pear.scene.phys.world.listen(opponentTargets.launchers, targets.projectiles, {
			enter: (A, B, collisions) -> {
				var a = A.getVitals();
				var b = B.getVitals();
				// no friendly fire!
				if (a.player == b.player)
					return;
				// no same type collisions handled  here
				if (a.pieceType == b.pieceType)
					return;

				var targetBody = a.pieceType == LAUNCHER ? A : B;
				var projectileBody = b.pieceType == PROJECTILE ? B : A;
				var target:Launcher = cast targetBody.data.gamePiece;
				// var projectile:Projectile = cast projectileBody.data.gamePiece;
				target.takeDamage(projectileBody);
			}
		}));
		worldListeners.push(pear.scene.phys.world.listen(opponentTargets.projectiles, targets.projectiles, {
			enter: (A, B, collisions) -> {
				var a = A.getVitals();
				var b = B.getVitals();
				// no friendly fire!
				if (a.player == b.player)
					return;
				// ONLY same type collisions handled  here
				if (a.pieceType != b.pieceType)
					return;

				if(a.pieceType == PROJECTILE){
					// var ours = a.player == playerId ? A : B;
					// var theirs = a.player == playerId ? B : A;
					var pieceA:Projectile = cast A.data.gamePiece;
					var pieceB:Projectile = cast B.data.gamePiece;
					pieceA.expire();
					pieceB.expire();
				}
			}
		}));

		#if debug
		trace('new launcher at $position');
		#end
	}

	public function initProjectile():Projectile {
		var behaviourCheckFrequency = 0.064; // 4 frames?
		var behaviour = pear.delayFactory.Default(behaviourCheckFrequency, true, true);
		var piece = new Projectile({player: vitals.player, pieceType: PROJECTILE}, pear.scene.phys, body.x, body.y, projectile, behaviour, isFlippedX);
		projectiles.push(piece);
		targets.projectiles.push(piece.body);
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
			// trace(log);
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
		for (l in worldListeners) {
			pear.scene.phys.world.listeners.remove(l);
		}
		expire();
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
	var mouseFollow:Vector2->Void;

	override function click() {
		if (mouseFollow == null) {
			mouseFollow = pear.followMouse(this);
		} else {
			pear.input.onMouseMove.disconnect(mouseFollow);
			mouseFollow = null;
		}
	}

	override public function update(dt:Float) {
		if(isExpired) return;
		super.update(dt);

		if (projectiles.length < stats.maxProjectiles) {
			rateLimiter.wait(dt, onRateLimitFinish);
			prepareShot.wait(dt, onPrepareShotFinish);
			madeShot.wait(dt, onMadeShotFinish);
		}
		recoverFromHit.wait(dt, onRecoverFromHit);

		for (p in projectiles) {
			if(p.isExpired) continue;
			
			p.update(dt);

			if(p.isRemoveNextUpdate || pear.scene.phys.isOutOfBounds(p.body)){
				p.isExpired = true;
			}

			if(p.isExpired){
				projectiles.remove(p);
				targets.projectiles.remove(p.body);
				p.dispose();
			}
		}
	}

	// public function moveTo(speed:Float, moveBy:Vector2) {
	// 	// todo tween this
	// 	body.velocity.x = speed;
	// 	// body.active = true;
	// 	trace('ent velocity ${body.velocity}');
	// 	body.set_position(pear.window.width * 0.5, pear.window.height * 0.5);
	// }

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
