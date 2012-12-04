module("math module");

test('add' , function() {
         var add = math.add;
         equal(add(1, 4), 5);
         equal(add(-3, 2), -1);
         equal(add(1, 3, 4), 8, 'passing 3 args');
         equal(add(2), 2, 'just one arg');
         equal(add(), 0, 'no args');

         equal(add(-3, 4), 7);
         equal(add(-3, 4), 7, 'with message');

         ok(true);
         ok(true, 'with message');
         ok(false);
         ok(false, 'with message');
     });
