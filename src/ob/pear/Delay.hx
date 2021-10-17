package ob.pear;

typedef Delay =
{
	var duration:Float;
	var currentTime:Float;
	var isInProgress:Bool;
	var isResetAuto:Bool;
}

class DelayFactory
{
	var framesPerSecond:Float;

	public function new(framesPerSecond:Float=60) {
		this.framesPerSecond = framesPerSecond;
	}

	public function Default(durationSeconds:Float, isStarted:Bool = false, isResetAuto:Bool = false):Delay
	{
		return {
			duration: (durationSeconds * framesPerSecond) * (1 / framesPerSecond),
			isInProgress: isStarted,
			currentTime: 0.0,
			isResetAuto: isResetAuto
		};
	}
}

class DelayExtensions
{
	static public function update(d:Delay, elapsed:Float, onFinish:Void->Void)
	{
		if (!d.isInProgress)
			return;

		d.currentTime += elapsed;
		if (d.currentTime >= d.duration)
		{
			d.isInProgress = d.isResetAuto;
			d.currentTime = 0;
			onFinish();
		}
	}

	static public function start(d:Delay)
	{
		d.isInProgress = true;
	}
}
