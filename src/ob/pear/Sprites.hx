package ob.pear;

import echo.data.Types.ShapeType;
import lime.graphics.Image;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.Element;
import peote.view.Program;
import peote.view.Texture;

class ShapeElement implements Element {
	@color public var color:Color;
	@custom @varying public var radius:Float;
	@custom @varying public var sides:Float = 3.0;
	@custom @varying public var isSelected:Float = 0.0;
	@posX @set("Position") public var x:Float;
	@posY @set("Position") public var y:Float;
	@sizeX @varying public var w:Int;
	@sizeY @varying public var h:Int;
	@pivotX @formula("w * 0.5 + px_offset") public var px_offset:Float;
	@pivotY @formula("h * 0.5 + py_offset") public var py_offset:Float;

	@rotation public var rotation:Float;
	@zIndex // max 0x3FFFFFFF , min -0xC0000000
	public var z:Int = 0;

	public static var buffers(default, null):Map<Int, Buffer<ShapeElement>> = [];
	public static var programs(default, null):Map<Int, Program> = [];

	static public function init(display:Display, shape:ShapeType, key:Int, image:Image = null) {
		buffers[key] = new Buffer<ShapeElement>(100, 100);
		programs[key] = new Program(buffers[key]);

		var fragmentShader = switch (shape) {
			case CIRCLE: ShapeShaders.CIRCLE;
			case POLYGON: ShapeShaders.TRIANGLE;
			case _: "";
		}

		if (image != null) {
			var texture = new Texture(image.width, image.height);
			texture.setImage(image, 0);
			programs[key].setTexture(texture, '_$key');
			var isDebug = false;
			var textureProgram:String = "";
			#if debug
			isDebug = true;
			#end
			var t = '';
		#if html5
			t = 'texture';
		#else 
			t	= 'texture2D'; 
		#end
			var composeTex0:String = '
			vec4 composeTex (vec4 c, float sides, float selected)
			{
				vec4 shapeColor = compose(c, sides);
				return mix($t(uTexture0, vTexCoord), shapeColor, vec4(0.5));
			}
			';
			var composeTex1:String = '
			vec4 composeTex (vec4 c, float sides, float selected)
			{
				vec4 texColor = $t(uTexture0, vTexCoord);
				if(selected == 1.0 && texColor.a < 0.9){
					texColor.r = 1.0;
					texColor.a = 1.0;
				}
				return texColor;
			}
			';
			textureProgram = fragmentShader.length > 0 && isDebug ? composeTex0 : composeTex1;
			fragmentShader += textureProgram;
			programs[key].injectIntoFragmentShader(fragmentShader);
			programs[key].setColorFormula('composeTex(color, sides, isSelected)');
		} else {
			if (fragmentShader.length > 0) {
				programs[key].injectIntoFragmentShader(fragmentShader);
				programs[key].setColorFormula('compose(color, sides)');
			}
		}

		programs[key].alphaEnabled = true;
		display.addProgram(programs[key]);
	}

	public function new(key:Int, positionX:Float, positionY:Float, width:Float, height:Float, color:Color, shape:ShapeType, numSides:Float = 3,
			isFlippedX:Bool) {
		this.x = positionX;
		this.y = positionY;
		width = isFlippedX ? width * -1 : width;
		this.w = Std.int(width);
		this.h = Std.int(height);
		this.radius = w / 2;
		this.color = color;
		this.sides = numSides;
		if (!buffers.exists(key)) {
			throw 'No buffer exists for the key [$key] make sure to Init the ShapeElement';
		}
		buffers[key].addElement(this);
		#if debug
		trace('new element pos [${this.x}, ${this.y}]  dim [${this.w} (${this.radius}) * ${this.h}] pivot [${this.px_offset}, ${this.py_offset}] colour [${this.color}] sides [${this.sides}]');
		#end
	}
}

class ShapeShaders {
	public static var CIRCLE:String = "
		float circle(in vec2 st, in float radius){
			vec2 dist = st-vec2(0.5);
			return 1.-smoothstep(radius-(radius*0.01),
									radius+(radius*0.01),
									dot(dist,dist)*4.0);
		}

		vec4 compose (vec4 c, float sides)
		{
			float a = circle(vTexCoord, 1.0) == 1.0 ? c.a : 0.0;
			return vec4(c.rgb, a);
		}
	";

	public static var TRIANGLE:String = "
		#define PI 3.14159265359
		#define TWO_PI 6.28318530718

		vec4 compose (vec4 c, float sides)
		{
			// Remap the coord for
			vec2 coord = vTexCoord;
			coord.y = (1.0 - coord.y);

			// Remap the space to -1. to 1.
			vec2 st = coord * 2.0-1.0;

			// Angle and radius from the current pixel
			float r = TWO_PI/sides;
			float a = atan(st.x,st.y) + PI;

			// Shaping function that modulate the distance
			float d = cos(floor(.5+a/r)*r-a)*length(st);

			float A = 1.0-smoothstep(.5,.51,d) == 1.0 ? c.a : 0.0;
			return vec4(c.rgb, A);
		}
	";
}
