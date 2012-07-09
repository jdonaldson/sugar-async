
package async;
class Error<T>{
    private var yield_f:Dynamic;
    public var val(_checkval,null):T;
    private var _val:T;
    public var set(default,null):Bool;
    private var _update:Array<T->Bool->Dynamic>;
    public function new(){
        set = false;
        _update = new Array<T->Bool->Dynamic>();
    }


    /**
     *  Yields the given value for processing on any waiting functions.
     **/
    public function yield(val:T){
        set = true;
        this._val = val;
        for (f in _update)  {
            yield_f = f(null,true);
            f(this._val,false);
        }
        yield_f = null;
    }

    /**
     *  add a wait function directly to the Promise instance.
     **/
    public function thenOnce(f:T->Dynamic){
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

    private function linkto(a:Error<T>){
        this.thenOnce(a.yield);
    }

    private function _checkval(){
        if (!set) throw('Error: Value access on an unset Promise variable.');
        else return _val;
    }

    /**
      Removes the async function callback.  This can be a single argument 
      function given by [then()].
     **/
    public function removeThen(f:Dynamic): Bool{
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
      Clears the queue of waited functions
     **/
    public function clearThen(){
        _update = new Array<T->Bool->Dynamic>();
    }
}
