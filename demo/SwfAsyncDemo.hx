import org.sugar.Async;
using org.sugar.Async;
import flash.events.MouseEvent;
class SwfAsyncDemo {
	public static function main(){
			var x = new Async<MouseEvent>();
			flash.Lib.current.stage.addEventListener(MouseEvent.CLICK, x.yield);
			foo.wait(x);
	}
	public static function foo(x:MouseEvent){
		trace(Async.yieldingFor(foo));
		trace(x.localX);
	}
}