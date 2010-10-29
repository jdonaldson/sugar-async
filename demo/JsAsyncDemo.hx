import org.sugar.Async;
using org.sugar.Async;
import js.Dom;
class JsAsyncDemo {
	static var click = new Async<Event>();
	
	public static function main(){
		var val = foo.wait(click);
		bar.wait2(val,5.toAsync());
	}
	
	public static function foo(x:Event){
		trace('inside foo');
		return 10;
	}
	
	public static function bar(y:Int, z:Int){
		trace('inside bar: y: '+ y + ' z: ' + z);
		throw Yield.REMOVEME;
	}
	
}