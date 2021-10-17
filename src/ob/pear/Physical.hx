package ob.pear;

import ob.pear.GamePiece.MultiShapePiece;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.Sprites.ShapeElement;
import echo.Body;
import ob.pear.GamePiece.ShapePiece;
import echo.data.Options.ListenerOptions;
import echo.data.Options.BodyOptions;
import echo.data.Options.WorldOptions;
import peote.view.Color;
import echo.World;
import echo.Echo;

class Physical {
	var v:Visual;
	public var world(default, null):World;
	var pieces(default, null):Array<IGamePiece> = [];

	var worldOptions:WorldOptions;
	public var totalMsElapsed(default, null):Float;
	
	public function new(vis:Visual, echoOptions:WorldOptions = null) {
		v = vis;
		worldOptions = echoOptions != null ? echoOptions : {
			width: 400, 
			height: 300, 
			gravity_y: 100,
			iterations: 2
		};
	}
	
	public function isOutOfBounds(b:Body) {
		var bounds = b.bounds();
		var check = bounds.min_y > world.height || bounds.max_x < 0 || bounds.min_x > world.width;
		bounds.put();
		return check;
	  }

	public function start() {
		world = Echo.start(worldOptions);
	}

	public function update(deltaTime:Int):Float {
		var deltaMs = deltaTime / 1000;
		totalMsElapsed += deltaMs;
		world.step(deltaMs);
		for(p in pieces){
			p.update(deltaMs);
		}
		return deltaMs;
	}

	public function initMultiShape(colour:Color, options:BodyOptions):MultiShapePiece {
		if(options.shapes.length < 1){
			throw "not a multi shape";
		}
		var elements:Array<ShapeElement> = [];
		for(s in options.shapes){
			var offsetPosX = options.x += s.offset_x;
			var offsetPosY = options.y += s.offset_y;
			var fallbackH = s.height == null ? s.width : s.height;
			var e = new ShapeElement(offsetPosX, offsetPosY, s.width, fallbackH, colour, s.type);
			e.pivotX += s.offset_x;
			e.pivotY += s.offset_y;
			elements.push(e);
		}
		var body = world.add(new Body(options));
		var piece = new MultiShapePiece(body, elements, ShapeElement.buffers[body.shape.type]);
		pieces.push(piece);
		return piece;
	}

	public function initShape(colour:Color, phys:BodyOptions):ShapePiece {
		var piece = new ShapePiece(colour, phys.shape.width, phys.shape.height, ShapeElement.buffers[phys.shape.type], world.make(phys), phys.shape.sides);
		pieces.push(piece);
		return piece;
	}

	public function setupCollision(a:Body, b:Body, options:ListenerOptions) {
		world.listen(a, b, options);
	}

}
