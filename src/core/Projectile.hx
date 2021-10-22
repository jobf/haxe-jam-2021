package core;

import core.Data.ElementKey;
import core.Pieces;
import echo.data.Options.BodyOptions;
import echo.data.Types.ShapeType;
import lime.math.Vector2;
import ob.pear.Delay;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Physical;

using ob.pear.Delay.DelayExtensions;
using ob.pear.Util.IntExtensions;

typedef ProjectileStats = {
	color:Int,
	imageKey:ElementKey,
	shape:ShapeType,
	?visualSize:Vector2,
	damagePower:Float,
	?bodyOptions:BodyOptions,
	tag:String,
	behaviours:Array<Projectile->Bool>
};



class Projectile extends OverlordPiece {
	public function new(vitals:Vitals, phys:Physical, x:Float, y:Float, stats:ProjectileStats, behaviour_:Delay, isFlippedX:Bool = false) {
		this.stats = stats;
		var body = phys.world.make(stats.bodyOptions);
		body.x = x;
		body.y = y;
		body.data.projectileData = stats;
		body.data.gamePiece = this;
		behaviour = behaviour_;
		super(stats.imageKey, vitals, stats.color, stats.visualSize.x, stats.visualSize.y, body, isFlippedX);
	}

	public function resetVelocity(){
		body.velocity.set(0,0);
	}



	override function update(deltaMs:Float) {
		if(isExpired) return;
		super.update(deltaMs);
		behaviour.wait(deltaMs, nextBehaviour);
	}

	function nextBehaviour() {
		// if behaviour is finished
		if(stats.behaviours.length < 1){
			return;
		}
		if(stats.behaviours[behaviourIndex](this)){
			// advance to next behavior
			trace('next beaviour');
			behaviourIndex.incrementMax(stats.behaviours.length -1);
		};
	}

	function nextMovement() {
		// todo?
		return;
	}

	var movementIndex:Int;
	var movement:Delay;
	
	var behaviourIndex:Int;
	var behaviour:Delay;

	var stats:ProjectileStats;
}
