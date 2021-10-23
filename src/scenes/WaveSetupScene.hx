package scenes;

import core.Launcher.LauncherStats;
import core.Wave;
import data.Barracks;
import echo.Body;
import echo.data.Options;
import lime.graphics.Image;
import lime.math.Vector2;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Input.ClickHandler;
import ob.pear.Sprites.ShapeElement;
import ob.pear.UI;


class WaveSetupScene extends BaseScene {
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

		// var textX = pear.window.width * 0.5;
		// var textY = 0;
		// var text = "";
		// vis.text.write(text, textX, textY);

		var worldCollideOptions:ListenerOptions = {
			// placeholder
		};

		phys.world.listen(worldCollideOptions);
		waveSetup = new WaveSetup(pear, group, clickHandler);
		waveSetup.readyButton.onClick = (b) -> {
			StartGameAlready();
		};
	}

	function StartGameAlready(){
		var waveConfig:WaveStats = {
			launchers: [],
			maximumActiveLaunchers: 100 // todo
		}
		var placedItems = group.filter((g) -> g.body.x < waveSetup.availableContainer.w);
		
		if(placedItems.length <= 0){
			return;
		}
		
		for (item in placedItems) {
			var button:LauncherButton = cast item;
			// button.launcherStats.position = new Vector2(item.body.x, item.body.y);
			var config = {pos: new Vector2(item.body.x, item.body.y), stats:button.launcherStats};
			#if debug
			trace('add ${config.launcherStats.tag} to player wave at ${config.pos.x} ${config.pos.y}');
			#end
			waveConfig.launchers.push(config);
		}
		
		Global.currentWaveSetup = waveConfig;

		pear.changeScene(new ScorchedEarth(pear, images));
	}

	override function update(deltaMs:Float) {
		super.update(deltaMs);
		group.all((item) -> item.update(deltaMs));
		// buttonsClickHandler.update(deltaMs);
	}

	var waveSetup:WaveSetup;

	// var buttonsClickHandler:ClickHandler;
}

class LauncherButton extends ShapePiece {
	var pear:Pear;

	public var launcherStats(default, null):LauncherStats;

	public function new(pear_:Pear, stats:LauncherStats, x:Float, y:Float, size:Vector2) {
		launcherStats = stats;
		pear = pear_;
		var isFlippedX = false;
		// todo .. this?
		// position is center of entity so adjust to fit.
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
		super(stats.imageKey, Global.colors[PlayerId.A], bodyOptions.shape.width, bodyOptions.shape.height, body, isFlippedX);
	}

	var mouseFollow:Vector2->Void;

	override function click() {
		super.click();
		if (mouseFollow == null) {
			mouseFollow = pear.followMouse(this);
			
		} else {
			pear.input.onMouseMove.disconnect(mouseFollow);
			mouseFollow = null;
		}
	}
}


class WaveSetup {
	var stats:WaveStats;

	public var buttons(default, null):Array<Body> = [];
	public var availableContainer(default, null):Box;
	public var readyButton(default, null):TextButton;
	var clickHandler:ClickHandler;

	public function new(pear:Pear, group:Array<ShapePiece>, clickHandler:ClickHandler) {
		this.clickHandler = clickHandler;
		stats = {
			launchers: [],
			maximumActiveLaunchers: 10
		}

		var margin = pear.window.height * 0.015;
		var width = (pear.window.width * 0.5) - (margin * 2);
		var height = pear.window.height - (margin * 2);

		var place = new ShapeElement(RECT, margin + (width * 0.5), margin + (height * 0.5), width, height, 0x22222244, RECT,  false);
		place.z = Layers.IMAGES;
		ShapeElement.buffers[RECT].updateElement(place);
		
		availableContainer = {
			x: width + margin,
			y: margin,
			w: width,
			h: height
		};
		// trace('availableContainer $availableContainer ');

		var buttonsize = new Vector2(width / 4, height / 5);
		var readyButtonX = pear.window.width - buttonsize.x - margin + buttonsize.x * 0.5;
		var readyButtonY = pear.window.height - buttonsize.y - margin + buttonsize.y * 0.5;
		
		readyButton = new TextButton(pear, Global.colors[A], readyButtonX, readyButtonY, buttonsize, "START");
		readyButton.body.data.gamePiece = readyButton;
		clickHandler.registerPiece(readyButton);
		
		pear.scene.vis.text.write("arrange units (click to stick/drop)", availableContainer.x, readyButtonY, Global.textBgColor);

		var numColumns = Std.int(availableContainer.w / buttonsize.x);
		var numRows = Std.int(availableContainer.h / buttonsize.y);
		
		var i = 0;
		for (r in 0...numRows) {
			for (c in 0...numColumns) {
				var stats = Global.availableLaunchers[i];
				if (stats == null) {
					// no more to display
					break;
				}
				
				var xOffset = availableContainer.x + (c * buttonsize.x) + buttonsize.x * 0.5;
				var yOffset = availableContainer.y + (r * buttonsize.x) + buttonsize.y * 0.5;
				var button = new LauncherButton(pear, stats, xOffset, yOffset, buttonsize);
				button.body.data.gamePiece = button;
				buttons.push(button.body);
				group.push(button);
				clickHandler.registerPiece(button);
				
				#if debug
				trace('added button for ${stats.tag}');
				#end
				
				i++;
			}
		}
	}


}
