package scenes;

import data.Global.ElementKey;
import data.Global;
import echo.Echo;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Pear;
import ob.pear.Sprites.ShapeElement;
import peote.view.Color;
import peote.view.PeoteGL.Image;

class RoundEnded extends BaseScene {
	override public function new(pear:Pear, images:Map<ElementKey, Image>) {
		super(pear, images);
	}

	override function init() {
		super.init();
		ShapeElement.init(vis.display, RECT, ROUNDOVER, images[ROUNDOVER]);
		ShapeElement.init(vis.display, RECT, RESTART, images[RESTART]);
		ShapeElement.init(vis.display, RECT, QUIT, images[QUIT]);

		var title = pear.initShape(ElementKey.ROUNDOVER, Color.CYAN, {
			x: pear.window.width * 0.5,
			y: pear.window.height * 0.5,
			elasticity: 0.0,
			rotational_velocity: 0.0,
			shape: {
				type: RECT,
				width: 200,
				height: 100,
				solid: false,
			}
		}, false);


		restart = pear.initShape(ElementKey.RESTART, Color.CYAN, {
			x: 200 * 0.5,
			y: 200,
			elasticity: 0.0,
			rotational_velocity: 0.0,
			shape: {
				type: RECT,
				width: 200,
				height: 100,
				solid: false,
			}
		}, false);

		quit = pear.initShape(ElementKey.QUIT, Color.CYAN, {
			x: pear.window.width - (200 * 0.5),
			y: 200,
			elasticity: 0.0,
			rotational_velocity: 0.0,
			shape: {
				type: RECT,
				width: 200,
				height: 100,
				solid: false,
			}
		}, false);

		pear.input.onMouseDown.connect((sig) -> {
			if (canUpdate) {
				Echo.check(phys.world, cursor.body, restart.body, {
					enter: (cursor, target, collisions) -> {
						pear.changeScene(new ScorchedEarth(pear, images));
					},
				});
			}
		});

		pear.input.onMouseDown.connect((sig) -> {
			if (canUpdate) {
				Echo.check(phys.world, cursor.body, quit.body, {
					enter: (cursor, target, collisions) -> {
						pear.changeScene(new Title(pear, images));
					},
				});
			}
		});
	}

	var restart:ShapePiece;
	var quit:ShapePiece;
}
