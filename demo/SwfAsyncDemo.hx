import org.sugar.Async;
using org.sugar.Async;



class SwfAsyncDemo {
	public static function main(){

			var f = flash.Lib.current.stage.clickToAsync();
			bar.wait(f);
	}
	public static function bar(x:MouseEvent){
		trace(x.localX);
	}
}

