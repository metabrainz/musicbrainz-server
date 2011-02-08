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

pq.getResults = function (elem) {

    var $results = jQuery(elem);

    var failed = $results.find ('.failed').text ();
    var passed = $results.find ('.passed').text ();
    var total = $results.find ('.total').text ();

    console.log('Failed: ' + failed + ', Passed: '+ passed + ',  Total: '+ total);

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
    pq.waitForElement ('#qunit-testresult', pq.getResults);
}

