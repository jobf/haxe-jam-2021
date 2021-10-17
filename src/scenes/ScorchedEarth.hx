package scenes;

import ob.pear.Delay;
import echo.data.Options.ListenerOptions;
import ob.pear.Pear;
import hxmath.math.Vector2;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.Scene;
import echo.data.Types.ShapeType;
using ob.pear.Delay.DelayExtensions;

typedef Projectile = {color:Int, shape:ShapeType, height:Float, width:Float};

class Launcher {
	var pear:Pear;
	var projectile:Projectile = {
		color: 0xffffffdd,
		shape: CIRCLE,
		width: 16,
		height: 16,
	};

	public var position(default, null):Vector2;
	public var trajectory(default, null):Vector2;
	public var projectiles(default, null):Array<IGamePiece> = [];

	var timer:Float = 0;
	var maxProjectiles = 20;
    var rateLimiter:Delay;

	public function new(pear_:Pear, position_:Vector2 = null, trajectory_:Vector2 = null) {
		pear = pear_;
        rateLimiter = pear.delayFactory.Default(1, true, true);
        trace(rateLimiter);

		position = position_ != null ? position_ : new Vector2(0, 0);
		trajectory = trajectory_ != null ? trajectory_ : new Vector2(0, 0);
	}

	public function initProjectile():IGamePiece {
        var projectile = pear.initShape(this.projectile.color, {
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
        
		projectiles.push(projectile);
		return projectile;
	}

	public function launchProjectile(projectile:IGamePiece) {
		projectile.body.velocity.set(trajectory.x, trajectory.y);
	}

    function onRateLimitFinish(){
        var p = initProjectile();
        launchProjectile(p);
    }

	public function update(dt:Float) {

		if (projectiles.length < maxProjectiles) {
            rateLimiter.update(dt, onRateLimitFinish);
		}

		for (p in projectiles) {
			if (pear.scene.phys.isOutOfBounds(p.body)) {
				// stop
				p.body.velocity.set(0, 0);
				// reset posiiton
				p.body.set_position(position.x, position.y);
				// ;aunch again
				launchProjectile(p);
			}
		}
	}
}

class ScorchedEarth extends Scene {
	var cursor:IGamePiece;
	var pieces:Array<IGamePiece> = [];
	var playerA:Launcher;

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

		phys.world.quadtree.max_depth = 2;
		phys.world.static_quadtree.max_depth = 3;

		var options:ListenerOptions = {
			// placeholder
		};

		phys.world.listen(options);

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

		// alter turret angle
		pear.input.onKeyDown.connect((sig) -> {
			var amount = 10;
			if (sig.key == UP) {
				playerTrajectoryA.y -= amount;
			}
			if (sig.key == DOWN) {
				playerTrajectoryA.y += amount;
			}

			if (sig.key == LEFT) {
				playerTrajectoryA.x -= amount;
			}
			if (sig.key == RIGHT) {
				playerTrajectoryA.x += amount;
			}
		});

		pear.onUpdate = pearUpdate;
	}

	function pearUpdate(dt:Int, p:Pear) {
        var deltaMs = phys.update(dt);
		playerA.update(deltaMs);
	}
}
