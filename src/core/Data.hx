package core;

import core.Launcher.LauncherStats;
import core.Launcher.ProjectileStats;
import lime.graphics.Image;
import lime.math.Vector2;
import utils.Loader;

@:enum abstract ElementKey(Int) from Int to Int {
	var RECT;
	var CIRCLE;
	var POLYGON;
	var TITLE;
	var LORD;
	var KENNEL;
	var DOG;
	var CAVALRY;
}

class Preload {
	static var assetPaths(default, null):Map<ElementKey, String> = [
		TITLE => 'assets/png/LLG7TH.png',
		LORD => 'assets/png/templord.png',
		KENNEL => 'assets/png/beasthouse.png',
		DOG => 'assets/png/dog.png',
		CAVALRY => 'assets/png/cavalry.png'
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
			isFlippedX: false,
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
			isFlippedX: false,
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
