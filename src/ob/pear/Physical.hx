package ob.pear;

import echo.Body;
import echo.Echo;
import echo.World;
import echo.data.Options.BodyOptions;
import echo.data.Options.ListenerOptions;
import echo.data.Options.WorldOptions;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.GamePiece.MultiShapePiece;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Sprites.ShapeElement;
import peote.view.Color;

class Physical {
	var v:Visual;

	public var world(default, null):World;

	var pieces(default, null):Array<IGamePiece> = [];

	var worldOptions:WorldOptions;
	var canUpdate:Bool;

	public function new(vis:Visual, echoOptions:WorldOptions = null) {
		v = vis;
		worldOptions = echoOptions != null ? echoOptions : {
			width: 400,
			height: 300,
			gravity_y: 100,
			iterations: 2
		};
		canUpdate = false;
	}

	public function isOutOfBounds(b:Body) {
		var bounds = b.bounds();
		var check = bounds.min_y > world.height || bounds.max_x < 0 || bounds.min_x > world.width;
		bounds.put();
		return check;
	}

	public function start() {
		canUpdate = true;
		world = Echo.start(worldOptions);
	}

	public function halt() {
		canUpdate = false;
		world.dispose();
	}

	public function update(deltaMs:Float) {
		if(canUpdate){
			world.step(deltaMs);
			for (p in pieces) {
				p.update(deltaMs);
			}
		}
	}

	public function initMultiShape(elementKey:Int, colour:Color, options:BodyOptions):MultiShapePiece {
		if (options.shapes.length < 1) {
			throw "not a multi shape";
		}
		var elements:Array<ShapeElement> = [];
		for (s in options.shapes) {
			var offsetPosX = options.x += s.offset_x;
			var offsetPosY = options.y += s.offset_y;
			var fallbackH = s.height == null ? s.width : s.height;
			var isFlippedX = false;
			var e = new ShapeElement(elementKey, offsetPosX, offsetPosY, s.width, fallbackH, colour, s.type, isFlippedX);
			// todo check how this works with px_offset py_offset
			// e.pivotX += s.offset_x;
			// e.pivotY += s.offset_y;
			elements.push(e);
		}
		var body = world.add(new Body(options));
		var piece = new MultiShapePiece(body, elements, ShapeElement.buffers[body.shape.type]);
		pieces.push(piece);
		return piece;
	}

	public function initShape(elementKey:Int, colour:Color, phys:BodyOptions, visualSize:{vWidth:Float, vHeight:Float} = null,
			isFlippedX:Bool = false):ShapePiece {
		visualSize = visualSize != null ? visualSize : {vWidth: phys.shape.width, vHeight: phys.shape.height};
		var piece = new ShapePiece(elementKey, colour, visualSize.vWidth, visualSize.vHeight, ShapeElement.buffers[elementKey], world.make(phys),
			phys.shape.sides, isFlippedX);
		pieces.push(piece);
		return piece;
	}

	public function setupCollision(a:Body, b:Body, options:ListenerOptions) {
		world.listen(a, b, options);
	}
}
