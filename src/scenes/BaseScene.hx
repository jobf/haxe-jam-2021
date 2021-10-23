package scenes;

import data.Global.ElementKey;
import data.Global.Layers;
import echo.data.Options.WorldOptions;
import lime.graphics.Image;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Input.ClickHandler;
import ob.pear.Scene;
import peote.view.Color;

class BaseScene extends Scene {
	var cursor:ShapePiece;
	var images:Map<ElementKey, Image>;

	
	public var clickHandler(default, null):ClickHandler;
	override public function new(pear:Pear, options:WorldOptions = null, backgroundColor:Color = 0xbdb6aeff, images:Map<ElementKey, Image>) {
		options = options != null ? options : {
			width: pear.window.width,
			height: pear.window.height,
			gravity_y: 0,
			iterations: 1,
			history: 1
		};
		this.images = images;
		super(pear, options, backgroundColor);
	}

	override function init() {

		super.init();

		var cursorSize = pear.window.height * 0.07;
		cursor = phys.initShape(ElementKey.CIRCLE, Global.cursorColor, {
			x: pear.window.width * 0.5,
			y: pear.window.height * 0.5,
			velocity_y: 0,
			velocity_x: 0,
			max_velocity_y: 0,
			max_velocity_x: 0,
			kinematic: true,
			shape: {
				type: CIRCLE,
				radius: cursorSize * 0.5,
				width: cursorSize,
				height: cursorSize,
				solid: false
			}
		}, false);
		cursor.cloth.z = Layers.CURSOR;
		cursor.body.data.isCursor = true;
		cursor.body.data.gamePiece = cursor;
		pear.followMouse(cursor);
		// todo
		// phys.world.listen(cursor.body, everything, {
		// 	enter: (A, B, collisions) -> {
		// 		if(A.data.isCursor != null){
		// 			var cursor:ShapePiece = A.data.gamePiece;
		// 			cursor.setColor(Color.RED);
		// 		}
		// 	},
		// 	exit: (A, B) -> {
		// 		if(A.data.isCursor != everything){
		// 			var cursor:ShapePiece = A.data.gamePiece;
		// 			cursor.setColor(Color.GREEN);
		// 		}
		// 	}
		// });

		clickHandler = new ClickHandler(cursor, phys.world);
		pear.input.onMouseDown.connect((sig) -> clickHandler.onMouseDown());

		// todo remove before release
		pear.input.onKeyDown.connect((sig) -> {
			// restart scene
			if (sig.key == BACKSPACE)
				pear.changeScene(new WaveSetupScene(pear, images));
		});

	}
	override function update(deltaTimeMs:Float) {
		super.update(deltaTimeMs);
		clickHandler.update(deltaTimeMs);
	}
}
