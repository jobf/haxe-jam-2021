package ob.pear;

import ob.pear.GamePiece.ShapePiece;
import peote.view.Color;
import echo.data.Options.WorldOptions;

class Scene {
	public var vis(default, null):Visual;
	public var phys(default, null):Physical;

	public function new(pear:Pear, options:WorldOptions = null, backgroundColor:Color = Color.GREY1) {
		vis = new Visual(pear.window);
		phys = new Physical(vis, options);
		init();
	}

	public function init() {
		vis.start();
		phys.start();
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


        var distribution = 10;
        var tileSizeW = Math.round(pear.window.width / distribution);
        var tileSizeH = Math.round(pear.window.height / distribution);
        var numColumns = Math.round(pear.window.width / tileSizeW);
        var numRows = Math.round(pear.window.width / tileSizeH);
        var colors = [0x4488eea0, 0xee4488a0];
        for(r in 0...numRows+1){
            var colorIndex = (r % 2 == 0 ? 0 : 1);
            var stripe = phys.initShape(colors[colorIndex], {
                x: 0 + (pear.window.width * 0.5),
                y: r * tileSizeH,
                shape:{
                    type: RECT,
                    width: pear.window.width,
                    height: tileSizeH,}
            });
        }
        for(c in 0...numColumns+1){
            var colorIndex = (c % 2 == 0 ? 0 : 1);
            var color =colors[colorIndex];
            var stripe = phys.initShape(color, {
                x: c * tileSizeW,
                y: 0 + (pear.window.height * 0.5),
                shape:{
                    type: RECT,
                    width: tileSizeW,
                    height: pear.window.height
                }
            });
        }

        cursor = phys.initShape(0xffffffa0,{
			x: pear.window.width * 0.5,
			y: pear.window.height * 0.5,
            rotational_velocity: 300,
			shape: {
			  type: RECT,
			  radius: 32,
			  width: 64,
			  height: 64
			}
		  }
		);
        
        pear.followMouse(cursor, (piece, pos)->{
            piece.body.velocity.set(pos.x - piece.body.x, pos.y - piece.body.y);
            piece.body.velocity *= 0.9;
        });
	}
}
