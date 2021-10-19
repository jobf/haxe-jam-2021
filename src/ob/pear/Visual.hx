package ob.pear;

import echo.data.Types.ShapeType;
import lime.ui.Window;
import ob.pear.Sprites.ShapeElement;
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
	var isRendering:Bool;
	var window:Window;
	var backgroundColor:Color;

	public function new(window:Window, backgroundColor:Color = Color.GREY1) {
		this.window = window;
		this.backgroundColor = backgroundColor;
	}

	public function toggleRender() {
		isRendering = !isRendering;
	}

	public function start(enableRender:Bool = true) {
		peoteView = new PeoteView(window);
		display = new Display(-10000, -10000, window.width, window.height, 0x00000000);
		peoteView.addDisplay(display);
		frameBufferTexture = new Texture(window.width, window.height, 2, 4, true, 1, 1); // 2 Slots
		display.setFramebuffer(frameBufferTexture);
		mainDisplay = new Display(0, 0, window.width, window.height, backgroundColor);
		peoteView.addDisplay(mainDisplay);

		var cameraBuffer = new Buffer<ViewElement>(1);
		var cameraProgram = new Program(cameraBuffer);
		cameraProgram.setTexture(frameBufferTexture, "frameBuffer");

		cameraProgram.injectIntoFragmentShader("
				/*
					vec4 frag is result of following:
					texture2D(uTexture0, vec2(vTexCoord.x * 0.5 + floor(mod(vTexPack0, 2.0)) * 0.5, vTexCoord.y * 1.0 + floor(floor(vTexPack0)/2.0) * 1.0));
				*/
				uniform float uTime;

				vec4 compose(vec4 frag){
					return frag;
				}
			");

		cameraProgram.setColorFormula('compose(frameBuffer)');

		cameraProgram.alphaEnabled = true;
		cameraProgram.discardAtAlpha(null);
		mainDisplay.addProgram(cameraProgram);

		var view = new ViewElement(0, 0, window.width, window.height, backgroundColor);
		view.slot = 0;

		cameraBuffer.addElement(view);

		peoteView.renderToTexture(display, 0);

		ShapeElement.init(display, RECT, RECT);
		ShapeElement.init(display, CIRCLE, CIRCLE);
		ShapeElement.init(display, POLYGON, POLYGON);

		isRendering = enableRender;
		peoteView.start();
	}

	public function halt() {
		peoteView.removeDisplay(display);
		peoteView.stop();
	}

	public function render() {
		if (isRendering) {
			peoteView.renderToTexture(display, 0);
		}
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

	@texSlot public var slot:Int = 0;

	@color public var c:Color = 0xffff00ff;

	public function new(positionX:Int = 0, positionY:Int = 0, width:Int = 64, height:Int = 64, c:Int = 0xFFFF00FF) {
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.c = c;
	}
}
