package data;

import core.Launcher.LauncherStats;
import core.Wave.WaveStats;
import lime.graphics.Image;
import lime.math.Vector2;
import peote.view.Color;
import utils.Loader;

class Global {
	
	public static var cursorColor:Color = 0xf01bf388; //0x44ff44aa
	public static var textBgColor:Color = 0x7fb3e1FF;//0xb7dbfaFF;//0x4370ccff;//0x905a00ff;
	public static var onHoverColor:Color = 0x7af31bFF;
	
	public static var fontSize:Int = 32;
	public static var margin:Float = 15.0;
	public static var whoWonLastRound:Int = 0;
	public static var opponentIndex:Int = 0;
	public static var currentWaveSetup:WaveStats;
	public static var colors:Map<PlayerId, Color> = [
		A => textBgColor,//0x1b4bacff,
		B => 0xe09a94FF//0xf36464ff//0xac1b75ff,
	];
	public static var availableLaunchers:Array<LauncherStats> = [];

	public static function resetGame(){
		availableLaunchers = [Barracks.Launchers[lBUBBLER]];
		opponentIndex = 0;
		whoWonLastRound = 0;
	}
}

@:enum abstract PlayerId(Int) from Int to Int {
	var A = 1;
	var B = 2;
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

	
	public static function letsGo(pear:Pear, onLoadAll:Map<ElementKey, Image>->Void) {
		Global.margin = Std.int(pear.window.height * 0.015);
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


