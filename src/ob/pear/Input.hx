package ob.pear;

import echo.Body;
import echo.World;
import echo.data.Data.CollisionData;
import ob.pear.GamePiece.IGamePiece;
import ob.pear.GamePiece.ShapePiece;


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