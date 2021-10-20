package ob.pear;

import ob.pear.GamePiece.ShapePiece;

typedef Delay = {
	duration:Float,
	currentTime:Float,
	isInProgress:Bool,
	isResetAuto:Bool,
}

typedef Tween<T> = {
	/**object being tweened**/
	target:T,
	/**resolution - in case want to check less frequently than every frame**/
	stepMs:Float,
	/**total step time - used to know a step duration was reached**/
	?currentMs:Float,
	/**how long since last looped**/
	?totalMs:Float,
	/** is tween started**/
	?isInProgress:Bool,
	/** will tween start again**/
	isLooped:Bool,
	/** data is arbitrary thus Dynamic**/
	data:Dynamic,
	/**target, data**/
	onStart:(T, Dynamic) -> Void,
	/**target, totalMs, data**/
	onCheck:(T, Float, Dynamic) -> Bool,
	/**target, data**/
	onTrue:(T, Dynamic) -> Void,
}

class DelayFactory {
	var framesPerSecond:Float;

	public function new(framesPerSecond:Float = 60) {
		this.framesPerSecond = framesPerSecond;
	}

	public function Default(durationSeconds:Float, isStarted:Bool = false, isResetAuto:Bool = false):Delay {
		return {
			duration: (durationSeconds * framesPerSecond) * (1 / framesPerSecond),
			isInProgress: isStarted,
			currentTime: 0.0,
			isResetAuto: isResetAuto
		};
	}
}

class TweenExtensions<T> {
	static public function tween<T>(t:Tween<T>, elapsed:Float) {
		if (!t.isInProgress) {
			t.onStart(t.target, t.data);
			t.isInProgress = true;
			t.currentMs = 0.0;
			t.totalMs = 0.0;
		}
		t.currentMs += elapsed;
		t.totalMs += elapsed;
		if (t.currentMs >= t.stepMs) {
			t.isInProgress = t.isLooped;
			t.currentMs = 0;
			if (t.onCheck(t.target, t.totalMs, t.data)) {
				t.onTrue(t.target, t.data);
				t.totalMs = 0.0;
			}
		}
	}
}

class DelayExtensions {
	static public function wait(d:Delay, elapsed:Float, onFinish:Void->Void) {
		if (!d.isInProgress)
			return;

		d.currentTime += elapsed;
		if (d.currentTime >= d.duration) {
			d.isInProgress = d.isResetAuto;
			d.currentTime = 0;
			onFinish();
		}
	}

	static public function evaluate(d:Delay, elapsed:Float, obj:ShapePiece, onTrue:(ShapePiece, Delay) -> Bool, onStart:ShapePiece->Void,
			onFinish:ShapePiece->Void) {
		// if (!is) {
		// 	onStart(obj);
		// 	d.isInProgress;
		// }

		d.currentTime += elapsed;
		if (onTrue(obj, d)) {
			onFinish(obj);
		}
		// todo add on progress? loop duration but only evaluate onProgress
		// if (d.currentTime >= d.duration) {
		// 	d.isInProgress = d.isResetAuto;
		// 	d.currentTime = 0;
		// 	onProgress(obj);
		// }
	}

	static public function start(d:Delay) {
		d.isInProgress = true;
	}
}
