package async;

import async.Error;
using async.Promise;
import haxe.macro.Context;
import haxe.macro.Expr;


class Promise<T> extends Error<T>{
    public var error(default,null):Error<Dynamic>;
    public function new(){
        super();
        error = new Error<Dynamic>();
    }

    private static function __init__(){
        //arr = Array of promises
        var whenf = function(arr:Array<Dynamic>):Dynamic{
            // could be an array of arrays
            if (arr.length > 0 && Std.is(arr[0],Array)) arr = arr[0];
            var p = new Promise<Dynamic>();
            var parr:Array<Promise<Dynamic>> = cast arr; 
            var pthen =  function(f:Dynamic){
                var pthen = function(v:Dynamic){
                    if (Promise.allSet(parr)){
                        var vals = [];
                        for (pv in parr) vals.push(pv.val);
                        try{
                            p.yield(Reflect.callMethod(null,f,vals));

                        } catch (e:Dynamic){
                            if (p.error._update.length == 0) throw e;
                            p.error.yield(e);
                        }
                    }
                }
                for (p in parr) p.thenOnce(pthen);
                return p;
            }
            var ret = {then:pthen};
            return ret;
        }
        Promise.when = Reflect.makeVarArgs(whenf);
    }
    /**
     *  utility function to determine if all Promise values are set.
     **/
    private static function allSet(as:Array<Promise<Dynamic>>): Bool{
        for (a in as) if (!a.set) return false;
        return true;
    }

    @:overload(function(arg1:Promise<A>, arg2:Promise<B>):{then:(A->B->C)->Promise<C>}{})
    @:overload(function(arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>):{then:(A->B->C->D)->Promise<D>}{})
    @:overload(function(arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>, arg4:Promise<D>):{then:(A->B->C->D->E)->Promise<E>}{})
    @:overload(function(arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>, arg4:Promise<D>, arg5:Promise<E>):{then:(A->B->C->D->E->F)->Promise<F>}{})
    @:overload(function(arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>, arg4:Promise<D>, arg5:Promise<E>, arg6:Promise<F>):{then:(A->B->C->D->E->F->G)->Promise<G>}{})
    public dynamic static function when<A,B,C,D,E,F,G>(f:Array<Promise<Dynamic>>):{then:(Array<Dynamic>->B)->Promise<B>} {return null;}

    /**
      Converts any value to a Promise
     **/
    public static function promise<T>(_val:T) : Promise<T>{
        var ret = new Promise<T>();
        ret.yield(_val);
        return ret;
    }
}



