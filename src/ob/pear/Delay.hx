package ob.pear;

import ob.pear.GamePiece.ShapePiece;

typedef Delay = {
	duration:Float,
	currentTime:Float,
	isInProgress:Bool,
	isResetAuto:Bool,
}

typedef Tween<T> = {
	target:T,
	stepMs:Float,
	currentMs:Float,
	isInProgress:Bool,
	isLooped:Bool,
	onStart:T->Void,
	onCheck:(T, Float) -> Bool,
	onTrue:(T) -> Void,
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
			t.onStart(t.target);
			t.isInProgress = true;
		}
		t.currentMs += elapsed;
		if (t.currentMs >= t.stepMs) {
			t.isInProgress = t.isLooped;
			t.currentMs = 0;
			if (t.onCheck(t.target, elapsed)) {
				t.onTrue(t.target);
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
