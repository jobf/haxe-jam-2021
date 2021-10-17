package ob.pear;

import peote.view.Element;
import peote.view.Color;
import ob.pear.Sprites.ShapeElement;
import peote.view.Buffer;
import echo.Body;

interface IGamePiece{
	public var cloth(default, null):Element;
    public var body(default, null):Body;
	public function update(deltaTime:Float):Void;
}

class ShapePiece implements IGamePiece{
	public var body(default, null):Body;
	public var cloth(default, null):ShapeElement;
	var buffer:Buffer<ShapeElement>;
	var color:Color;
	public function new(color:Color, visibleWidth:Float, visibleHeight:Float, buffer:Buffer<ShapeElement>, body:Body, numShapeSides:Int=3){
		this.buffer = buffer;				
		cloth = new ShapeElement(body.x, body.y, visibleWidth, visibleHeight, color, body.shape.type, numShapeSides);
		this.body = body;
		this.body.on_move = onMove;
		this.body.on_rotate = onRotate;
		this.color = color;
	}

	function onRotate(rotation:Float){
		cloth.rotation = rotation;
		buffer.updateElement(cloth);
	}

	function onMove(bodyX:Float, bodyY:Float){
		cloth.setPosition(bodyX, bodyY);
		buffer.updateElement(cloth);
		
	}

	public function update(deltaTime:Float){
		if(body.collided){
			cloth.color.alpha = 0xcc;
		}
		else{
			cloth.color.alpha = color.alpha;
		}
	}

}

class MultiShapePiece implements IGamePiece{
	public var body(default, null):Body;
	public var cloth(default, null):ShapeElement;
	var elements:Array<ShapeElement>;
	var buffer:Buffer<ShapeElement>;
	var color:Color;
	public function new(body:Body, elements:Array<ShapeElement>, buffer:Buffer<ShapeElement>){
		this.buffer = buffer;				
		cloth = elements[0];
		this.body = body;
		this.body.on_move = onMove;
		this.body.on_rotate = onRotate;
		this.color = this.cloth.color;
		this.elements = elements;
	}

	function onRotate(rotation:Float){
		// trace('rotate');
		for(e in elements){
			e.rotation = rotation;
			buffer.updateElement(e);
		}
	}

	function onMove(bodyX:Float, bodyY:Float){
		for(e in elements){
			e.setPosition(bodyX, bodyY);
			buffer.updateElement(e);
		}
		
	}

	public function update(deltaTime:Float){
		if(body.collided){
			cloth.color.alpha = 0xcc;
		}
		else{
			cloth.color.alpha = color.alpha;
		}
	}

}

