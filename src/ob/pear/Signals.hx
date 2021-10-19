package ob.pear;

import lime.math.Vector2;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import zigcall.SignalP;

class MouseButtonSignal {
	public var x:Float;
	public var y:Float;

	var button:MouseButton;

	public function new(x_:Float, y_:Float, button_:MouseButton) {
		x = x_;
		y = y_;
		button = button_;
	}
}

class KeyPressSignal {
	public var key:KeyCode;
	public var modifier:KeyModifier;
	public var isDown:Bool;

	public function new(key_:KeyCode, modifier_:KeyModifier, isDown_:Bool) {
		key = key_;
		modifier = modifier_;
		isDown = isDown_;
	}
}

class Signals {
	public var onKeyDown(default, null):SignalP<KeyPressSignal>;
	public var onKeyUp(default, null):SignalP<KeyPressSignal>;

	public var onMouseMove(default, null):SignalP<Vector2>;
	public var onMouseDown(default, null):SignalP<MouseButtonSignal>;
	public var onMouseUp(default, null):SignalP<MouseButtonSignal>;
	public var onMouseWheel(default, null):SignalP<Vector2>;

	public function new() {
		onKeyDown = new SignalP<KeyPressSignal>();
		onKeyUp = new SignalP<KeyPressSignal>();
		onMouseMove = new SignalP<Vector2>();
		onMouseDown = new SignalP<MouseButtonSignal>();
		onMouseUp = new SignalP<MouseButtonSignal>();
		onMouseWheel = new SignalP<Vector2>();
	}
}
