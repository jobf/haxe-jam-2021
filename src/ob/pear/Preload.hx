package ob.pear;

import utils.Loader;
import lime.graphics.Image;

class Preload{
    public static function letsGo(imagePaths:Array<String>, onLoadAll:Array<Image>->Void){
        Loader.imageArray(imagePaths, onLoadAll);
    }
}