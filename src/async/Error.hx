
package async;
class Error<T>{
    public var val(_checkval,null):T;
    private var _val:T;
    public var set(default,null):Bool;
    private var _update:Array<T->Dynamic>;
    public function new(){
        set = false;
        _update = new Array<T->Dynamic>();
    }


    /**
     *  Yields the given value for processing on any waiting functions.
     **/
    public function yield(val:T){
        set = true;
        this._val = val;
        for (f in _update) f(this._val);
    }

    /**
     *  add a wait function directly to the Promise instance.
     **/
    public function thenOnce<A>(f:T->A):Promise<A>{
        var ret = new Promise<A>();
        _update.push(f);
        return ret;
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
        return this._update.remove(f);
    }

    /**
      Clears the queue of waited functions
     **/
    public function clearThen(){
        _update = new Array<T->Dynamic>();
    }
}
