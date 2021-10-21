package scenes;

import core.Data.Barracks;
import core.Data.ElementKey;
import core.Wave;
import echo.data.Options.ListenerOptions;
import lime.graphics.Image;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Pear;
import ob.pear.Sprites.ShapeElement;

using ob.pear.Util.ArrayExtensions;
class ArtTestScene extends BaseScene{
	var group:Array<ShapePiece> = [];
    override public function new(pear:Pear, images:Map<ElementKey, Image>) {
		super(pear, {
			width: pear.window.width,
			height: pear.window.height,
			gravity_y: 100,
			iterations: 5,
			history: 1
		}, images);
	}

	override function init() {
		super.init();
        
        // ShapeElement.init(vis.display, RECT, LORD, images[LORD]);
		ShapeElement.init(vis.display, RECT, KENNEL, images[KENNEL]);
		ShapeElement.init(vis.display, CIRCLE, DOG, images[DOG]);
		ShapeElement.init(vis.display, RECT, CAVALRY, images[CAVALRY]);
        
		pear.input.onKeyDown.connect((sig)->{
			// restart scene 
			if(sig.key == BACKSPACE) pear.changeScene(new ArtTestScene(pear, images));
		});

		pear.input.onMouseDown.connect((sig) -> {
			trace('mouse is clicked ${sig.x}, ${sig.y}');
		});
		var worldCollideOptions:ListenerOptions = {
			// placeholder
		};

		phys.world.listen(worldCollideOptions);
		// add floor at base of screen
		var platformHeight = 10;
		var block = phys.initShape(RECT, 0xffff44FF,{
			mass: 0,
			elasticity: 0.3,
			x: pear.window.width * 0.5,
			y: pear.window.height - platformHeight,
			shape: {
				type: RECT,
				width: pear.window.width,
				height: platformHeight,
			}
		});
		group.push(block);


        var stats:WaveStats = {
            launchers: [
				{
					launcher: Barracks.Launchers[KENNEL],
					projectile: Barracks.Projectiles[DOG]
				},
				{
					launcher: Barracks.Launchers[CAVALRY],
					projectile: Barracks.Projectiles[DOG]
				}
			],
            maximumActiveLaunchers: 999
        };
        var isFlippedX = false;
        var bodiesA = [];
        var bodiesB = [];

        wave = new Wave(pear, stats, bodiesA, bodiesB, "BOT", isFlippedX);
	}
    
	override function update(deltaMs:Float) {
		super.update(deltaMs);
        wave.update(deltaMs);
		group.all((item)->item.update(deltaMs));
    }
	var wave:Wave;
}