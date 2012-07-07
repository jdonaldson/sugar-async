import async.Promise; 
using  async.Promise;
import flash.events.Event;
using SwfAsyncDemo.Foo;
import flash.events.MouseEvent;
class SwfAsyncDemo {
	public static function main(){

			var f = flash.Lib.current.stage.clickToAsync();
			bar.wait(f);
	}
	public static function bar(x:MouseEvent){
		trace(x.localX);
	}
}
class Foo{
	public static function clickToAsync(x:flash.events.IEventDispatcher):Async<MouseEvent>{
		var y = new Async<MouseEvent>();
		x.addEventListener(MouseEvent.CLICK,y.yield);
		return y;
	}
}
