module("incr module");

test('increment' , function() {
         var inc = incr.increment;
         equal(inc(1), 2);
         equal(inc(-3), -2);
     });
