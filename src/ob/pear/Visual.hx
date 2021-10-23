package ob.pear;

import echo.data.Types.ShapeType;
import lime.ui.Window;
import ob.pear.Sprites.ShapeElement;
import ob.pear.Text;
import peote.text.Font;
import peote.text.FontProgram;
import peote.view.Buffer;
import peote.view.Color;
import peote.view.Display;
import peote.view.Element;
import peote.view.PeoteView;
import peote.view.Program;
import peote.view.Texture;

class Visual {
	var peoteView:PeoteView;

	public var display:Display;

	var frameBufferTexture:Texture;
	var mainDisplay:Display;
	var window:Window;
	var backgroundColor:Color;
	var font:Font<GlyphStyleTiled>;
	var fontProgram:FontProgram<GlyphStyleTiled>;
	public var text(default, null):Text;

	public function new(window:Window, font_:Font<GlyphStyleTiled>, backgroundColor:Color = Color.GREY1) {
		this.window = window;
		this.backgroundColor = backgroundColor;
	font = font_;
		
	}

	public function toggleRender() {
		display.renderFramebufferEnabled = !display.renderFramebufferEnabled;
	}

	public function start(enableRender:Bool = true) {
		peoteView = new PeoteView(window);
		

		frameBufferTexture = new Texture(window.width, window.height, 2, 4, true, 1, 1); // 2 Slots
		
		display = new Display(0, 0, window.width, window.height);

	
		
		peoteView.addDisplay(display); // this will only need to set the framebuffer-texture (needs a peote-view fix later!)
		display.setFramebuffer(frameBufferTexture);
		peoteView.removeDisplay(display); // no need to render this to the view anymore
		
		mainDisplay = new Display(0, 0, window.width, window.height, backgroundColor);
		peoteView.addDisplay(mainDisplay);

		var cameraBuffer = new Buffer<ViewElement>(1);
		var cameraProgram = new Program(cameraBuffer);
		
		cameraProgram.setTexture(frameBufferTexture, ViewElement.TEXTURE_base, false);

		cameraProgram.injectIntoFragmentShader("
		
				//vec4 frag is result of following:
				//texture2D(uTexture0, vec2(vTexCoord.x * 0.5 + floor(mod(vTexPack0, 2.0)) * 0.5, vTexCoord.y * 1.0 + floor(floor(vTexPack0)/2.0) * 1.0));

				vec4 compose(vec4 frag) {
					return frag;
				}
			"
			//, true                    // to insert uTime uniform automatically
			//, [customCameraUniforms]  // for later camera glsl postprocessing
		);
		
		#if (html5)
		// On webgl the default fragmentFloatPrecision is "medium" and shared uniforms
		// between vertex- and fragmentshader have to be the same precision!
		// cameraProgram.setFragmentFloatPrecision("high");
		#end

		// this is only need if not already defined inside ViewElement -> DEFAULT_COLOR_FORMULA
		// cameraProgram.setColorFormula('compose( ${ViewElement.TEXTURE_base} * tint )');

		cameraProgram.alphaEnabled = true;
		cameraProgram.discardAtAlpha(null);
		
		mainDisplay.addProgram(cameraProgram);

		var view = new ViewElement(0, 0, window.width, window.height, backgroundColor);
		view.slot = 0;
		
		// try this (^_^):
		// view.c = Color.RED;

		cameraBuffer.addElement(view);

		peoteView.renderToTexture(display, 0);

		ShapeElement.init(display, RECT, RECT);
		ShapeElement.init(display, CIRCLE, CIRCLE);
		ShapeElement.init(display, POLYGON, POLYGON);

		peoteView.addFramebufferDisplay(display);
		peoteView.start();

		var glyphStyle = new GlyphStyleTiled();
		glyphStyle.width = font.config.width;
		glyphStyle.height = font.config.height;
		fontProgram = new FontProgram<GlyphStyleTiled>(font, glyphStyle, false, true);
		display.addProgram(fontProgram);
		text = new Text(fontProgram);
	}

	public function halt() {
		peoteView.stop();
	}

	public function resize(width:Int, height:Int) {
		// does not change?
		peoteView.resize(width, height);
	}
	
	public function getPeoteTime():Float{
		return peoteView.time;
	}
}

class ViewElement implements Element {
	@posX @anim("PosSize", "pingpong") public var x:Int = 0;
	@posY @anim("PosSize", "pingpong") public var y:Int = 0;

	@sizeX @anim("PosSize", "pingpong") public var w:Int = 100;
	@sizeY @anim("PosSize", "pingpong") public var h:Int = 100;

	@zIndex public var z:Int = 0;

	@rotation @anim("Rotation", "constant") public var r:Float;

	@pivotX @set("Pivot") public var px:Int;
	@pivotY @set("Pivot") public var py:Int;
	
	
	// textures and colors to modify the colors of the pixels of a texture

	@texUnit("base") public var unitBase:Int = 0;  // 1 texture-unit called "base"
	@texSlot("base") public var slot:Int = 0;

	@color("tint") public var c:Color = 0xffff00ff;  // only need if you wanna use inside ColorFormula to use for modify the texture-colors
	
	var DEFAULT_FORMULA_VARS = [ "base"  => 0xff0000ff ]; // if no texture was set up for this unit, this will be the default color-value instead

	var DEFAULT_COLOR_FORMULA = "compose(base*tint)";

	
	
	public function new(positionX:Int = 0, positionY:Int = 0, width:Int = 64, height:Int = 64, c:Int = 0xFFFF00FF) {
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}
}
