package org.sugar;

import org.sugar.Bond;

class Async<T>{
	public var val(_checkval,null): T;
	public var set(default,null): Bool;
	private var _val: T;
	private var _bond_update: List<IBond>;

	public function new(){
		set = false;
		_bond_update = new List<IBond>();
	}

	public function yield(val:T){
		set = true;
		this._val = val;
		for (b in _bond_update)	b.update();
	}
	
	private function _checkval(){
		if (!set) throw('Error: Value access on an unset Async variable.');
		else return _val;
	}
	
	public function addBond(bnd:IBond){ _bond_update.add(bnd); }
	
        public function removeBond(bnd:IBond){ return _bond_update.remove(bnd);}
	
	public function clearBonds(){ _bond_update = new List<IBond>(); }
	
	public static function toAsync<T>(v:T){
		return new Async<T>();
	}
	
	public static function wait<A,B>(f:A->B, a:Async<A>):Async<B>{
		var ret = new Async<B>();
		var bnd = new Bond<A,B>(f,a,ret);
		a.addBond(bnd);
		bnd.update();
		return ret;
	}
	
	public static function bind<A,B>(f:A->B, a:Async<A>):Bond<A,B>{
		var ret = new Async<B>();
		var bnd = new Bond<A,B>(f,a,ret);
		a.addBond(bnd);
		bnd.update();
		return bnd;
	}
}


//untested!
class Async2{
	public static function wait<A,B,C>(f:A->B->C, a:Async<A>, b:Async<B>):Async<C>{
		var ret = new Async<C>();
		var bnd = new Bond2<A,B,C>(f,a,b,ret);
		a.addBond(bnd);
		b.addBond(bnd);
		bnd.update();
		return ret;
	}
	
	public static function bind<A,B,C>(f:A->B->C, a:Async<A>, b:Async<B>):Bond2<A,B,C>{
		var ret = new Async<C>();
		var bnd = new Bond2<A,B,C>(f,a,b,ret);
		a.addBond(bnd);
		b.addBond(bnd);
		bnd.update();
		return bnd;
	}
}

class Async3{
	public static function wait<A,B,C,D>(f:A->B->C->D, a:Async<A>, b:Async<B>, c:Async<C>):Async<D>{
		var ret = new Async<D>();
		var bnd = new Bond3<A,B,C,D>(f,a,b,c,ret);
		a.addBond(bnd);
		b.addBond(bnd);
		c.addBond(bnd); 
		bnd.update();
		return ret;
	}
	
	public static function bind<A,B,C,D>(f:A->B->C->D, a:Async<A>, b:Async<B>, c:Async<C>):Bond3<A,B,C,D>{
		var ret = new Async<D>();
		var bnd = new Bond3<A,B,C,D>(f,a,b,c,ret);
		a.addBond(bnd);
		b.addBond(bnd);
		c.addBond(bnd);
		bnd.update();
		return bnd;
	}
}



