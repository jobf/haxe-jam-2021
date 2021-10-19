package core;

import core.Launcher.LauncherStats;
import core.Launcher.ProjectileStats;
import lime.math.Vector2;

@:enum abstract ElementKey(Int) from Int to Int {
	var RECT;
	var CIRCLE;
	var POLYGON;
	var LORD;
	var KENNEL;
	var DOG;
	var CAVALRY;
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
			states: [Idle => 0.7, Prepare => 0.2, Shoot => 0.1],
			distanceFromWaveMin: new Vector2(10, 10),
			distanceFromWaveMax: new Vector2(300, 300),
		},
		CAVALRY => {
			imageKey: CAVALRY,
			shape: RECT,
			bodySize: new Vector2(340, 120),
			visualSize: new Vector2(520, 280),
			health: 50,
			isFlippedX: false,
			trajectory: new Vector2(130, -130),
			states: [Idle => 0.7, Prepare => 0.2, Shoot => 0.1],
			distanceFromWaveMin: new Vector2(10, 10),
			distanceFromWaveMax: new Vector2(300, 300),
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
