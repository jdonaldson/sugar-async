package async; 
using async.Promise; 
import haxe.macro.Context;
import haxe.macro.Expr;
class Promise<T>{
    private var yield_f:Dynamic;
    public var val(_checkval,null):T;
    private var _val:T;
    public var error(default,null):Promise<Dynamic>;
    public var set(default,null):Bool;
    private var _update:Array<T->Bool->Dynamic>;
    private var _remove:Array<Dynamic>;
    public function new(){
        set = false;
        _update = new Array<T->Bool->Dynamic>();
        _remove = new Array<Dynamic>();
        error = new Promise<Dynamic>();
    }
    


    /**
     *  Yields the given value for processing on any waiting functions.
     **/
    public function yield(val:T){
        trigger(val);
        _update = new Array<Dynamic>();

    }

    /**
      yields the given value for processing on any waiting functions.
      Can be called more than once. 
     **/
    public function trigger(val:T){
        set = true;
        this._val = val;
        for (f in _update)  {
            yield_f = f(null,true);
            f(this._val,null);
        }
        yield_f = null;
    }


    /**
     *  Indicates if Promise is currently yielding for the given function.
     **/
    public function yieldingFor(f:Dynamic) : Bool{
        return Reflect.compareMethods(f,this.yield_f);
    }


    /**
     *  add a wait function directly to the Promise instance.
     **/
    public function addWait(f:T->Dynamic){
        var f2 = function(x:T, ?ret_func:Bool) : Dynamic{
            if (ret_func  == true) return f;
            f(x);
            return true;
        }
        _update.push(f2);
    }

    private function addUpdate(f:T->Bool->Dynamic){
        _update.push(f);
    }

    private function linkto(a:Promise<T>){
        var f = function(t:T, b:Bool){
            a.yield(t);
        }
        this.addUpdate(f);
    }

    private function _checkval(){
        if (!set) throw('Error: Value access on an unset Promise variable.');
        else return _val;
    }

    /**
     *  Removes the waited function.  This can be a single argument function given by [addWait()], 
     *  or a multi-argument wait function given by [wait#()];
     **/
    public function removeWait(f:Dynamic): Bool{
        var new_update = new Array<T->Bool->Dynamic>();
        var found = false;
        for (idx in 0..._update.length){
            var rev_idx =_update.length-idx-1;
            var original_f = cast(_update[rev_idx])(null, true);
            if (!found && Reflect.compareMethods(original_f,f)){
                found = true;
                continue;
            }
            new_update.push(_update[rev_idx]);
        }
        new_update.reverse();
        _update = new_update;
        return found;
    }

    /**
     *  Clears the queue of waited functions 
     **/
    public function clearWait(){
        _update = new Array<T->Bool->Dynamic>();
    }

    /**
     *  utility function to determine if all Promise values are set.
     **/
    private static function allSet(as:Array<Promise<Dynamic>>): Bool{
        for (a in as) if (!a.set) return false;
        return true; 
    }

    /**
     *  Triggers the function [f] once the Promise variable [arg1] yields
     **/
    public static function wait<A,B>( f:A->B, arg1:Promise<A> ) : Promise<B> {
        var ret = new Promise<B>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic {
            if(ret_func != null) return f;
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
        yieldf(null);
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

