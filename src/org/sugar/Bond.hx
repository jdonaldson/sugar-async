package org.sugar;

interface IBond{
	public function update():Void;
	public function halt():Void;
	public function resume():Void;
}


class Bond<A,B> implements IBond {
	private var f:A->B;
	private var a:Async<A>;	
	private var b:Async<B>;
	private var _halt:Bool;
	
	public function new( f:A->B, a:Async<A>, b:Async<B> ){
		this.f = f;
		this.a = a;
		this.b = b;
		_halt = false;
	}
	
	public function update(){
		if (a.set && !_halt) b.yield(f(a.val));
	}
	
	public function halt(){ _halt = true; }
	
	public function resume(){ _halt = false; }
	
	public static function containsFunction(b:BondFriend, f:Dynamic){
		return b.f = f;
	}
	
	public static function allSet<A>(as:Array<Async<A>>): Bool{
		for (a in as) if (!a.set) return false;
		return true; 
	}
		
}

class Bond2<A,B,C> implements IBond {
	private var f:A->B->C;
	private var a:Async<A>;	
	private var b:Async<B>;
	private var c:Async<C>;
	private var _halt:Bool;
	
	public function new( f:A->B->C, a:Async<A>, b:Async<B>, c:Async<C> ){
		this.f = f;
		this.a = a;
		this.b = b;
		this.c = c;
		_halt = false;
	}
	public function halt(){ _halt = true; }
	public function resume(){ _halt = false; }
	
	public function update(){
		if (!_halt && Bond.allSet(cast [a,b])) c.yield(f(a.val, b.val));
	}
}

class Bond3<A,B,C,D> implements IBond {
	private var f:A->B->C->D;
	private var a:Async<A>;	
	private var b:Async<B>;
	private var c:Async<C>;
	private var d:Async<D>;
	private var _halt:Bool;
	public function new( f:A->B->C->D, a:Async<A>, b:Async<B>, c:Async<C>, d:Async<D>){
		this.f = f;
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;	
		_halt = false;	
	}
	
	public function halt(){ _halt = true; }
	public function resume(){ _halt = false; }
	
	public function update(){
		if (!_halt && Bond.allSet(cast [a,b,c])) d.yield(f(a.val, b.val, c.val));
	}
}

typedef BondFriend= {
	var update:Dynamic;
	var f:Dynamic;
}
	
	