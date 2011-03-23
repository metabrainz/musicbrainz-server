/* 
phantom-qunit.js - A simple qunit testrunner for phantomjs.

Summary: MIT License

Copyright 2011  MetaBrainz Foundation
Copyright 2011  Kuno Woudt <kuno@frob.nl>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

var pq = {};

pq.waitFor = function (check, callback) {
    if (check ()) { callback (); return; }
    setTimeout (function () { pq.waitFor (check, callback); }, 20);
};

pq.waitForElement = function (selector, callback) {

    pq.waitFor (
        function () { return jQuery (selector).length; },
        function () { callback (jQuery (selector)) });
};

pq.TAP = function (elem) {

    var failures = 0;

    var $sections = jQuery ('#qunit-tests').children ('li');
    console.log ('1..' + $sections.length);

    $sections.each (function (idx, test) {
        var testno = idx + 1;
        var $section = jQuery (test);
        var $strong = $section.find ('strong');
        var name = $strong.find ('span.module-name').text () + ': ' + $strong.find ('span.test-name').text ();

        var $tests = $section.find ('ol > li');
        console.log ('    1..' + $tests.length);

        var pass = '';
        $tests.each (function (idx, subtest) {
            var testno = idx + 1;
            var $li = jQuery (subtest);
            var message = $li.find ('span.test-message').text ();
            if ($li.hasClass ('pass'))
            {
                console.log ('    ok ' + testno + ' - ' + message);
            }
            else
            {
                console.log ('    not ok ' + testno + ' - ' + message);
                pass = 'not ';
                failures++;
            }
        });

        console.log (pass + 'ok ' + testno + ' - ' + name);
    });

    var $results = jQuery(elem);

    var failed = $results.find ('.failed').text ();

    phantom.exit (parseInt(failed,10) > 0);
};

if (phantom.state.length === 0)
{
    if (phantom.args.length === 1)
    {
        phantom.state = 'qunit';
        phantom.viewportSize = { width: 960, height: 480 };
        phantom.open (phantom.args[0]);
    }
    else
    {
        console.log ('Usage: phantomjs phantom-qunit.js <URL>');
        phantom.exit (-1);
    }
}
else
{
    pq.waitForElement ('#qunit-testresult', pq.TAP);
}

