package scenes;

import core.Data.Barracks;
import core.Data.ElementKey;
import core.Data.Projectiles;
import core.Wave;
import echo.Body;
import echo.World;
import echo.data.Data.CollisionData;
import echo.data.Options.ListenerOptions;
import lime.graphics.Image;
import ob.pear.GamePiece.IGamePiece;
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
				// {
				// 	launcher: Barracks.Launchers[KENNEL],
				// 	projectile: Projectiles.DOG_HURL
				// },
				{
					launcher: Barracks.Launchers[launcherKNIGHTHOUSE],
					projectile: Projectiles.KNIGHT
				},
				{
					launcher: Barracks.Launchers[launcherBUBBLER],
					projectile: Projectiles.BUBBLE
				},
				{
					launcher: Barracks.Launchers[launcherARCHERS],
					projectile: Projectiles.ARROW
				}
			],
            maximumActiveLaunchers: 999
        };
        var isFlippedX = false;
        bodiesA = [];
        var bodiesB = [];

        wave = new Wave(pear, stats, bodiesA, bodiesB, "BOT", isFlippedX);

		clickHandler = new ClickHandler(bodiesA, cursor, phys.world);

		pear.input.onMouseDown.connect((sig) -> clickHandler.onMouseDown());
	}
    
	override function update(deltaMs:Float) {
		super.update(deltaMs);
        wave.update(deltaMs);
		group.all((item)->item.update(deltaMs));
    }
	var wave:Wave;

	var bodiesA:Array<Body>;
	var clickHandler:ClickHandler;
}

class ClickHandler{
	public function new(mouseTargets:Array<Body>, cursor:ShapePiece, world:World) {
		targets = mouseTargets;
		this.cursor = cursor;
		this.world = world;
		world.listen(mouseTargets, cursor.body, {
			// separate: separate,
			enter: onItemOver,
			// stay: stay,
			exit: onItemLeave,
			// condition: condition,
			// percent_correction: percent_correction,
			// correction_threshold: correction_threshold
		});
	}

	public function onMouseDown(){
		// var itemUnderMouse = itemsUnderMouse.first((item)-> item.body.id)
		// if(itemUnderMouse != null){
		// 	itemUnderMouse.click();
		// }
		for(item in itemsUnderMouse){
			item.click();
		}
	}

	// todo check that the Body arguments are always in this order?
	function onItemOver(cursor:Body, item:Body,  collisions:Array<CollisionData>){
		trace('mouseover');
		var piece:IGamePiece = item.data.gamePiece;
		if(piece != null){
			if(!itemsUnderMouse.contains(piece)){
				trace('mouseover remembered');
				itemsUnderMouse.push(piece);
			}
		}
	}

	// todo check that the Body arguments are always in this order?
	function onItemLeave(cursor:Body, item:Body){
		trace('mouseleave');
		var piece:IGamePiece = item.data.gamePiece;
		
		if(piece != null && itemsUnderMouse.length > 0){
			if(itemsUnderMouse.contains(piece)){
				itemsUnderMouse.remove(piece);
				trace('mouseleave discard');
			}
		}
	}


	var targets:Array<Body>;
	var cursor:ShapePiece;
	var world:World;
	var itemsUnderMouse:Array<IGamePiece> = [];
	
}