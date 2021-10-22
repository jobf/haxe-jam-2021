package scenes;

import core.Launcher.LauncherConfig;
import core.Launcher.LauncherStats;
import core.Wave;
import data.Barracks;
import data.Global.ElementKey;
import data.Global;
import echo.Body;
import echo.data.Options.BodyOptions;
import echo.data.Options.ListenerOptions;
import lime.graphics.Image;
import lime.math.Vector2;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Input.ClickHandler;
import ob.pear.Pear;
import ob.pear.Sprites.ShapeElement;
import peote.view.Color;

using ob.pear.Util.ArrayExtensions;

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

		pear.input.onMouseDown.connect((sig) -> {
			trace('mouse is clicked ${sig.x}, ${sig.y}');
		});
		var worldCollideOptions:ListenerOptions = {
			// placeholder
		};

		phys.world.listen(worldCollideOptions);
		waveSetup = new WaveSetup(pear, group);
		waveSetup.readyButton.onClick = (b) -> {
			StartGameAlready();
		};

		clickHandler = new ClickHandler(waveSetup.buttons, cursor, phys.world);

		pear.input.onMouseDown.connect((sig) -> clickHandler.onMouseDown());
	}

	function StartGameAlready(){
		var waveConfig:WaveStats = {
			launchers: [],
			maximumActiveLaunchers: 100 // todo
		}
		var placedItems = group.filter((g) -> g.body.x < waveSetup.availableContainer.x);
		for (item in placedItems) {
			var button:LauncherButton = cast item;
			button.launcherStats.position = new Vector2(item.body.x, item.body.y);
			waveConfig.launchers.push(button.launcherStats);
		}
		Global.currentWaveSetup = waveConfig;

		pear.changeScene(new ScorchedEarth(pear, images));
	}

	override function update(deltaMs:Float) {
		super.update(deltaMs);
		group.all((item) -> item.update(deltaMs));
	}

	var clickHandler:ClickHandler;

	var waveSetup:WaveSetup;
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

typedef Box = {x:Float, y:Float, w:Float, h:Float};

class WaveSetup {
	var stats:WaveStats;

	public var buttons(default, null):Array<Body> = [];
	public var availableContainer(default, null):Box;

	public function new(pear:Pear, group:Array<ShapePiece>) {
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
		trace('availableContainer $availableContainer ');
		var buttonsize = new Vector2(width / 4, height / 5);

		var readyButtonX = pear.window.width - buttonsize.x - margin + buttonsize.x * 0.5;
		var readyButtonY = pear.window.height - buttonsize.y - margin + buttonsize.y * 0.5;
		readyButton = new TextButton(pear, 0x18601add, readyButtonX, readyButtonY, buttonsize);
		readyButton.body.data.gamePiece = readyButton;
		buttons.push(readyButton.body);

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
				i++;
			}
		}
	}

	public var readyButton(default, null):TextButton;
}

class TextButton extends ShapePiece {
	var pear:Pear;

	public var onClick:TextButton->Void;

	public function new(pear_:Pear, color:Color, x:Float, y:Float, size:Vector2) {
		pear = pear_;
		var isFlippedX = false;
		// is the really needed?
		// // position is center of entity so adjust to fit.
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
		super(RECT, color, bodyOptions.shape.width, bodyOptions.shape.height, body, isFlippedX);
	}

	override function click() {
		super.click();
		if (onClick != null) {
			onClick(this);
		}
	}
}
