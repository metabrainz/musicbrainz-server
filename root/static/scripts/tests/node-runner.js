require('babel-core/register');

if (typeof window === 'undefined') {
    global.document = require('jsdom').jsdom();
    global.window = document.defaultView;
    global.navigator = window.navigator;
    window.localStorage = new (require('node-storage-shim'));
    window.sessionStorage = new (require('node-storage-shim'));
}

var rowCount = 0;
var timeout;

require('tape').createStream().on('data', function (row) {
    console.log(row.replace(/\n$/, ''));

    var lastKnownRow = ++rowCount;

    clearTimeout(timeout);

    timeout = setTimeout(function () {
        if (rowCount === lastKnownRow) {
            process.exit(0);
        }
    }, 3000);
});

require('./index');
