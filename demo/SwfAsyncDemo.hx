import async.Promise; 
import flash.events.IEventDispatcher;
import flash.Lib;
using  async.Promise;
import flash.events.Event;
using SwfAsyncDemo.Foo;
import flash.events.MouseEvent;
class SwfAsyncDemo {
    public static function main(){
        //var f = Lib.current.stage.clickToPromise();
        //bar.wait(f);
        var foo1 = new Promise<Int>();
        var foo2 = new Promise<Int>();
        var foo3 = new Promise<Int>();

        Promise.when(foo1,foo2).then(function(x,y) trace(x + y));
        foo1.yield(1);
        foo2.yield(1);
        foo3.yield(1);
    }
    public static function bar(x:MouseEvent){
        trace(x.localX);
    }
}
class Foo{
    public static function clickToPromise(x:IEventDispatcher):Promise<MouseEvent>{
        var y = new Promise<MouseEvent>();
        x.addEventListener(MouseEvent.CLICK,y.trigger);
        return y;
    }
}
