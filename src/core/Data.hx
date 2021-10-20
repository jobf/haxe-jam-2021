package core;

import core.Launcher.LauncherStats;
import core.Launcher.ProjectileStats;
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
	public static var Launchers:Map<ElementKey, LauncherStats> = [
		KENNEL => {
			imageKey: KENNEL,
			shape: RECT,
			bodySize: new Vector2(150, 150),
			visualSize: new Vector2(180, 180),
			health: 100,
			trajectory: new Vector2(130, -130),
			states: [Idle => 0.7, Prepare => 0.2, Shoot => 0.1, TakeDamage => 0.2],
			distanceFromWaveMin: new Vector2(10, 10),
			distanceFromWaveMax: new Vector2(300, 300),
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
			distanceFromWaveMin: new Vector2(10, 10),
			distanceFromWaveMax: new Vector2(300, 300),
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
			bodySize: new Vector2(16, 16),
			visualSize: new Vector2(90, 90),
			damagePower: 20
		}
	];
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
					waveCenter: new Vector2(1000, 330)
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
					waveCenter: new Vector2(1000, 330)
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
					waveCenter: new Vector2(1000, 330)
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
					waveCenter: new Vector2(1000, 330)
				},
			]
		}
	];
}
