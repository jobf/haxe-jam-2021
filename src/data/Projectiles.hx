package data;

import core.Projectile.ProjectileStats;
import core.Projectile;
import data.Global.Size;
import lime.math.Vector2;
import ob.pear.Random;


class Behaviors{
	static var fps:Float = 60;
	static function secToMs(durationSeconds){
		return (durationSeconds * fps) * (1 / fps);
	}
	static function stop(p:Projectile){
		p.body.acceleration.y = 0;
		p.body.velocity.y = 0;
		p.body.rotational_velocity= 0;
		p.body.rotation = 0;
		p.body.max_velocity.y = 0;
	}
	
	public static var stopAt400:Projectile->Bool = projectile -> {
			if(projectile.body.y >= 400){
				projectile.body.acceleration.y = 0;
				projectile.body.velocity.y = 0;
				projectile.body.rotational_velocity= 0;
				projectile.body.rotation = 0;
				projectile.body.max_velocity.y = 0;
			}
			return false; // stop doing behaviors
		}

	public static var wanderingSwordsman:Projectile->Bool = projectile -> {
		projectile.changeBehaviorTime(secToMs(2));
		projectile.body.velocity.y = Random.range(-50, 50);
		if(projectile.cloth.y <= (projectile.cloth.h * 0.5)) {
			trace('hit top');
			projectile.body.velocity.y = Math.abs(projectile.body.velocity.y);
		}
		// projectile.body.velocity.x = Random.range(-50, 50);
		var canKeepMoving = projectile.body.collided;
		if(!canKeepMoving){
			stop(projectile);
		}
		return canKeepMoving;
	}
}

class Projectiles{
	public static var DOG_HURL:ProjectileStats = {
		color: 0xffffffdd,
		imageKey: pDog,
		shape: CIRCLE,
		visualSize: Size.calcVisual(2, 1),
		damagePower: 40,
		bodyOptions: {
			shape: {
				type: CIRCLE,
				width: Size.calcBody(2, 1).x,
				height: Size.calcBody(2, 1).y,
				radius: 5,
				solid: true
			},
			elasticity: 0.9,
			rotational_velocity: 8, // Math.abs(Random.range(300, 360)),
			max_rotational_velocity: 10,
		},
		tag: "Hurl't dogg",
		behaviours:[],
	};


	public static var FOWL:ProjectileStats = {
		color: 0xffffffdd,
		imageKey: pFowl,
		shape: CIRCLE,
		visualSize: Size.calcVisual(1, 1),
		damagePower: 75,
		bodyOptions: {
			shape: {
				type: CIRCLE,
				width: 8,
				height: 8,
				radius: 4,
				solid: true
			},
			elasticity: 0.9,
			rotational_velocity: 8, // Math.abs(Random.range(300, 360)),
			max_rotational_velocity: 10,
		},
		tag: "feathered friend",
		behaviours:[],
	};

	public static var BUBBLE:ProjectileStats = {
		color: 0xb8a723ff,
		imageKey: CIRCLE,
		shape: CIRCLE,
		damagePower: 20,
		bodyOptions: {
			shape: {
				type: CIRCLE,
				width: 8,
				height: 8,
				radius: 4,
				solid: true
			},
			elasticity: 0.9,
			rotational_velocity: 8, // Math.abs(Random.range(300, 360)),
			max_rotational_velocity: 10,
		},
		tag: "wat bubble",
		behaviours:[],
	};

	public static var KNIGHT:ProjectileStats = {
		color: 0x95b0afFF,
		imageKey: pMelee,
		shape: RECT,
		visualSize: Size.calcVisual(2, 3),
		damagePower: 60,
		bodyOptions: {
			shape: {
				type: RECT,
				width: Size.calcBody(2, 3).x,
				height: Size.calcBody(2, 3).y,
				// radius: (30 * 0.7) * 0.5,
				solid: true
			},
			kinematic: true,
			elasticity: 0.9,
			max_rotational_velocity: 0,
			max_velocity_y: 0,
			velocity_y: 0,
			velocity_x: 0
		},
		tag: "swordsman",
		behaviours:[Behaviors.wanderingSwordsman],
	};


	public static var ARROW:ProjectileStats = {
		color: 0x3b6940ff,
		imageKey: RECT,
		shape: RECT,
		damagePower: 20,
		bodyOptions: {
			shape: {
				type: RECT,
				width: 10,
				height: 2,
				radius: 1,
				solid: false
			},
			elasticity: 0.9,
			rotational_velocity: 0, // Math.abs(Random.range(300, 360)),
			max_rotational_velocity: 0,
		},
		tag: "swordsman",
		behaviours:[],
	};
}

