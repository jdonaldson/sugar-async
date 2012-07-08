package async;

import async.Async;
using async.Promise;
import haxe.macro.Context;
import haxe.macro.Expr;


class Promise<T> extends Async<T>{
    public var error(default,null):Async<Dynamic>;
    public function new(){
        super();
        error = new Async<Dynamic>();
    }

    private static function __init__(){
        var whenf = function(arr:Array<Dynamic>):Dynamic{
            var allf = function(f:Dynamic){
                if (Promise.allSet(cast arr)){
                    var vals = [];
                    for (a in arr) vals.push(a._val);
                    Reflect.callMethod(null, f, vals);
                }
            }
            for (a in arr) a.then(allf);
            var ret = {then:function(x:Dynamic) allf(x)}
            return ret;
        }
        Promise.when = Reflect.makeVarArgs(whenf);
    }
    /**
     *  utility function to determine if all Async values are set.
     **/
    private static function allSet(as:Array<Async<Dynamic>>): Bool{
        for (a in as) if (!a.set) return false;
        return true;

    }

    @:overload(function(a:A,b:B):Void{})
    public dynamic static function foo<A,B,C>(a:A, b:B, c:C){}

    @:overload(function(arg1:Promise<A>, arg2:Promise<B>):{then:(A->B->Dynamic)}{})
    @:overload(function(arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>):{then:(A->B->C->Dynamic)}{})
    @:overload(function(arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>, arg4:Promise<D>):{then:(A->B->C->D->Dynamic)}{})
    @:overload(function(arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>, arg4:Promise<D>, arg5:Promise<E>):{then:(A->B->C->D->E->Dynamic)}{})
    public dynamic static function when<A,B,C,D,E,F>(arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>, arg4:Promise<D>, arg5:Promise<E>, arg6:Promise<F>):{then:(A->B->C->D->E->F->Dynamic)}{
        return null;
    }

    public static function wait<A,B>( f:A->B, arg1:Promise<A> ) : Promise<B> {
        var ret = new Promise<B>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic {
            if(ret_func) return f;
            if (arg1.set) {
                try{
                    ret.yield(f(arg1._val));
                } catch (e:Dynamic){
                    if (ret.error._update.length == 0) throw e;
                    ret.error.yield(e);
                }
                return true;

            } else return false;
        }
        yieldf(null,false);
        arg1.addUpdate(yieldf);
        return ret;
    }
    /**
      Converts any value to a Promise
     **/
    public static function promise<T>(_val:T) : Promise<T>{
        var ret = new Promise<T>();
        ret.yield(_val);
        return ret;
    }
}

class Promise2<T> extends Promise<T>{
    /**
     *  Triggers the function [f] once all the Promise variables ([arg1],[arg2]) yield
     **/
    public static function wait<A,B,C>( f:A->B->C, arg1:Promise<A>, arg2:Promise<B> ) : Promise<C> {
        var ret = new Promise<C>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic {
            if(ret_func == true) return f;
            if (Promise.allSet( [arg1, cast arg2])) {
                try{
                    ret.yield(f(arg1.val, arg2.val));
                } catch (e:Dynamic){
                    if (ret.error._update.length == 0) throw e;
                    ret.error.yield(e);
                }
                return true;
            } else return false;
        };
        yieldf(null);
        for (x in  [arg1, cast arg2]) {
            x.addUpdate(yieldf);
            x.error.linkto(ret.error);
        }
        return ret;
    }
}

class Promise3<T> extends Promise<T>{
    /**
     *  Triggers the function [f] once all the async variables ([arg1],[arg2], etc.) yield
     **/
    public static function wait<A,B,C,D>( f:A->B->C->D, arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>) : Promise<D> {
        var ret = new Promise<D>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic{
            if(ret_func == true) return f;
            if (Promise.allSet( [arg1, cast arg2,cast arg3])) {
                try{
                    ret.yield(f(arg1.val, arg2.val, arg3.val));
                } catch (e:Dynamic){
                    if (ret.error._update.length == 0) throw e;
                    ret.error.yield(e);
                }
                return true;
            } else return false;
        };
        yieldf(null);
        for (x in [arg1, cast arg2, cast arg3]) {
            x.addUpdate(yieldf);
            x.error.linkto(ret.error);
        }
        return ret;
    }
}

class Promise4<T> extends Promise<T>{
    /**
     *  Triggers the function [f] once all the Promise variables ([arg1],[arg2], etc.) yield
     **/
    public static function wait<A,B,C,D,E>( f:A->B->C->D->E, arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>, arg4:Promise<D>) : Promise<E> {
        var ret = new Promise<E>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic{
            if(ret_func == true) return f;
            if (Promise.allSet( untyped [arg1,  arg2,  arg3,  arg4])) {
                try{
                    ret.yield(f(arg1.val, arg2.val, arg3.val, arg4.val));
                } catch (e:Dynamic){
                    ret.error.yield(e);
                }
                return true;
            } else return false;
        };
        yieldf(null);
        for (x in [arg1, cast arg2, cast arg3, cast arg4]) {
            x.addUpdate(yieldf);
            x.error.linkto(ret.error);
        }
        return ret;
    }
}

class Promise5<T> extends Promise<T>{
    /**
     *  Triggers the function [f] once all the Promise variables ([arg1],[arg2], etc.) yield
     **/
    public static function wait<A,B,C,D,E,F>( f:A->B->C->D->E->F, arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>, arg4:Promise<D>, arg5:Promise<E>) : Promise<F> {
        var ret = new Promise<F>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic{
            if(ret_func == true) return f;
            if (Promise.allSet(untyped [arg1,arg2,arg3,arg4,arg5])) {
                try{
                    ret.yield(f(arg1.val, arg2.val, arg3.val, arg4.val, arg5.val));
                } catch (e:Dynamic){
                    if (ret.error._update.length == 0) throw e;
                    ret.error.yield(e);
                }
                return true;
            } else return false;
        };
        yieldf(null);
        for (x in  [arg1, cast arg2,cast arg3,cast arg4,cast arg5]) {
            x.addUpdate(yieldf);
            x.error.linkto(ret.error);
        }
        return ret;
    }

}
class Promise6<T> extends Promise<T>{
    /**
     *  Triggers the function [f] once all the Promise variables ([arg1],[arg2], etc.) yield
     **/
    public static function wait<A,B,C,D,E,F,G>( f:A->B->C->D->E->F->G, arg1:Promise<A>, arg2:Promise<B>, arg3:Promise<C>, arg4:Promise<D>, arg5:Promise<E>, arg6:Promise<F>) : Promise<G> {
        var ret = new Promise<G>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic{
            if(ret_func == true) return f;
            if (Promise.allSet(untyped [arg1,arg2,arg3,arg4,arg5, arg6])) {
                try{
                    ret.yield(f(arg1.val, arg2.val, arg3.val, arg4.val, arg5.val, arg6.val));
                } catch (e:Dynamic){
                    if (ret.error._update.length == 0) throw e;
                    ret.error.yield(e);
                }
                return true;
            } else return false;
        };
        yieldf(null);
        for (x in  [arg1, cast arg2, cast arg3, cast arg4, cast arg5, cast arg6]) {
            x.addUpdate(yieldf);
            x.error.linkto(ret.error);
        }
        return ret;
    }

}

/**
 *  A special enum that can be thrown inside yielded functions to alter overall yield behavior for the relevant Promise variable.
 **/
enum Yield{
    STOP;
    REDOALL;
    REMOVEME;
    REPEAT;
}

