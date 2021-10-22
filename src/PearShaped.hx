package;

import data.Global.Preload;
import haxe.CallStack;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;
import lime.ui.Window;
import ob.pear.Pear;
import ob.pear.Text.GlyphStyleTiled;
import peote.text.Font;
import scenes.ArtTestScene;
import scenes.RoundEnded;
import scenes.ScorchedEarth;
import scenes.Title;
import scenes.WaveSetupScene;

class PearShaped extends Application {
	var pear:Pear;
	var sceneIndex:Int = 0;
	
	var readyToUpdate = false;

	public function init(window:Window) {
		window.cursor = null;
		new Font<GlyphStyleTiled>('assets/fonts/peote.json').load((font) -> {
			pear = new Pear(window, font);
			Preload.letsGo((imageMap) -> {
				// pear.changeScene(new RoundEnded(pear, imageMap));
				// pear.changeScene(new ScorchedEarth(pear, imageMap));
				// pear.changeScene(new Title(pear, imageMap));
				pear.changeScene(new ArtTestScene(pear, imageMap));
				// pear.changeScene(new WaveSetupScene(pear, imageMap));
				readyToUpdate = true;
			});
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
		if (readyToUpdate) pear.update(deltaTime);
	}

	/* ~~~~~~~~~~~~~~~~~ Keyboard Events ~~~~~~~~~~~~~~~~~ */
	override function onKeyDown(keyCode:KeyCode, modifier:KeyModifier):Void {
		#if !html5
		if (keyCode == ESCAPE) {
			window.close();
		}
		#end
		pear.onKeyDown(keyCode, modifier);
	}

	override function onKeyUp(keyCode:KeyCode, modifier:KeyModifier):Void {
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

	override function onMouseWheel(deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode):Void {
		pear.onMouseScroll(deltaX, deltaY);
	}
}
