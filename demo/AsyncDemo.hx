using org.sugar.Async;
import org.sugar.Async;

class AsyncDemo {
	static var a = new Async<{x:Int}>();

	public static function main(){
		var b = new Async<Int>();
		foo.wait(4.toAsync());
		b.yield(4);
	}
	
	public static function foo(x:Int){
		trace(x);
	}
	
	
}

