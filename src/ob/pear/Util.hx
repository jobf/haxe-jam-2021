package ob.pear;

class IntExtensions{
    public static function incrementMax(int:Int, max:Int){
        int++;
        if(int > max) int = 0;
    }
}


class ArrayExtensions{
    public static function all<T>(array:Array<T>, call:T->Void){
        for(item in array) call(item);
    }
}