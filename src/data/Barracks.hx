package data;
import core.Launcher.LauncherStats;
import data.Global.ElementKey;
import data.Global.Size;
import lime.math.Vector2;

class Barracks {
	
	public static var Launchers:Map<ElementKey, LauncherStats> = [
		lDOGGER => {
			tag: "dogger",
			imageKey: lDOGGER,
			shape: RECT,
			heightMinMax: new Vector2(0.9, 0.99),
			bodySize: Size.calcVisual(2, 3),
			visualSize: Size.calcBody(2, 3),
			health: 200,
			trajectory: new Vector2(130, -130),
			projectileStats: Projectiles.DOG_HURL,
			states: [Idle => 0.7, Prepare => 0.2, Shoot => 0.1, TakeDamage => 0.2],
			movements: [{
				velocity: new Vector2(45, 0),
				durationMs: 1.2 / 1000,
			},
			{
				velocity: new Vector2(-45, 0),
				durationMs: 1.2 / 1000,
			}]
		},
		lBUBBLER => {
			tag: "hair balls",
			color: 0xb8a723cc,
			imageKey: lBUBBLER,
			shape: RECT,
			heightMinMax:new Vector2(0.98, 0.99),
			bodySize: Size.calcVisual(1, 1),
			visualSize: Size.calcBody(1, 1),
			health: 100,
			trajectory: new Vector2(130, -130),
			projectileStats: Projectiles.BUBBLE,
			states: [Idle => 24 * 0.016, Prepare => 24 *  0.016, Shoot => 24 * 0.016, TakeDamage => 24 * 0.016],
			movements: []
		},
		lBUILDING => {
			tag: "leaks 'knights'",
			color: 0x95b0afcc,
			imageKey: lBUILDING,
			shape: RECT,
			heightMinMax:new Vector2(0.68, 0.80),
			bodySize: Size.calcVisual(3, 5),
			visualSize: Size.calcBody(3, 5),
			health: 100,
			trajectory: new Vector2(50, 0),
			projectileStats: Projectiles.KNIGHT,
			states: [Idle => 200 * 0.016, Prepare => 24 *  0.016, Shoot => 24 * 0.016, TakeDamage => 24 * 0.016],
			movements: []
		},
		lARCHER => {
			tag: "pings arrows",
			color: 0x3b6940cc,
			imageKey: lARCHER,
			shape: RECT,
			heightMinMax:new Vector2(0.33, 0.50),
			bodySize: Size.calcVisual(2, 3),
			visualSize: Size.calcBody(2, 3),
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
		lFOWLER => {
			tag: "throws fowl",
			color: 0x3b6940cc,
			imageKey: lFOWLER,
			shape: RECT,
			heightMinMax:new Vector2(0.33, 0.50),
			bodySize: Size.calcVisual(1, 1),
			visualSize: Size.calcBody(1, 1),
			health: 100,
			trajectory: new Vector2(130, -130),
			projectileStats: Projectiles.FOWL,
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
		}
	];

}