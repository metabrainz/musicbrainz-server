if (typeof window === 'undefined') {
    global.document = require('jsdom').jsdom();
    global.window = document.defaultView;
    global.navigator = window.navigator;
    window.localStorage = new (require('node-storage-shim'));
    window.sessionStorage = new (require('node-storage-shim'));
}
