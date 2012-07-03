package org.sugar;
using org.sugar.Async;
import haxe.macro.Context;
import haxe.macro.Expr;
class Async<T>{
    private static var yield_f:Dynamic;

    public var val(_checkval,null):T;
    private var _val:T;
    public var error(default,null):Async<Dynamic>;
    public var set(default,null):Bool;
    private var _update:Array<T->Bool->Dynamic>;
    private var _remove:Array<Dynamic>;
    public function new(){
        set = false;
        _update = new Array<T->Bool->Dynamic>();
        _remove = new Array<Dynamic>();
        error = new Async<Dynamic>();
    }
    


    /**
     *  yields the given value for processing on any waiting functions.
     **/
    public function yield(val:T){
        set = true;
        this._val = val;
        var repeat = true;
        while(repeat){		
            repeat = false;
            for (r in _remove) _update.remove(r);
            _remove = new Array<Dynamic>();
            for (f in _update)  {
                Async.yield_f = f(null,true);
                try { cast(f)(this._val, null); }
                catch(status:Yield){
                    switch(status){
                        case REDOALL: {
                            repeat = true;
                            break;
                        }
                        case REMOVEME: {
                            _remove.push(f);
                            continue;
                        }
                        case REPEAT: repeat = true;
                        case STOP: break;
                    }
                } 
                Async.yield_f = null;
            }
        }

    }

    /**
     *  Indicates if async is currently yielding for the given function.
     **/
    public static function yieldingFor(f:Dynamic) : Bool{
        return Reflect.compareMethods(f,Async.yield_f);
    }


    /**
     *  add a wait function directly to the async instance.
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

    private function linkto(a:Async<T>){
        var f = function(t:T, b:Bool){
            a.yield(t);
        }
        this.addUpdate(f);
    }

    private function _checkval(){
        if (!set) throw('Error: Value access on an unset Async variable.');
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
     *  utility function to determine if all asynchronous values are set.
     **/
    private static function allSet(as:Array<Async<Dynamic>>): Bool{
        for (a in as) if (!a.set) return false;
        return true; 
    }

    /**
     *  Triggers the function [f] once the async variable [arg1] yields
     **/
    public static function wait<A,B>( f:A->B, arg1:Async<A> ) : Async<B> {
        var ret = new Async<B>();
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
    public static function toAsync<T>(_val:T) : Async<T>{
        var ret = new Async<T>();
        ret.yield(_val);
        return ret;
    }
}

class Async2<T> extends Async<T>{
    /**
     *  Triggers the function [f] once all the async variables ([arg1],[arg2]) yield
     **/
    public static function wait<A,B,C>( f:A->B->C, arg1:Async<A>, arg2:Async<B> ) : Async<C> {
        var ret = new Async<C>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic {
            if(ret_func == true) return f;
            if (Async.allSet( [arg1, cast arg2])) {
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

class Async3<T> extends Async<T>{
    /**
     *  Triggers the function [f] once all the async variables ([arg1],[arg2], etc.) yield
     **/
    public static function wait<A,B,C,D>( f:A->B->C->D, arg1:Async<A>, arg2:Async<B>, arg3:Async<C>) : Async<D> {
        var ret = new Async<D>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic{
            if(ret_func == true) return f;
            if (Async.allSet( [arg1, cast arg2,cast arg3])) {
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

class Async4<T> extends Async<T>{
    /**
     *  Triggers the function [f] once all the async variables ([arg1],[arg2], etc.) yield
     **/
    public static function wait<A,B,C,D,E>( f:A->B->C->D->E, arg1:Async<A>, arg2:Async<B>, arg3:Async<C>, arg4:Async<D>) : Async<E> {
        var ret = new Async<E>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic{
            if(ret_func == true) return f;
            if (Async.allSet( untyped [arg1,  arg2,  arg3,  arg4])) {
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

class Async5<T> extends Async<T>{
    /**
     *  Triggers the function [f] once all the async variables ([arg1],[arg2], etc.) yield
     **/	
    public static function wait<A,B,C,D,E,F>( f:A->B->C->D->E->F, arg1:Async<A>, arg2:Async<B>, arg3:Async<C>, arg4:Async<D>, arg5:Async<E>) : Async<F> {
        var ret = new Async<F>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic{
            if(ret_func == true) return f;
            if (Async.allSet(untyped [arg1,arg2,arg3,arg4,arg5])) {
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
class Async6<T> extends Async<T>{
    /**
     *  Triggers the function [f] once all the async variables ([arg1],[arg2], etc.) yield
     **/	
    public static function wait<A,B,C,D,E,F,G>( f:A->B->C->D->E->F->G, arg1:Async<A>, arg2:Async<B>, arg3:Async<C>, arg4:Async<D>, arg5:Async<E>, arg6:Async<F>) : Async<G> {
        var ret = new Async<G>();
        var yieldf = function(x:Dynamic,?ret_func:Bool) : Dynamic{
            if(ret_func == true) return f;
            if (Async.allSet(untyped [arg1,arg2,arg3,arg4,arg5, arg6])) {
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
 *  A special enum that can be thrown inside yielded functions to alter overall yield behavior for the relevant async variable.
 **/
enum Yield{
    STOP;
    REDOALL;
    REMOVEME;
    REPEAT;
}

