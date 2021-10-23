package ob.pear;

import echo.Body;
import echo.World;
import echo.data.Data.CollisionData;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.GamePiece.ShapePiece;


class ClickHandler{
	public var group(default, null):Array<ShapePiece> = [];
	public var targets(default, null):Array<Body> = [];
	public function new(cursor:ShapePiece, world:World) {
		this.cursor = cursor;
		this.world = world;
		world.listen(targets, cursor.body, {
			// separate: separate,
			enter: onItemOver,
			// stay: stay,
			exit: onItemLeave,
			// condition: condition,
			// percent_correction: percent_correction,
			// correction_threshold: correction_threshold
		});
	}

	public function update(deltaMs:Float) {
		group.all((item)->item.update(deltaMs));
    }

	public function listenForClicks(extraTargets:Array<Body>){
		world.listen(extraTargets, cursor.body, {
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
		// trace('mouseover');
		var piece:ShapePiece = item.data.gamePiece;
		if(piece != null){
			if(!itemsUnderMouse.contains(piece)){
				// trace('mouseover remembered');
				itemsUnderMouse.push(piece);
				piece.setColor(Global.onHoverColor);
			}
		}
	}

	// todo check that the Body arguments are always in this order?
	function onItemLeave(cursor:Body, item:Body){
		// trace('mouseleave');
		var piece:ShapePiece = item.data.gamePiece;
		
		if(piece != null && itemsUnderMouse.length > 0){
			if(itemsUnderMouse.contains(piece)){
				itemsUnderMouse.remove(piece);
				piece.setColor(Global.colors[A]);
				// trace('mouseleave discard');
			}
		}
	}
	
	public function registerPiece(piece:ShapePiece){
		targets.push(piece.body);
		group.push(piece);
	}
	var cursor:ShapePiece;
	var world:World;
	var itemsUnderMouse:Array<IGamePiece> = [];
	
}