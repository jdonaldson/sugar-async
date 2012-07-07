import async.Promise; 
import flash.events.IEventDispatcher;
import flash.Lib;
using  async.Promise;
import flash.events.Event;
using SwfAsyncDemo.Foo;
import flash.events.MouseEvent;
class SwfAsyncDemo {
    public static function main(){
        var f = Lib.current.stage.clickToPromise();
        bar.wait(f);
    }
    public static function bar(x:MouseEvent){
        trace(x.localX);
    }
}
class Foo{
    public static function clickToPromise(x:IEventDispatcher):Promise<MouseEvent>{
        var y = new Promise<MouseEvent>();
        x.addEventListener(MouseEvent.CLICK,y.yield);
        return y;
    }
}
