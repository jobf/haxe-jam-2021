package core;

import echo.Body;
import ob.pear.GamePiece.ShapePiece;
import ob.pear.Sprites.ShapeElement;
import peote.view.Buffer;
import peote.view.Color;

typedef Vitals = { player:PlayerId, pieceType:PieceType};
class BodyExtensions{
    public static function getVitals(body:Body):Vitals {
        return body.data.vitals;
    }
}

@:enum abstract PieceType(Int) from Int to Int {
	var PROJECTILE;
	var LAUNCHER;
	var BUTTON;
	var CURSOR;
}

class OverlordPiece extends ShapePiece{
    var vitals:Vitals;
    public var isExpired:Bool;
    public var isExpiring:Bool;
    public function new(elementKey:Int, vitals_:Vitals, color:Color, visibleWidth:Float, visibleHeight:Float, ?buffer:Buffer<ShapeElement>, body:Body, isFlippedX:Bool) {
        super(elementKey, color, visibleWidth, visibleHeight, null, body, isFlippedX);
        vitals = vitals_;
        body.data.vitals = vitals_;
        isExpired = false;
        isExpiring = false;
    }
    public function expire() {
		if(!isExpiring && !isExpired){
			isExpiring = true;
		}
	}
}