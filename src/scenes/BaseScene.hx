package scenes;

import data.Global.ElementKey;
import echo.data.Options.WorldOptions;
import lime.graphics.Image;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Pear;
import ob.pear.Scene;
import ob.pear.Text.GlyphStyleTiled;
import peote.text.Font;
import peote.view.Color;

class BaseScene extends Scene {
	var cursor:ShapePiece;
	var images:Map<ElementKey, Image>;

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
		cursor = phys.initShape(ElementKey.CIRCLE, 0x44ff44aa, {
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

		pear.followMouse(cursor);
	}

}
