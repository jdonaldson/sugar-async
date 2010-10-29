Sugar-Async
========

Async is an asynchronous event management system.  It combines functionality of Future<T> types in addition to Monadic lift operations in order to provide a procedural way to manage complex asynchronous events.  To get started, it's necessary to import the Async class, and it is highly recommended that it is imported via *using* as well:
	
	import org.sugar.Async;
	using org.sugar.Async;


## Async Variables ##


The core functionality of the Aysnc class lies within the Async<T> instance.  Async instances must be initialized with a type parameter:
	
	var a = new Async<Int>();
	
## Async wait Functions ##


Once created, it is possible to use Async variables inside special static Async functions, called *wait* functions such as `Async.wait2`.  These wait functions take a function argument, as well as one or more Async argument values.  When imported via *using*, the wait functions become pseudo-fields of *another function*.  So, for instance, if you had the following function:

`public static function foo(x:Int){
	return x + 1;
}`

It is possible to make the following function call, using the previously created asynchronous variable:

	foo.wait(a);

The function foo took a single Int argument, but through the magic of *using*, we can alter the functionality of foo so that it accepts Async variables.  With the wait function used in this way, the argument arity is preserved.  If the original foo function accepted Strings, it would be necessary to use Async<String>, and so forth. 
	
It is necessary to pay special attention to the original function arity.  If the function foo accepted two arguments, then it is necessary to use foo.wait2.  If it took three, it would be foo.wait3, and so forth.

Finally, it is possible to add waited functions directly to the Async variable by using:

	a.addWait(foo);

The functionality will be identical, but it is not possible to add multi-argument waited functions this way.

## "Faking" an Async Value ##

In many cases, it may be nice to use `Async.wait#()` on a function where one or more arguments are already known.  In this case, you can use the function `Async.toAsync();`.  If the Async class is imported via *using*, this function becomes a member of *every* variable instance.  So for instance, `2.toAsync()` will construct an Async instance that has already yielded the integer 2.  Consider the following function:

	public static function bar(x:Int,y:Int){
		return x + y;
	}

It is possible to specify a wait() function as follows:


	var a = new Async<Int>(); // normal Async instance.
	bar.wait2(a,2.toAsync()); // Async.wait call with second "dummy" Async instance of 2


### Yielding to *wait()*-ed Functions ###


Once the function is "waited", it will get triggered whenever the relevant Async variable gets *yielded*.  For the Async variable `a`, we could yield 10 by:

	a.yield(10);

Once yielded, any functions that are waiting on `a` will trigger with `a`'s value.  Waited functions that rely on two or more asynchronous variables will only trigger once *all* Async variables have yielded.  Furthermore, it will also trigger whenever the yielded variables change (for instance, calling `a.yield(11)` will once more trigger `foo()` with the new argument value).

### Handling Return values of *wait()*-ed Functions ###

Any functions called with Async.wait#()  will have a typed Async return value.  This value can be treated as any other Async value.  In this way, it is possible to write asynchronous code in a procedural style:

	var b = foo.wait(a);
	var c = foo.wait(b);
	var d = foo.wait(c);

In this case, `b` gets the result of `foo.wait(a)`.  Once `a` yields, `b` will yield the result of the foo function on `a`'s value.  This will in turn yield the result of the foo function on `b`'s value to `c`, and so forth.  It is possible to set up complex systems of multi-argument waited functions in this manner.

### Managing Yield Functionality ###

It is possible to remove waited functions by calling:

	a.removeWait(foo);

This will remove any waited functions added to the instance via Async.wait() functions, or through instance specific addWait() functions.

It is possible for yielded functions like foo to determine if they are in the middle of a yield operation.  By calling Async.yieldingFor(foo) (on itself), it is possible to determine if Async is in the process of yielding to the foo function.  Once foo knows that it takes part in a yield process, it can communicate to Async by throwing a special `Yield` enum:


	public static function foo(x:Int){
		if (Async.yieldingFor(foo)) throw Yield.REMOVEME;
		return x + 1;
	}

This allows the yielded function to remove itself from any further updates by Async.  The various Yield states it can throw include:

*	Yield.REMOVEME :  Removes the function from any further yield processes.
*	Yield.STOP : Halts the yield process for any other waited functions.
*	YIELD.REDOALL : Repeats the yield process for all waited functions.	

Any other thrown errors are not captured.


### Relationships to Future<T> and Monadic Lift ###

In many ways, Async<T> instances are similar to [Future<T>](http://download.oracle.com/javase/1.5.0/docs/api/java/util/concurrent/Future.html) instances.  However, Future<T> relies on a *get()* function that suspends execution in the current block until the Future<T> value becomes available.  This isn't possible on many of the platforms/vm's that haXe targets, so it's not available here.

Likewise, [Monadic Lifts](http://www.haskell.org/ghc/docs/6.12.2/html/libraries/base-4.2.0.1/Control-Monad.html#v%3AliftM) work by *promoting* simple functions into monadic functions, which is similar to what Async is doing with `wait()`.  Unfortunately, haXe does not allow for operator overloading.  So, it's impossible to use monadic types with basic math operators.  Therefore, Async's `wait()` function works much differently, and does not get all the benefits of monadic control.  

The Async class combines the advantages of both patterns in order to get around platform limitations.  With the *using* keyword, it's very easy to express and create asynchronous functions using existing imperative functions as a foundation.  Since the `wait()` function is parameterized, it mimics the typing of the original function, and in doing so is itself type safe.


