import js.JQuery;
import org.sugar.Async;
using org.sugar.Async;
using JQueryDemo.JqAsync;
class JQueryDemo {

	public static function main(){
		var j = new JQuery('#foo');
		j.html('Click/Hover this text!!!');
		
		j.fadeOut.cAsyncOpt(2000).addWait(callback(j.fadeIn,400));
		var e = j.click.async();
		var th = j.hover.asyncTuple();
		bar.wait(e);
		foo.wait2(th.a, th.b);
		baz.wait2(e, th.a);
		
	}
	
	
	public static function opacity(){
		
	}

	
	public static function bar(e:JqEvent):Int{
		trace('bar fired on click!');
		return 1;
	}
	
	
	
	
	public static function foo(e:JqEvent, e2:JqEvent){
		trace('foo fired on hover!');
	}
	
	public static function baz(e:JqEvent, e2:JqEvent){
		trace('baz fired after hovered and clicked!');
		if (baz.yieldingFor()) throw Yield.REMOVEME;
	}
	
	
}

typedef JqF = JqEvent->Void;
class JqAsync
{
	public static function async(jqf: (JqEvent->Void)->JQuery):Async<JqEvent>{
		var k = new Async<JqEvent>();
		var f = function(j:JqEvent) k.yield(j);
		jqf(f);
		return k;
	}

	public static function asyncTuple(f:(JqEvent->Void)->(Void->Void)->JQuery) : Tuple<Async<JqEvent>, Async<JqEvent>>{
		var a1 = new Async<JqEvent>();
		var a2 = new Async<JqEvent>();
		var t = new Tuple(a1,a2);
		var f1 = function(j:JqEvent) a1.yield(j);
		var f2 = function() a2.yield(null);
		f(f1,f2);
		return t;
	}
	
	
	public static function cAsyncOpt<A>( jqf:A->(Void->Void)->JQuery,  x:A ) : Async<Dynamic>{
		var a = new Async<Dynamic>();
		var f = function() a.yield(null);
		jqf(x,f);
		return a;
	}
	
	public static function cAsyncOpt2<A,B>( jqf:A->B->JqF->JQuery,  x:A, y:B) : Async<JqEvent>{
		var a = new Async<JqEvent>();
		var f = function(j:JqEvent) a.yield(j);
		jqf(x,y,f);
		return a;
	}
	
	
}

class Tuple<A,B>
{
	public var a:A;
	public var b:B;

	public function new( a:A, b:B ){
		this.a = a;
		this.b = b;
	}
}