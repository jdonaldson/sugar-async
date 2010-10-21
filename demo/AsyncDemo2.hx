using org.sugar.Async;
import  org.sugar.Async;
/**
 * <p><b>Description</b> :	Description
 * </p>
 * <p><b>langversion</b> HaXe 2</p>
 * <p><b>targets</b> cpp, flash, flash9, js, neko, php</p>
 * <p><b>author</b>	Justin Donaldson : <a href="mailto:jdonaldson@gmail.com">jdonaldson@gmail.com</a></p>
 * <p><b>since</b>	2010-10-20</p>
 */
class AsyncDemo2 {
	static var localX = new Async<Float>();
	static var localY = new Async<Float>();
	static var localFoo = new Async<Float>();
	public static function main(){
		var a = doX.wait(localX);
		var b = doY.wait(localY);
		doXY.wait2(localX, localY);
		localX.yield(4);
		localY.yield(5);
		var c = doX.wait(a);
		var d = doXY.wait2(c,a);
	}

	
	

	public static function doX(x:Float){
		trace("x: " + Std.string(x)); 
		return x + 1;

	}
	
	public static function doY(y:Float){
		trace("y: " + Std.string(y)); 
		return y + 2;

	}
	
	public static function doXY(x:Float, y:Float ){
		trace("x+ ' ' + y: " + Std.string(x+ ' ' + y)); 
	}
	
	
	public static function foo(){
		trace('yielding');
		localX.yield(1);
	}
	
}

