import js.JQuery;
import org.sugar.Async;
using org.sugar.Async;
using JQueryDemo.JqAsync;
class JQueryDemo {

	public static function main(){
		var j = new JQuery('#foo');
		j.html('whooo');
		
		var e = j.click.cAsync();
		bar.wait(e);
	}
	
	public static function bar(e:JqEvent){
		trace(e);
	}
}

typedef JqF = JqEvent->Void;
class JqAsync
{
	public static function cAsync(jqf: (JqEvent->Void)->JQuery):Async<JqEvent>{
		var k = new Async<JqEvent>();
		var f = function(j:JqEvent) k.yield(j);
		jqf(f);
		return k;
	}

	public static function cAsyncTuple2(jqf1: JqF->JQuery, jqf2: (JqEvent->Void)->JQuery):Tuple<Async<JqEvent>, Async<JqEvent>>{
		var k = new Async<JqEvent>();
		var j = new Async<JqEvent>();
		var t = new Tuple(k,j);
		var f = function(l:JqEvent) k.yield(l);
		var g = function(l:JqEvent) j.yield(l);
		jqf1(f);
		jqf2(g);
		return t;
	}
	public static function cAsyncOpt<A>( jqf:A->JqF->JQuery,  x:A ) : Async<JqEvent>{
		var a = new Async<JqEvent>();
		var f = function(j:JqEvent) a.yield(j);
		jqf(x,f);
		return a;
	}
	
	public static function cAsync2Opt<A,B>( jqf:A->B->JqF->JQuery,  x:A, y:B) : Async<JqEvent>{
		var a = new Async<JqEvent>();
		var f = function(j:JqEvent) a.yield(j);
		jqf(x,y,f);
		return a;
	}
	public static function cAsync2OptVoid<A,B>( jqf:A->B->(Void->Void)->JQuery,  x:A, y:B) : Async<Void>{
		var a = new Async<Void>();
		var f = function(j:Void) : Void  {a.yield(j);}
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