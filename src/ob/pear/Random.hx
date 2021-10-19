package ob.pear;

import lime.math.Vector2;

/* copied from echo sample wirth gratitude :heart: */
class Random {
	public static inline function range(?min:Float = -1, ?max:Float = 1):Float
		return min + Math.random() * (max - min);

	public static inline function range_int(?min:Float = -1, ?max:Float = 1):Int
		return Std.int(range(min, max));

	public static inline function range_int_to_string(?min:Float, ?max:Float):String
		return "" + Math.floor(range_int(min, max));

	public static inline function chance(percent:Float = 50):Bool
		return Math.random() < percent / 100;

	public static inline function range_vector2(min:Vector2, max:Vector2) {
		return new Vector2(range(min.x, max.y), range(min.y, max.y));
	}
}
