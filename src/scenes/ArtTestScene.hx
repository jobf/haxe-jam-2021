package scenes;

import core.Launcher.TargetGroup;
import core.Wave;
import data.Barracks;
import data.Global.ElementKey;
import data.Projectiles;
import echo.Body;
import echo.World;
import echo.data.Data.CollisionData;
import echo.data.Options.ListenerOptions;
import lime.graphics.Image;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Input.ClickHandler;
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
		
		for(l in Barracks.Launchers.keyValueIterator()){
			ShapeElement.init(vis.display, l.value.shape, l.value.imageKey, images[l.value.imageKey]);
			ShapeElement.init(vis.display, l.value.projectileStats.shape, l.value.projectileStats.imageKey, images[l.value.projectileStats.imageKey]);
		}
		
        
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
		}, false);
		group.push(block);


        var stats:WaveStats = {
            launchers: [
				{pos: null, stats: Barracks.Launchers[lBUILDING]},
				{pos: null, stats: Barracks.Launchers[lBUBBLER]},
				{pos: null, stats: Barracks.Launchers[lARCHER]},
				{pos: null, stats: Barracks.Launchers[lDOGGER]},
				{pos: null, stats: Barracks.Launchers[lDOGGER]},
				{pos: null, stats: Barracks.Launchers[lDOGGER]},
				{pos: null, stats: Barracks.Launchers[lFOWLER]},
			],
            maximumActiveLaunchers: 999
        };
		var statsB:WaveStats = {
            launchers: [
				
				{pos: null, stats: Barracks.Launchers[lBUILDING]},
				{pos: null, stats: Barracks.Launchers[lBUBBLER]},
				{pos: null, stats: Barracks.Launchers[lARCHER]},
				{pos: null, stats: Barracks.Launchers[lDOGGER]},
				{pos: null, stats: Barracks.Launchers[lFOWLER]},
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

        waveA = new Wave(PlayerId.A, pear, stats, bodiesA, bodiesB, "BOT A", isNotFlippedX);
        waveB = new Wave(PlayerId.B, pear, statsB, bodiesB, bodiesA, "BOT B", isFlippedX);

		launchersClickHandler = new ClickHandler(cursor, phys.world);
		launchersClickHandler.listenForClicks(bodiesA.launchers);

		pear.input.onMouseDown.connect((sig) -> clickHandler.onMouseDown());
	}
    
	override function update(deltaMs:Float) {
		super.update(deltaMs);
        waveA.update(deltaMs);
        waveB.update(deltaMs);
		group.all((item)->item.update(deltaMs));
		launchersClickHandler.update(deltaMs);
    }
	var waveA:Wave;
	var waveB:Wave;

	var bodiesA:Array<Body>;

	var launchersClickHandler:ClickHandler;
}
