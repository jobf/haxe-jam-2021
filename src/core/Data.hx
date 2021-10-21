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
		BOB => 'assets/png/templord.png', // todo real image for this
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
	public static var HEIGHTS:Map<ElementKey, Vector2> =[
		KENNEL => new Vector2(0.9, 0.99), // minmax percent of y
		CAVALRY => new Vector2(0.3, 0.6)
	];
	public static var Launchers:Map<ElementKey, LauncherStats> = [
		KENNEL => {
			imageKey: KENNEL,
			shape: RECT,
			bodySize: new Vector2(150, 150),
			visualSize: new Vector2(180, 180),
			health: 100,
			trajectory: new Vector2(130, -130),
			states: [Idle => 0.7, Prepare => 0.2, Shoot => 0.1, TakeDamage => 0.2],
			movements: []
		},
		CAVALRY => {
			imageKey: CAVALRY,
			shape: RECT,
			bodySize: new Vector2(340, 120),
			visualSize: new Vector2(520, 280),
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
	];

	public static var Projectiles:Map<ElementKey, ProjectileStats> = [
		DOG => {
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
		}
	];
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
						{
							launcher: Barracks.Launchers[KENNEL],
							projectile: Barracks.Projectiles[DOG]
						}
					],
					maximumActiveLaunchers: 2,
				},
				{
					launchers: [
						{
							launcher: Barracks.Launchers[CAVALRY],
							projectile: Barracks.Projectiles[DOG]
						},
						{
							launcher: Barracks.Launchers[CAVALRY],
							projectile: Barracks.Projectiles[DOG]
						},
						{
							launcher: Barracks.Launchers[CAVALRY],
							projectile: Barracks.Projectiles[DOG]
						}
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
						{
							launcher: Barracks.Launchers[KENNEL],
							projectile: Barracks.Projectiles[DOG]
						},
						{
							launcher: Barracks.Launchers[CAVALRY],
							projectile: Barracks.Projectiles[DOG]
						},
						{
							launcher: Barracks.Launchers[CAVALRY],
							projectile: Barracks.Projectiles[DOG]
						},
						{
							launcher: Barracks.Launchers[CAVALRY],
							projectile: Barracks.Projectiles[DOG]
						}
					],
					maximumActiveLaunchers: 2,
				},
				{
					launchers: [
						{
							launcher: Barracks.Launchers[CAVALRY],
							projectile: Barracks.Projectiles[DOG]
						},
						{
							launcher: Barracks.Launchers[CAVALRY],
							projectile: Barracks.Projectiles[DOG]
						},
						{
							launcher: Barracks.Launchers[CAVALRY],
							projectile: Barracks.Projectiles[DOG]
						}
					],
					maximumActiveLaunchers: 2,
				},
			]
		}
	];
}
