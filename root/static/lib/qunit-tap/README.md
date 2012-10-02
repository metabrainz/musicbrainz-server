QUnit-TAP - a TAP Output Producer Plugin for QUnit
================================


NEWS
---------------------------------------
* (2012/09/13) Release 1.2.0: Reorganize configuration options. Some options are marked as deprecated (with safe fallbacks). Changed output message format a little.
* (2012/09/03) Note for CommonJS users (includes Node.js users): Now 'qunitjs' npm module dependencies in package.json is moved to devDependencies since qunit-tap does not depend on 'qunitjs' module directly. So you should resolve 'qunitjs' on your own.
* (2012/03/18) Note for CommonJS users (includes Node.js users): QUnit's module export path has changed since QUnit 1.3.0, so you should fix 'require' path to get QUnit Object from 'require' module. (for details, see [my fix](https://github.com/twada/qunit-tap/commit/4799002ae1b9d8a1721da448b98f3dd0d89159d6).)


DESCRIPTION
---------------------------------------
QUnit-TAP is a simple plugin for [QUnit](http://qunitjs.com) to produce [TAP](http://testanything.org/) output, to run tests on CLI.

With QUnit-TAP you can run your QUnit test scripts on your terminal, and you can use TAP Consumers like [prove](http://perldoc.perl.org/prove.html) for test automation.

QUnit-TAP runs under headless browsers like [phantomjs](http://code.google.com/p/phantomjs/), command-line js environments (like [SpiderMonkey](https://developer.mozilla.org/en/SpiderMonkey) or [Rhino](https://developer.mozilla.org/en/Rhino)), and [CommonJS](http://commonjs.org/) environments (like [node.js](http://nodejs.org/) or [narwhal](http://narwhaljs.org/)), and of cource, runs on your real browser too.


DOWNLOAD
---------------------------------------
* Just download [qunit-tap.js](http://github.com/twada/qunit-tap/raw/master/lib/qunit-tap.js)
* or download archives from [qunit-tap tags](https://github.com/twada/qunit-tap/tags)
* or `git clone git://github.com/twada/qunit-tap.git`
* or `npm install qunit-tap` if you use npm.

You can use QUnit-TAP,

* as a single file, copy lib/qunit-tap.js to anywhere you like.
* as git submodule.
* as a node.js package (via npm).


USAGE
---------------------------------------
Three steps to use QUnit-TAP.

1. load/require qunit.js
2. load/require qunit-tap.js
3. Call `qunitTap` function with two or three arguments. The first argument is QUnit reference, the second is print-like function for TAP output. And the third argument is object to customize default behavior. (Note that the first and second argument is mandatory, and the third argument is optional.)

### usage example 1 : embed QUnit-TAP in your HTML (e.g. to run with PhantomJS)
    <script type="text/javascript" src="path/to/qunit.js"></script>
    <script type="text/javascript" src="path/to/qunit-tap.js"></script>
    <script>
      qunitTap(QUnit, function() { console.log.apply(console, arguments); }, {noPlan: true});
    </script>
    <script type="text/javascript" src="path/to/your_test.js"></script>
    <script type="text/javascript" src="path/to/your_test2.js"></script>

### usage example 2 : use QUnit-TAP with Node.js

First, declare qunitjs and qunit-tap as devDependencies in your package.json, then run `npm install`.

    {
        . . .
        "devDependencies": {
            "qunitjs": "1.10.0",
            "qunit-tap": "1.2.0",
            . . .
        },
        . . .
    }

Next, require and configure them.

    var util = require("util"),
        QUnit = require('qunitjs'),
        qunitTap = require('qunit-tap').qunitTap;
    qunitTap(QUnit, util.puts, { noPlan: true });
    QUnit.init();
    QUnit.config.updateRate = 0;

### usage example 3 : use QUnit-TAP with Rhino/SpiderMonkey
    load("path/to/qunit.js");
    load("path/to/qunit-tap.js");
    
    // enable TAP output
    qunitTap(QUnit, print);  //NOTE: 'print' is Rhino/SpiderMonkey's built-in function
    
    // or customize default behavior
    // qunitTap(QUnit, print, {noPlan: true, showExpectationOnFailure: true, showSourceOnFailure: false});
    
    // configure QUnit to run under non-browser env.
    QUnit.init();
    QUnit.config.updateRate = 0;
    
    load("path/to/your_test.js");
    load("path/to/your_test2.js");
    
    QUnit.start();


CONFIGURATION OPTIONS
---------------------------------------
QUnit-TAP is already configured with reasonable default. To customize, `qunitTap` function takes third optional argument as options object to override default behavior. Customization props are,

* `noPlan` : If true, print test plan line at the bottom after all the test points have run. Inspired by Perl's "no_plan" feature. Default is false.
* `initialCount` : Initial number for TAP plan line. Default is 1.
* `showExpectationOnFailure` : If true, show 'expected' and 'actual' on failure. Default is true.
* `showTestNameOnFailure` : If true, show test name on failure (supported since QUnit 1.10.0). Default is true.
* `showModuleNameOnFailure` : If true, show module name on failure (supported since QUnit 1.10.0). Default is true.
* `showSourceOnFailure` : If true, show source file name and line number on failure if stack trace is available. Default is true.


TAP OUTPUT EXAMPLE
---------------------------------------
QUnit-TAP produces output based on [TAP](http://testanything.org/) specification.

    # module: math module
    # test: add
    ok 1
    ok 2
    ok 3 - passing 3 args
    ok 4 - just one arg
    ok 5 - no args
    not ok 6 - expected: '7', got: '1', test: add, module: math module
    not ok 7 - with message, expected: '7', got: '1', test: add, module: math module
    ok 8
    ok 9 - with message
    not ok 10 - test: add, module: math module
    not ok 11 - with message, test: add, module: math module
    # module: incr module
    # test: increment
    ok 12
    ok 13
    # module: TAP spec compliance
    # test: Diagnostic lines
    ok 14 - with\r
    # multiline
    # message
    not ok 15 - with\r
    # multiline
    # message, expected: 'foo\r
    # bar', got: 'foo
    # bar', test: Diagnostic lines, module: TAP spec compliance
    not ok 16 - with\r
    # multiline
    # message, expected: 'foo
    # bar', got: 'foo\r
    # bar', test: Diagnostic lines, module: TAP spec compliance
    1..16

Configuration for this example is,

    qunitTap(QUnit, function() { console.log.apply(console, arguments); }, {
      noPlan: true,
      showSourceOnFailure: false
    });

Explicitly, it's same as,

    qunitTap(QUnit, function() { console.log.apply(console, arguments); }, {
      noPlan: true,
      initialCount: 1,
      showExpectationOnFailure: true,
      showTestNameOnFailure: true,
      showModuleNameOnFailure: true,
      showSourceOnFailure: false
    });


RUNNING EXAMPLES
---------------------------------------
### prepare
    $ git clone git://github.com/twada/qunit-tap.git
    $ cd qunit-tap


### to run with PhantomJS

    # assume you have built and installed phantomjs
    $ cd sample/js/
    $ ./phantomjs_test.sh

    # with prove
    $ prove phantomjs_test.sh

for details, see [phantomjs_test.sh](http://github.com/twada/qunit-tap/tree/master/sample/js/phantomjs_test.sh)


### to run with Rhino/SpiderMonkey

    # assume you are using rhino
    $ cd sample/js/
    $ rhino run_tests.js

for details, see [sample/js/](http://github.com/twada/qunit-tap/tree/master/sample/js/)


### to run under CommonJS environment (includes Node.js)

    # assume you are using node.js
    $ cd sample/commonjs/
    $ node test/math_test.js
    $ node test/incr_test.js

    # with prove
    $ prove --exec=/usr/local/bin/node test/*.js

for details, see [sample/commonjs/](http://github.com/twada/qunit-tap/tree/master/sample/commonjs/)


TROUBLE SHOOTING
---------------------------------------
If you are using Node.js (or any CommonJS env) and have an error like this,

    $ node test/incr_test.js 
    
    node.js:201
            throw e; // process.nextTick error, or 'error' event on first tick
                  ^
    Error: should pass QUnit object reference. Please check QUnit's "require" path if you are using Node.js (or any CommonJS env).
        at qunitTap (/path/to/qunit-tap.js:22:15)
        at Object.<anonymous> (/path/to/using_qunit_via_require_module.js)
        ....
    $

Check QUnit's version you are using. QUnit's module export path has changed since QUnit 1.3.0, so you should fix 'require' path to get QUnit Object from 'require' module. 

      var util = require("util"),
    -     QUnit = require('./path/to/qunit').QUnit,
    +     QUnit = require('./path/to/qunit'),
          qunitTap = require('qunit-tap').qunitTap;
      qunitTap(QUnit, util.puts, { noPlan: true });
      QUnit.init();
      QUnit.config.updateRate = 0;

Official QUnit npm module is available since QUnit version 1.9.0, so the best way to get QUnit Object is just use 'qunitjs' module.

      var util = require("util"),
    -     QUnit = require('./path/to/qunit').QUnit,
    +     QUnit = require('qunitjs'),
          qunitTap = require('qunit-tap').qunitTap;
      qunitTap(QUnit, util.puts, { noPlan: true });
      QUnit.init();
      QUnit.config.updateRate = 0;

for details, see [my fix](https://github.com/twada/qunit-tap/commit/4799002ae1b9d8a1721da448b98f3dd0d89159d6).


TESTED ENVIRONMENTS
---------------------------------------
* [phantomjs](http://code.google.com/p/phantomjs/)
* [node.js](http://nodejs.org/)
* [SpiderMonkey](https://developer.mozilla.org/en/SpiderMonkey)
* [Rhino](https://developer.mozilla.org/en/Rhino)
* [narwhal](http://narwhaljs.org/)


AUTHOR
---------------------------------------
* [Takuto Wada](http://github.com/twada)


CONTRIBUTORS
---------------------------------------
* [Nikita Vasilyev](http://github.com/NV)
* [Hiroki Kondo](http://github.com/kompiro)
* [Keiji Yoshimi](http://github.com/walf443)
* [Hiroki Honda](http://github.com/Cside)


LICENSE
---------------------------------------
Dual licensed under the MIT and GPLv2 licenses.
