package scenes;


import echo.Echo;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Pear;
import ob.pear.UI.TextButton;
import peote.view.PeoteGL.Image;

class RoundEnded extends BaseScene {
	override public function new(pear:Pear, images:Map<ElementKey, Image>) {
		super(pear, images);
	}

	override function init() {
		super.init();

		vis.text.write("the round is over ", 0, 0);
		var margin = pear.window.height * 0.015;
		var width = (pear.window.width * 0.5) - (margin * 2);
		var height = pear.window.height - (margin * 2);
		var container = {
			x: width + margin,
			y: margin,
			w: width,
			h: height
		};
		var buttonsize = new Vector2(width / 4, height / 5);

		var numColumns = Std.int(container.w / buttonsize.x);
		var numRows = Std.int(container.h / buttonsize.y);
		var buttons = [
			{
				text: "AGAIN!",
				action: (b) -> {
					pear.changeScene(new ScorchedEarth(pear, images));
				}
			},
			{
				text: "QUIT!",
				action: (b) -> {
					pear.changeScene(new Title(pear, images));
				}
			}
		];
		var i = 0;
		for (r in 0...numRows) {
			for (c in 0...numColumns) {
				var b = buttons[i];
				if (b == null) {
					// no more to display
					break;
				}
				var buttonX = container.x + (c * buttonsize.x) + buttonsize.x * 0.5;
				var buttonY = container.y + (r * buttonsize.x) + buttonsize.y * 0.5;
				var button = new TextButton(pear, 0xacb475FF, buttonX, buttonY, buttonsize, b.text);
				button.body.data.gamePiece = button;
				clickHandler.registerPiece(button);
				button.onClick = b.action;

				i++;
			}
		}
	}
}
