package ob.pear;


import echo.data.Options.BodyOptions;
import lime.math.Vector2;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Input.ClickHandler;
import ob.pear.Text.GlyphStyleTiled;
import peote.text.Line;
import peote.view.Color;


typedef Box = {x:Float, y:Float, w:Float, h:Float, ?margin:Float};

class TextButton extends ShapePiece {
	var pear:Pear;

	var line:Line<GlyphStyleTiled>;

	public var onClick:TextButton->Void;

	public function new(pear_:Pear, color:Color, x:Float, y:Float, size:Vector2, text:String) {
		pear = pear_;
		var isFlippedX = false;
		// is the really needed?
		// // position is center of entity so adjust to fit.
		// x += size.x * 0.5; // nudge towards right of screen by 50% of size
		// y -= size.y * 0.5; // nudge towards top of screen by 50% of size
		var bodyOptions:BodyOptions = {
			kinematic: true, // ! important !
			x: x,
			y: y,
			elasticity: 0.0,
			rotational_velocity: 0.0,
			shape: {
				type: RECT,
				width: size.x,
				height: size.y,
				solid: false,
			}
		};
		var body = pear.scene.phys.world.make(bodyOptions);
		super(RECT, color, bodyOptions.shape.width, bodyOptions.shape.height, body, isFlippedX);
		var textX = body.x - bodyOptions.shape.width * 0.5;//x - size.x * 0.5
		var textY = body.y - Global.fontSize * 0.5;// - bodyOptions.shape.height * 0.5;//y - size.y * 0.5
		line = pear.scene.vis.text.write(text, body.x, body.y);
		
		// line.get_height
		// line.y -= line.height * 0.5;
		cloth.z = Layers.BUTTONS;
	}

	override function click() {
		super.click();
		if (onClick != null) {
			onClick(this);
		}
	}

}


typedef ButtonConfig = {text:String, action:TextButton -> Void}

class ButtonGrid{
	public function new(pear:Pear, clickHandler:ClickHandler, buttons:Array<ButtonConfig>, container:Box){
		
		if(container.margin == null) container.margin = 0.0;
		container.w -= container.margin * 0.5;
		container.h -= container.margin * 0.5;
		container.x += container.margin;
		container.y += container.margin;
		
		var buttonsize = new Vector2(container.w / 4, container.h / 5);
		var numColumns = Std.int(container.w / buttonsize.x);
		var numRows = Std.int(container.h / buttonsize.y);

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
				var button = new TextButton(pear, Global.colors[A], buttonX, buttonY, buttonsize, b.text);
				button.body.data.gamePiece = button;
				clickHandler.registerPiece(button);
				button.onClick = b.action;

				i++;
			}
		}
	}
}