package ob.pear;

import echo.data.Options.BodyOptions;
import echo.data.Options.ListenerOptions;
import lime.math.Vector2;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.Window;
import ob.pear.Delay.DelayFactory;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Scene.TestScene;
import ob.pear.Signals.KeyPressSignal;
import ob.pear.Signals.MouseButtonSignal;
import peote.view.Color;

class Pear {
	public var scene(default, null):Scene;
	public var window(default, null):Window;
	public var delayFactory(default, null):DelayFactory;

	var mousePos:Vector2;
	var mouseWheelDelta:Vector2;

	public var input(default, null):Signals;

	public function new(window:Window, backgroundColor:Color = Color.GREY1) {
		this.window = window;
		input = new Signals();
		this.scene = new TestScene(this);
		onUpdate = defaultOnUpdate;
		mousePos = new Vector2();
		mouseWheelDelta = new Vector2();
		delayFactory = new DelayFactory();
	}

	public function followMouse(piece:IGamePiece, followLogic:(IGamePiece, Vector2) -> Void = null) {
		var followLogic = followLogic != null ? followLogic : (piece, pos) -> {
			piece.body.set_position(pos.x, pos.y);
		};

		input.onMouseMove.connect((pos) -> {
			followLogic(piece, pos);
		});
	}

	public function changeScene(nextScene:Scene, autoInit:Bool = true) {
		// reset input to clear old connections
		input = new Signals();

		if (scene != null) {
			scene.halt();
		}
		scene = nextScene;
		scene.init();
	}

	public function toggleRender() {
		scene.vis.toggleRender();
	}

	public var onUpdate:(Int, Pear) -> Void;

	function defaultOnUpdate(deltaTime:Int, core:Pear):Void {
		scene.phys.update(deltaTime);
	}

	public function update(deltaTime:Int):Void {
		onUpdate(deltaTime, this);
	}

	public function render() {
		scene.vis.render();
	}

	public function onKeyDown(keyCode:KeyCode, modifier:KeyModifier):Void {
		input.onKeyDown.emit(new KeyPressSignal(keyCode, modifier, true));
	}

	public function onKeyUp(keyCode:KeyCode, modifier:KeyModifier):Void {
		input.onKeyUp.emit(new KeyPressSignal(keyCode, modifier, false));
	}

	public function onMouseMove(x:Float, y:Float) {
		mousePos.x = x;
		mousePos.y = y;
		input.onMouseMove.emit(mousePos);
	}

	public function onMouseDown(x:Float, y:Float, button:MouseButton) {
		input.onMouseDown.emit(new MouseButtonSignal(x, y, button));
	}

	public function onMouseUp(x:Float, y:Float, button:MouseButton) {
		input.onMouseUp.emit(new MouseButtonSignal(x, y, button));
	}

	public function onMouseScroll(x:Float, y:Float) {
		mouseWheelDelta.x = x;
		mouseWheelDelta.y = y;
		input.onMouseWheel.emit(mouseWheelDelta);
	}

	public function initShape(elementKey:Int, colour:Color, options:BodyOptions, visualSize:{vWidth:Float, vHeight:Float} = null,
			isFlippedX:Bool = false):ShapePiece {
		return scene.phys.initShape(elementKey, colour, options, visualSize, isFlippedX);
	}

	public function setupCollision(a:IGamePiece, b:IGamePiece, options:ListenerOptions) {
		scene.phys.setupCollision(a.body, b.body, options);
	}
}
