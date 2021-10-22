package ob.pear;

import echo.data.Options.WorldOptions;
import ob.pear.Delay.Tween;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Text.GlyphStyleTiled;
import peote.text.Font;
import peote.view.Color;

using ob.pear.Delay.TweenExtensions;

class Scene {
	public var vis(default, null):Visual;
	public var phys(default, null):Physical;
	public var tweens(default, null):Array<Tween<Dynamic>>;

	var pear:Pear;
	var canUpdate:Bool;
	var font:Font<GlyphStyleTiled>;

	public function new(pear:Pear, options:WorldOptions = null, backgroundColor:Color = Color.GREY1) {
		this.pear = pear;
		vis = new Visual(pear.window,  pear.font, backgroundColor);
		phys = new Physical(vis, options);
		tweens = [];
		canUpdate = false;
	}

	/** initialise the scene - overide this and do set up here, not in new**/
	public function init() {
		vis.start();
		phys.start();
		canUpdate = true;
	}

	public function update(deltaTimeMs:Float):Void {
		if(canUpdate){
			phys.update(deltaTimeMs);
			for (t in tweens) {
				t.tween(deltaTimeMs);
			}
		}
	}

	/** clean up the scene  **/
	public function halt() {
		canUpdate = false;
		phys.halt();
		vis.halt();
	}
}

class TestScene extends Scene {
	var cursor:ShapePiece;

	override public function new(pear:Pear) {
		super(pear, {
			width: pear.window.width,
			height: pear.window.height,
			iterations: 1,
			history: 0
		});

		init();

		var distribution = 10;
		var tileSizeW = Math.round(pear.window.width / distribution);
		var tileSizeH = Math.round(pear.window.height / distribution);
		var numColumns = Math.round(pear.window.width / tileSizeW);
		var numRows = Math.round(pear.window.width / tileSizeH);
		var colors = [0x4488eea0, 0xee4488a0];
		var stripeKey = 0;
		for (r in 0...numRows + 1) {
			var colorIndex = (r % 2 == 0 ? 0 : 1);
			var stripe = phys.initShape(stripeKey, colors[colorIndex], {
				x: 0 + (pear.window.width * 0.5),
				y: r * tileSizeH,
				shape: {
					type: RECT,
					width: pear.window.width,
					height: tileSizeH,
				}
			}, false);
		}
		for (c in 0...numColumns + 1) {
			var colorIndex = (c % 2 == 0 ? 0 : 1);
			var color = colors[colorIndex];
			var stripe = phys.initShape(stripeKey, color, {
				x: c * tileSizeW,
				y: 0 + (pear.window.height * 0.5),
				shape: {
					type: RECT,
					width: tileSizeW,
					height: pear.window.height
				}
			}, false);
		}

		cursor = phys.initShape(stripeKey, 0xffffffa0, {
			x: pear.window.width * 0.5,
			y: pear.window.height * 0.5,
			rotational_velocity: 300,
			shape: {
				type: RECT,
				radius: 32,
				width: 64,
				height: 64
			}
		}, false);

		pear.followMouse(cursor, (piece, pos) -> {
			piece.body.velocity.set(pos.x - piece.body.x, pos.y - piece.body.y);
			piece.body.velocity *= 0.9;
		});
	}
}
