package data;

import core.Wave.WaveStats;
import lime.graphics.Image;
import lime.math.Vector2;
import peote.view.Color;
import utils.Loader;

class Global {
	public static var fontSize:Int = 32;
	public static var margin:Int = 15;
	public static var wonLastRound:Int = 0;
	public static var opponentIndex:Int = 0;
	public static var currentWaveSetup:WaveStats;
	public static var colors:Map<Int, Color> = [
		0 => 0x1b4bacff,
		1 => 0xac1b75ff,
	];
}

// z-index for various elements
@:enum abstract Layers(Int) from Int to Int {
	var CURSOR = 0;
	var TEXT = -10;
	var BUTTONS = -20;
	var LAUNCHERS = -40;
	var PROJECTILES = -50;
	var IMAGES = -80;
	var BACKGROUND = -90;
}

@:enum abstract ElementKey(Int) from Int to Int {
	var RECT;
	var CIRCLE;
	var POLYGON;
	var TITLE;
	var LORD;
	var BOB;
	var lBUBBLER;
	var lBUILDING;
	var lARCHER;
	var pKNIGHT;
	var lDOGGER;
	var lFOWLER;
	var pARROW ;
	var pBUBBLE;
	var pMelee; 
	var pFowl;
	var pDog;
	// var projectileARROW;
}

class Preload {
	static var assetPaths(default, null):Map<ElementKey, String> = [
		TITLE => 'assets/png/LLG7TH.png',
		LORD => 'assets/png/templord.png',
		// KENNEL => 'assets/png/beasthouse.png',
		// DOG => 'assets/png/dog.png',
		// CAVALRY => 'assets/png/cavalry.png',
		// ROUNDOVER => 'assets/png/round-over.png',
		// RESTART => 'assets/png/restart.png',
		// QUIT => 'assets/png/quit.png',
		BOB => 'assets/png/templord.png',
		lBUBBLER => 'assets/png/lBubbler.png',
		lBUILDING => 'assets/png/lBuilding.png',
		lARCHER => 'assets/png/lArcher.png',
		lDOGGER => 'assets/png/lDogger.png',
		lFOWLER => 'assets/png/lFowler.png',
		// pARROW => 'assets/png/pArrow.png', todo?
		// pBUBBLE => 'assets/png/pBubble.png', todo?
		pMelee => 'assets/png/pMelee.png',
		pFowl => 'assets/png/pFowl.png',
		pDog => 'assets/png/pDog.png',
	];

	public static function letsGo(onLoadAll:Map<ElementKey, Image>->Void) {
		var keyValues = [for (_ in assetPaths.keyValueIterator()) _];
		Loader.imageArray([for (kv in keyValues) kv.value], (images) -> {
			var imageMap:Map<ElementKey, Image> = [];
			for (i => kv in keyValues) {
				imageMap[kv.key] = images[i];
			}
			onLoadAll(imageMap);
		});
	}
}

class Size{
	static var tileSize:Vector2 = new Vector2(75, 75); // real size is 150 x 150
	public static function calcVisual(tileWidth:Float, tileHeight:Float){
		return new Vector2(tileSize.x * tileWidth, tileSize.y * tileHeight);
	}
	public static function calcBody(tileWidth:Float, tileHeight:Float){
		var sizeReduction = 0.7;
		return new Vector2((tileSize.x * tileWidth) * sizeReduction, (tileSize.y * tileHeight) * sizeReduction);
	}
}


