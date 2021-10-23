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
import ob.pear.Pear;
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
		// vis.text.write("Hello from peote-world", pear.window.width * 0.5, pear.window.height * 0.5);
		// ShapeElement.init(vis.display, RECT, LORD, images[LORD]);
		// ShapeElement.init(vis.display, RECT, KENNEL, images[KENNEL]);
		// ShapeElement.init(vis.display, CIRCLE, DOG, images[DOG]);
		// ShapeElement.init(vis.display, RECT, CAVALRY, images[CAVALRY]);
		// ShapeElement.init(vis.display, RECT, lARCHER, images[lARCHER]);
		// ShapeElement.init(vis.display, RECT, lBUBBLER, images[lBUBBLER]);
		// ShapeElement.init(vis.display, RECT, lBUILDING, images[lBUILDING]);
		// ShapeElement.init(vis.display, RECT, pKNIGHT, images[pKNIGHT]);


		for(l in Barracks.Launchers.keyValueIterator()){
			ShapeElement.init(vis.display, l.value.shape, l.value.imageKey, images[l.value.imageKey]);
			ShapeElement.init(vis.display, l.value.projectileStats.shape, l.value.projectileStats.imageKey, images[l.value.projectileStats.imageKey]);
		}
		
		pear.input.onKeyDown.connect((sig) -> {
			// restart scene
			if (sig.key == BACKSPACE)
				pear.changeScene(new WaveSetupScene(pear, images));
		});

		// pear.input.onMouseDown.connect((sig) -> {
		// 	trace('mouse is clicked ${sig.x}, ${sig.y}');
		// });
		var worldCollideOptions:ListenerOptions = {
			// placeholder
		};

		phys.world.listen(worldCollideOptions);
		waveSetup = new WaveSetup(pear, group, clickHandler);
		waveSetup.readyButton.onClick = (b) -> {
			StartGameAlready();
		};

		// buttonsClickHandler = new ClickHandler(cursor, phys.world);
		// buttonsClickHandler.listenForClicks(waveSetup.buttons);
	}

	function StartGameAlready(){
		var waveConfig:WaveStats = {
			launchers: [],
			maximumActiveLaunchers: 100 // todo
		}
		var placedItems = group.filter((g) -> g.body.x < waveSetup.availableContainer.w);
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
		super(stats.imageKey, stats.color, bodyOptions.shape.width, bodyOptions.shape.height, body, isFlippedX);
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
		
		readyButton = new TextButton(pear, 0xacb475FF, readyButtonX, readyButtonY, buttonsize, "START");
		readyButton.body.data.gamePiece = readyButton;
		clickHandler.registerPiece(readyButton);
		
		pear.scene.vis.text.write("arrange units", availableContainer.x, readyButtonY);

		var numColumns = Std.int(availableContainer.w / buttonsize.x);
		var numRows = Std.int(availableContainer.h / buttonsize.y);
		var keys = [for (k in Barracks.Launchers.keys()) k];
		var i = 0;
		for (r in 0...numRows) {
			for (c in 0...numColumns) {
				var l = Barracks.Launchers[keys[i]];
				if (l == null) {
					// no more to display
					break;
				}
				var xOffset = availableContainer.x + (c * buttonsize.x) + buttonsize.x * 0.5;
				var yOffset = availableContainer.y + (r * buttonsize.x) + buttonsize.y * 0.5;
				var button = new LauncherButton(pear, l, xOffset, yOffset, buttonsize);
				trace('added button for ${l.tag}');
				button.body.data.gamePiece = button;
				buttons.push(button.body);
				group.push(button);
				clickHandler.registerPiece(button);
				// clickHandler.targets.push(readyButton.body);
				// clickHandler.group.push(readyButton);
				
				i++;
			}
		}
	}


}
