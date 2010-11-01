using org.sugar.ThreadedAsync;
typedef TAsync<T> =  org.sugar.ThreadedAsync<T>;

class ThreadedAsyncDemo {
	static var done:Bool = false;
	public static function main(){
				var a = new TAsync<Int>();
				var b = new TAsync<Int>();
				var v1 = foo.wait(a); // 3
				var v4 = foo2.wait2(a,b); // 6
				var v2 = foo2.wait2(a,v1); // 5
				var v3 = foo2.wait2(v1,v2);// 8
				cleanup.wait(v3);
				a.yield(2);
				b.yield(4);
				while(!done){}
	}
	public static function foo(x:Int){
		trace(x+1);
		return x+1;
	}
	
	public static function foo2(x:Int, y:Int){
		trace(x+y);
		return x+y;
	}

	public static function foo3(x:Int, y:Int,z:Int){
		trace(x+y+z);
		return x+y+z;
	}
	
	public static function cleanup(x:Int){
		done = true;
	}
	
}