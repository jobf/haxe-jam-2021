package scenes;

import data.Global.ElementKey;
import data.Global.Layers;
import echo.Body;
import lime.math.Vector2;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Input.ClickHandler;
import ob.pear.Pear;
import ob.pear.Sprites.ShapeElement;
import ob.pear.UI.TextButton;
import peote.view.PeoteGL.Image;

class Title extends BaseScene {
	public var readyButton(default, null):TextButton;
	override public function new(pear:Pear, images:Map<ElementKey, Image>) {
		super(pear, images);
	}

	override function init() {
		super.init();
		phys.world.listen({});
		ShapeElement.init(vis.display, RECT, TITLE, images[TITLE]);
		var title = pear.initShape(ElementKey.TITLE, 0x00000000, {
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
		title.cloth.z = Layers.BACKGROUND;

		var buttonsize = new Vector2(pear.window.width / 4, pear.window.width / 5);
		var readyButtonX = pear.window.width - buttonsize.x + buttonsize.x * 0.5;
		var readyButtonY = pear.window.height - buttonsize.y + buttonsize.y * 0.5;
		readyButton = new TextButton(pear, 0xacb475FF, readyButtonX, readyButtonY, buttonsize, "START");
		readyButton.cloth.z = Layers.BUTTONS;
		readyButton.body.data.gamePiece = readyButton;
		clickHandler.registerPiece(readyButton);

// do this
// 		clickHandler.targets.push(readyButton.body);
// 		clickHandler.group.push(readyButton);




		readyButton.onClick = (button)->{
			pear.changeScene(new WaveSetupScene(pear, images));
		};
		

	}

	override function update(deltaMs:Float) {
		super.update(deltaMs);
	}
}
