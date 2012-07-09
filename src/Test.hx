import async.Promise;

class Test {
    static function main() {
        var p1 = new Promise<Int>();
        var p2 = new Promise<Int>(); 
        var p3 = Promise.when(p1,p2).then(foo);
        p3.error.then(function(d:Dynamic){
            trace(d);
        });
        p1.yield(4);
        p2.yield(2);
        
    }
    public static function foo(x:Int, y:Int){
        trace(x+y);
        throw('what');
        return 'foo';
    }
    
    public static function bar(x:String){
        trace(x+' bar!');
    }

}
