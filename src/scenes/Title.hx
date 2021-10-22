package scenes;

import data.Global.ElementKey;
import ob.pear.Pear;
import ob.pear.Sprites.ShapeElement;
import peote.view.Color;
import peote.view.PeoteGL.Image;

class Title extends BaseScene {
	override public function new(pear:Pear, images:Map<ElementKey, Image>) {
		super(pear, images);
	}

	override function init() {
		super.init();
		ShapeElement.init(vis.display, RECT, TITLE, images[TITLE]);

		var title = pear.initShape(ElementKey.TITLE, Color.CYAN, {
			x: pear.window.width * 0.5,
			y: pear.window.height * 0.5,
			elasticity: 0.0,
			rotational_velocity: 0.0,
			shape: {
				type: RECT,
				// radius: size * 0.5,
				width: pear.window.width,
				height: pear.window.height,
				solid: false,
			}
		}, false);

		pear.input.onMouseDown.connect((sig) -> {
			pear.changeScene(new ScorchedEarth(pear, images));
		});
	}
}
