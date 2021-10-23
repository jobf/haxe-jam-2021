package ob.pear;


import echo.data.Options.BodyOptions;
import lime.math.Vector2;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Text.GlyphStyleTiled;
import peote.text.Line;
import peote.view.Color;


typedef Box = {x:Float, y:Float, w:Float, h:Float};

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

class ButtonArea{
	public function new(){
		
	}
}