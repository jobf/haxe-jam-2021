package;

import scenes.ScorchedEarth;
import haxe.CallStack;
import ob.pear.Pear;
import lime.ui.MouseWheelMode;
import lime.app.Application;
import lime.ui.Window;
import lime.graphics.RenderContext;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

class PearShaped extends Application {
	var pear:Pear;
	var sceneIndex:Int = 0;

	public function init(window:Window) {
		pear = new Pear(window);
		
		Preload.letsGo(ScorchedEarth.assetPaths, (imageMap)->{
			pear.changeScene(new ScorchedEarth(pear, imageMap));
		});
	}

	override function onWindowCreate():Void {
		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					init(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	public override function update(deltaTime:Int):Void {
		pear.update(deltaTime);
	}

	override function render(context:RenderContext) {
		pear.render();
	}


	/* ~~~~~~~~~~~~~~~~~ Keyboard Events ~~~~~~~~~~~~~~~~~ */
	override function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void {
		#if !html5
		if (keyCode == ESCAPE) {
			window.close();
		}
		#end
		pear.onKeyDown(keyCode, modifier);
	}

	override function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void {
		pear.onKeyUp(keyCode, modifier);
	}
	
	/* ~~~~~~~~~~~~~~~~~ Mouse Events ~~~~~~~~~~~~~~~~~ */

	override function onMouseMove(x:Float, y:Float) {
		pear.onMouseMove(x, y);
	}

	override function onMouseDown(x:Float, y:Float, button:MouseButton):Void {
		pear.onMouseDown(x, y, button);
	}

	override function onMouseUp(x:Float, y:Float, button:MouseButton):Void {
		pear.onMouseUp(x, y, button);
	}

	override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		pear.onMouseScroll(deltaX, deltaY);
	}

}


