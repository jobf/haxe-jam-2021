package ob.pear;

import peote.text.Font;
import peote.text.FontProgram;
import peote.view.Color;
import peote.view.Display;

class Text {
	public function new(display_:Display) {
		display = display_;
		// todo - preload this
		font = new Font<GlyphStyleTiled>('assets/fonts/peote.json');
		font.load((font) -> {
			var glyphStyle = new GlyphStyleTiled();
			glyphStyle.width = font.config.width;
			glyphStyle.height = font.config.height;
			fontProgram = new FontProgram<GlyphStyleTiled>(font, glyphStyle);

			display.addProgram(fontProgram);
		});
	}

	var font:Font<GlyphStyleTiled>;

	var display:Display;

	var fontProgram:FontProgram<GlyphStyleTiled>;

	public function write(chars:String, x:Float, y:Float){
		fontProgram.createLine(chars, x, y);
	}
}

class GlyphStyleTiled {
	public var color:Color = 0x7a6a3aff;
	public var width:Float = 16;
	public var height:Float = 16;
	public var tilt:Float = 0.0;
	// reduce gaps between chars? 
	// todo - it doesn't
	// @global
	public var letterSpace:Float = -5.0; 

	public function new() {}

}
