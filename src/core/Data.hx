package core;

import core.Launcher.LauncherStats;
import core.Projectile.ProjectileStats;
import core.Wave.WaveStats;
import lime.graphics.Image;
import lime.math.Vector2;
import utils.Loader;

class Global {
	public static var wonLastRound:Int = 0;
	public static var opponentIndex:Int = 0;
	public static var currentWaveSetup:WaveStats;
}

@:enum abstract ElementKey(Int) from Int to Int {
	var RECT;
	var CIRCLE;
	var POLYGON;
	var TITLE;
	var LORD;
	var KENNEL;
	var DOG;
	var CAVALRY;
	var ROUNDOVER;
	var RESTART;
	var QUIT;
	var BOB;
	var launcherBUBBLER;
	var launcherKNIGHTHOUSE;
	var launcherARCHERS;
	var projectileKNIGHT;
	// var projectileARROW;
}

class Preload {
	static var assetPaths(default, null):Map<ElementKey, String> = [
		TITLE => 'assets/png/LLG7TH.png',
		LORD => 'assets/png/templord.png',
		KENNEL => 'assets/png/beasthouse.png',
		DOG => 'assets/png/dog.png',
		CAVALRY => 'assets/png/cavalry.png',
		ROUNDOVER => 'assets/png/round-over.png',
		RESTART => 'assets/png/restart.png',
		QUIT => 'assets/png/quit.png',
		BOB => 'assets/png/templord.png',
		// launcherBUBBLER => '',
		// launcherKNIGHTHOUSE => '',
		// launcherARCHERS => '',
		// projectileKNIGHT =>  '',
	];

	public static function letsGo(onLoadAll:Map<ElementKey, Image>->Void) {
		var keyValues = [for (_ in assetPaths.keyValueIterator()) _];
		Loader.imageArray([for (kv in keyValues) kv.value], (images) -> {
			var imageMap:Map<ElementKey, Image> = [];
			for (i => kv in keyValues) {
				imageMap[kv.key] = images[i];
			}
			onLoadAll(imageMap);
		});
	}
}

class Barracks {

	public static var Launchers:Map<ElementKey, LauncherStats> = [
		KENNEL => {
			tag: "DOGCATS",
			imageKey: KENNEL,
			shape: RECT,
			heightMinMax: new Vector2(0.9, 0.99),
			bodySize: new Vector2(150, 150),
			visualSize: new Vector2(180, 180),
			health: 100,
			trajectory: new Vector2(130, -130),
			projectileStats: Projectiles.DOG_HURL,
			states: [Idle => 0.7, Prepare => 0.2, Shoot => 0.1, TakeDamage => 0.2],
			movements: []
		},
		CAVALRY => {
			tag: "HORSES",
			imageKey: CAVALRY,
			shape: RECT,
			heightMinMax: new Vector2(0.3, 0.6),
			bodySize: new Vector2(340, 120),
			visualSize: new Vector2(520, 280),
			projectileStats: Projectiles.DOG_HURL,
			health: 50,
			trajectory: new Vector2(130, -130),
			states: [Idle => 0.7, Prepare => 0.2, Shoot => 0.1, TakeDamage => 0.2],
			movements: [
				{
					velocity: new Vector2(15, 0),
					durationMs: 2.0,
				},
				{
					velocity: new Vector2(-15, 0),
					durationMs: 2.0,
				}
			]
		},
		launcherBUBBLER => {
			tag: "hair balls",
			color: 0xb8a723cc,
			imageKey: RECT,
			shape: RECT,
			bodySize: new Vector2(50, 35),
			heightMinMax:new Vector2(0.98, 0.99),
			visualSize: new Vector2(100, 70),
			health: 100,
			trajectory: new Vector2(130, -130),
			projectileStats: Projectiles.BUBBLE,
			states: [Idle => 24 * 0.016, Prepare => 24 *  0.016, Shoot => 24 * 0.016, TakeDamage => 24 * 0.016],
			movements: []
		},
		launcherKNIGHTHOUSE => {
			tag: "cannon fodder",
			color: 0x95b0afcc,
			imageKey: RECT,
			shape: RECT,
			heightMinMax:new Vector2(0.68, 0.80),
			bodySize: new Vector2(50, 35),
			visualSize: new Vector2(150, 100),
			health: 100,
			trajectory: new Vector2(50, 0),
			projectileStats: Projectiles.KNIGHT,
			states: [Idle => 100 * 0.016, Prepare => 24 *  0.016, Shoot => 24 * 0.016, TakeDamage => 24 * 0.016],
			movements: []
		},
		launcherARCHERS => {
			tag: "robin hoods",
			color: 0x3b6940cc,
			imageKey: RECT,
			shape: RECT,
			heightMinMax:new Vector2(0.33, 0.50),
			bodySize: new Vector2(50, 35),
			visualSize: new Vector2(150, 100),
			health: 100,
			trajectory: new Vector2(130, -130),
			projectileStats: Projectiles.ARROW,
			states: [Idle => 100 * 0.016, Prepare => 24 *  0.016, Shoot => 24 * 0.016, TakeDamage => 24 * 0.016],
			movements: [
				{
					velocity: new Vector2(30, 0),
					durationMs: 1.2 / 1000,
				},
				{
					velocity: new Vector2(-3, 0),
					durationMs: 3.0 / 1000,
				}
			]
		},
	];

}

class Projectiles{
	public static var DOG_HURL:ProjectileStats = {
		color: 0xffffffdd,
		imageKey: DOG,
		shape: CIRCLE,
		visualSize: new Vector2(90, 90),
		damagePower: 20,
		bodyOptions: {
			shape: {
				type: RECT,
				width: 16,
				height: 16,
				radius: 8,
				solid: true
			},
			elasticity: 0.9,
			rotational_velocity: 8, // Math.abs(Random.range(300, 360)),
			max_rotational_velocity: 10,
		},
		tag: "Hurl't dogg",
		behaviours:[],
	};

	public static var BUBBLE:ProjectileStats = {
		color: 0xb8a723ff,
		imageKey: CIRCLE,
		shape: CIRCLE,
		// visualSize: new Vector2(90, 90),
		damagePower: 20,
		bodyOptions: {
			shape: {
				type: CIRCLE,
				width: 16,
				height: 16,
				radius: 8,
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
		imageKey: RECT,
		shape: RECT,
		visualSize: new Vector2(50, 90),
		damagePower: 20,
		bodyOptions: {
			shape: {
				type: RECT,
				width: 16,
				height: 16,
				radius: 8,
				solid: false
			},
			kinematic: true,
			elasticity: 0.9,
			max_rotational_velocity: 0,
			max_velocity_y: 0,
			velocity_y: 0,
			velocity_x: 0
		},
		tag: "swordsman",
		behaviours:[],
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

class ProjectBehaviors{
	public static var stopAt400:Projectile->Bool = projectile -> {
			if(projectile.body.y >= 400){
				projectile.body.acceleration.y = 0;
				projectile.body.velocity.y = 0;
				projectile.body.rotational_velocity= 0;
				projectile.body.rotation = 0;
				projectile.body.max_velocity.y = 0;
			}
			return false;
		}
}

typedef OpponentConfig = {
	name:String,
	imageKey:ElementKey,
	waves:Array<WaveStats>
}

class Rounds {
	public static var opponents:Array<OpponentConfig> = [
		{
			name: "Bob the belidgerent",
			imageKey: BOB,
			waves: [
				{
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
				},
			]
		},
		{
			name: "Karl of the Kabal",
			imageKey: BOB,
			waves: [
				{
					launchers: [
						Barracks.Launchers[CAVALRY],
						Barracks.Launchers[CAVALRY],
						Barracks.Launchers[CAVALRY]
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
				},
			]
		}
	];
}
