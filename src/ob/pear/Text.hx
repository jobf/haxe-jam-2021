package ob.pear;

import data.Global.Layers;
import peote.text.Font;
import peote.text.FontProgram;
import peote.text.Line;
import peote.view.Color;
import peote.view.Display;

class Text {
	public function new(fontProgram:FontProgram<GlyphStyleTiled>) {
		this.fontProgram = fontProgram;
	}

	var font:Font<GlyphStyleTiled>;

	var display:Display;

	var fontProgram:FontProgram<GlyphStyleTiled>;

	public function write(chars:String, x:Float, y:Float):Line<GlyphStyleTiled>{
		var line = fontProgram.createLine(chars, x, y);
		var offsetX = x - line.get_textSize() * 0.5;
		var offsetY = y - line.get_height() * 0.5;
		fontProgram.lineSetPosition(line, offsetX, offsetY);
		fontProgram.updateLine(line);
		return line;
	}
	
	public function move(line, x:Float, y:Float){
		fontProgram.lineSetPosition(line, x, y);
	}
}


class GlyphStyleTiled {
	public var color:Color = 0xffffffFF;
	public var width:Float = 16;
	public var height:Float = 16;
	public var tilt:Float = 0.0;
	// reduce gaps between chars? 
	// todo - it doesn't
	// @global
	public var letterSpace:Float = -15.0; 
	public var zIndex:Int = Layers.TEXT;
	public function new() {}

}
