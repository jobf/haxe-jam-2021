package scenes;

import core.Data.Barracks;
import core.Data.ElementKey;
import core.Data.Projectiles;
import core.Launcher.TargetGroup;
import core.Wave;
import echo.Body;
import echo.World;
import echo.data.Data.CollisionData;
import echo.data.Options.ListenerOptions;
import lime.graphics.Image;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Input.ClickHandler;
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
		ShapeElement.init(vis.display, RECT, launcherARCHERS, images[launcherARCHERS]);
		ShapeElement.init(vis.display, RECT, launcherBUBBLER, images[launcherBUBBLER]);
		ShapeElement.init(vis.display, RECT, launcherKNIGHTHOUSE, images[launcherKNIGHTHOUSE]);
		ShapeElement.init(vis.display, RECT, projectileKNIGHT, images[projectileKNIGHT]);
        
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
				Barracks.Launchers[launcherKNIGHTHOUSE],
				Barracks.Launchers[launcherBUBBLER],
				Barracks.Launchers[launcherARCHERS],
			],
            maximumActiveLaunchers: 999
        };
		var statsB:WaveStats = {
            launchers: [
				Barracks.Launchers[launcherKNIGHTHOUSE],
				Barracks.Launchers[launcherBUBBLER],
				Barracks.Launchers[launcherARCHERS],
			],
            maximumActiveLaunchers: 999

		};

		// for(l in statsB.launchers){
		// 	l.position
		// }
        var isFlippedX = true;
        var isNotFlippedX = false;
        
        var bodiesA:TargetGroup = {launchers: [], projectiles: []};
        var bodiesB:TargetGroup = {launchers: [], projectiles: []};

        waveA = new Wave(0, pear, stats, bodiesA, bodiesB, "BOT A", isNotFlippedX);
        waveB = new Wave(1, pear, statsB, bodiesB, bodiesA, "BOT B", isFlippedX);

		clickHandler = new ClickHandler(bodiesA.launchers, cursor, phys.world);

		pear.input.onMouseDown.connect((sig) -> clickHandler.onMouseDown());
	}
    
	override function update(deltaMs:Float) {
		super.update(deltaMs);
        waveA.update(deltaMs);
        waveB.update(deltaMs);
		group.all((item)->item.update(deltaMs));
    }
	var waveA:Wave;
	var waveB:Wave;

	var bodiesA:Array<Body>;
	var clickHandler:ClickHandler;
}
