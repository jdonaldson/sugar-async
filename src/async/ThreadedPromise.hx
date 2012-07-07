package org.sugar;
#if (cpp||neko)
import Type;
#if neko
	typedef Thread = neko.vm.Thread;
	typedef Mutex = neko.vm.Mutex;
	typedef Lock = neko.vm.Lock;
#elseif cpp
	typedef Thread = cpp.vm.Thread;
	typedef Mutex = cpp.vm.Mutex;
	typedef Lock = cpp.vm.Lock;
#end

class ThreadedAsync<T> {
	private var val:T;
	private var _update:Array<T->Dynamic>;
	private var set:Bool;
	
	private static var _thread_counter = 0;
	private static var _instance_counter = 0;
	private static var _instance_status  = new IntHash<ThreadedAsync<Dynamic>>();
	private static var _f_lock_hash = new IntHash<Lock>();
	private var _thread_status:IntHash<Bool>;
	private var _yielding:Bool;
	private var _yield_queue:List<T>;
	private var _lock:Lock;
	private var _id:Int;
	
	public function new(){
		set = false;
		val = null;
		_yielding = false;
		_yield_queue = new List<T>();
		_thread_status = new IntHash<Bool>();
		_update = new Array<T->Dynamic>();
		_id = ThreadedAsync._instance_counter++;
		_instance_status.set(this._id, this);
/*		var tval = Type.typeof(val); */
/*		if (tval != TFloat && tval != TInt && tval != TNull) */
		_lock = new Lock();
	}

	public function yield(val:T){
		var locked = true;
		while(locked){
			locked = _lock.wait(.1);
			if (locked) trace(_id + ' waiting for lock');
		}
		_lock = new Lock();

		for(fv in _update) {
				var proxy_f = function(){
					var id = Thread.readMessage(true); 
					var val = Thread.readMessage(true);
					trace("Thread " + id + " started, and given " + val);
					var fv = Thread.readMessage(true);
					var main:Thread = Thread.readMessage(true);
					fv(val);
					main.sendMessage(id);
					trace("Thread " + id + " finished");
				}
				var th = Thread.create(proxy_f);
				var cur_id = ThreadedAsync._thread_counter++;
				_thread_status.set(cur_id,false);
				th.sendMessage(cur_id);
				th.sendMessage(val);
				th.sendMessage(fv);
				th.sendMessage(Thread.current());
		}
		
		set = true;
		this.val = val;
		_lock.release();		

	}
	public function addUpdate(f:T->Dynamic){
		_update.push(f);
	}
	
	public function blockForThreads(){
			for (k in _thread_status.keys()) {
				if (_thread_status.get(k)) {
					trace(" Thread " + k + " already reported back");
					trace("thread status: " + Std.string(_thread_status));
					continue;
				}								
				trace('waiting for message...');
				var id = Thread.readMessage(true);
				_thread_status.set(id,true);
				trace(" Thread " + id + " just reported back");
				trace("thread status: " + Std.string(_thread_status));
			}
	}
	
	private static function allAcquire<A>(as:Array<ThreadedAsync<A>>){
		var all_unlocked = false;
		while (all_unlocked){
			for (a in as){
				var this_unlocked =  a._lock.wait(.1);
				if (!this_unlocked) break;
			}
		}
	}
	
	private static function allRelease(as:Array<Dynamic>){
		for (a in as){
			if (a._mutex != null) a._mutex.release();
		}
	}
	
	private static function allSet(as:Array<Dynamic>): Bool{
		for (a in as) {
			if (!a.set) return false;
		}
		return true; 
	}


	public static function blockForAll(){
			for (i in _instance_status) i.blockForThreads();		
	}

	public static function wait<A,B>( f:A->B, arg1:ThreadedAsync<A> ) : ThreadedAsync<B> {
		var ret = new ThreadedAsync<B>();
		if (arg1.set) ret.yield(f(arg1.val));
		else arg1.addUpdate(function(x:A) {
			allAcquire([arg1]);
			ret.yield(f(x));
			allRelease([arg1]);
			});
		return ret;
	}

	public static function wait2<A,B,C>( f:A->B->C, arg1:ThreadedAsync<A>, arg2:ThreadedAsync<B> ) : ThreadedAsync<C> {
		var ret = new ThreadedAsync<C>();
		var f_id = _instance_counter++;
		_f_lock_hash.set(f_id, new Lock());
		var all_set_f = function(x:Dynamic) {
			_f_lock_hash.set(f_id, new Lock());
			if (allSet(cast [arg1,arg2])) {
				allAcquire(cast [arg1,arg2]);
				ret.yield(f(arg1.val, arg2.val));
				_f_lock_hash.get(f_id).release();
				allRelease([arg1,arg2]);
				return true;
			} else {
				_f_lock_hash.get(f_id).release();
				return false;
				
			}
		};

		var all_set = all_set_f(true);
		if (!all_set) for (x in [arg1, arg2]) 	x.addUpdate(all_set_f);
		return ret;
	}

	public static function wait3<A,B,C,D>( f:A->B->C->D, arg1:ThreadedAsync<A>, arg2:ThreadedAsync<B>, arg3:ThreadedAsync<C>) : ThreadedAsync<D> {
		var ret = new ThreadedAsync<D>();
		var all_set_f =function(x:Dynamic) {
			if (allSet( [arg1,arg2,arg3])) {
				allAcquire(cast [arg1,arg2,arg3]);
				ret.yield(f(arg1.val, arg2.val, arg3.val));
				allRelease([arg1,arg2,arg3]);
				return true;
			} else return false;
			};
		var all_set = all_set_f(null);
		if (!all_set) for (x in [arg1, arg2, arg3]) x.addUpdate(all_set_f);
		return ret;		
	}

	public static function wait4<A,B,C,D,E>( f:A->B->C->D->E, arg1:ThreadedAsync<A>, arg2:ThreadedAsync<B>, arg3:ThreadedAsync<C>, arg4:ThreadedAsync<D>) : ThreadedAsync<E> {
		var ret = new ThreadedAsync<E>();
		var all_set_f =function(x:Dynamic) {
			if (allSet([arg1,arg2,arg3,arg4])) {
				allAcquire(cast [arg1,arg2,arg3,arg4]);
				ret.yield(f(arg1.val, arg2.val, arg3.val, arg4.val));
				allRelease([arg1,arg2,arg3,arg4]);
				return true;
			} else return false;
			};
		var all_set = all_set_f(null);
		if (!all_set) for (x in [arg1, arg2, arg3, arg4]) x.addUpdate(all_set_f);
		return ret;
	}
	
	public static function wait5<A,B,C,D,E,F>( f:A->B->C->D->E->F, arg1:ThreadedAsync<A>, arg2:ThreadedAsync<B>, arg3:ThreadedAsync<C>, arg4:ThreadedAsync<D>, arg5:ThreadedAsync<E>) : ThreadedAsync<F> {
		var ret = new ThreadedAsync<F>();
		var all_set_f =function(x:Dynamic) {
			if (allSet([arg1,arg2,arg3,arg4,arg5])) {
				allAcquire(cast [arg1,arg2,arg3,arg4,arg5]);
				ret.yield(f(arg1.val, arg2.val, arg3.val, arg4.val, arg5.val));
				allRelease([arg1,arg2,arg3,arg4,arg5]);
				return true;
			} else return false;
			};
		var all_set = all_set_f(null);
		if (!all_set) for (x in [arg1, arg2, arg3, arg4, arg5]) x.addUpdate(all_set_f);
		return ret;
	}
	
	public static function wait6<A,B,C,D,E,F,G>( f:A->B->C->D->E->F->G, arg1:ThreadedAsync<A>, arg2:ThreadedAsync<B>, arg3:ThreadedAsync<C>, arg4:ThreadedAsync<D>, arg5:ThreadedAsync<E>, arg6:ThreadedAsync<F>) : ThreadedAsync<G> {
		var ret = new ThreadedAsync<G>();
		var all_set_f =function(x:Dynamic) {
			if (allSet([arg1,arg2,arg3,arg4,arg5, arg6])) {
				allAcquire(cast [arg1,arg2,arg3,arg4,arg5,arg6]);
				ret.yield(f(arg1.val, arg2.val, arg3.val, arg4.val, arg5.val, arg6.val));
				allRelease([arg1,arg2,arg3,arg4,arg5,arg6]);
				return true;
			} else return false;
			};
		var all_set = all_set_f(null);
		if (!all_set) for (x in [arg1, arg2, arg3, arg4, arg5, arg6]) x.addUpdate(all_set_f);
		return ret;
	}
	
	public static function destroy<A>(a:ThreadedAsync<A>){
		_instance_status.remove(a._id);
		a.blockForThreads();
		a._update = new Array<A->Dynamic>();
		a._yield_queue = new List<A>();
	}
	
	public static function toAsync<T>(val:T) : ThreadedAsync<T>{
		var ret = new ThreadedAsync<T>();
		ret.yield(val);
		return ret;
	}

}
#end