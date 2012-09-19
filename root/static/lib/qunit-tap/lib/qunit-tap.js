/**
 * QUnit-TAP - A TAP Output Producer Plugin for QUnit
 *
 * https://github.com/twada/qunit-tap
 * version: 1.2.1pre
 *
 * Copyright (c) 2010, 2011, 2012 Takuto Wada
 * Dual licensed under the MIT or GPL Version 2 licenses.
 *
 * @param qunitObject QUnit object reference.
 * @param printLikeFunction print-like function for TAP output (assumes line-separator is added by this function for each call).
 * @param options configuration options to customize default behavior.
 */
var qunitTap = function qunitTap(qunitObject, printLikeFunction, options) {
    'use strict';
    var qunitTapVersion = '1.2.1pre',
        multipleLoggingCallbacksSupported,
        qu = qunitObject;

    if (!qu) {
        throw new Error('should pass QUnit object reference. Please check QUnit\'s "require" path if you are using Node.js (or any CommonJS env).');
    }
    if (typeof printLikeFunction !== 'function') {
        throw new Error('should pass print-like function');
    }
    if (typeof qu.tap !== 'undefined') {
        return;
    }

    // borrowed from qunit.js
    var extend = function (a, b) {
        var prop;
        for (prop in b) {
            if (b.hasOwnProperty(prop)) {
                if (typeof b[prop] === 'undefined') {
                    delete a[prop];
                } else {
                    a[prop] = b[prop];
                }
            }
        }
        return a;
    };

    // option deprecation and fallback function
    var deprecateOption = function (optionName, fallback) {
        if (!options || typeof options !== 'object') {
            return;
        }
        if (typeof options[optionName] === 'undefined') {
            return;
        }
        printLikeFunction('# WARNING: Option "' + optionName + '" is deprecated and will be removed in future version.');
        fallback(options[optionName]);
    };

    // using QUnit.tap as namespace.
    qu.tap = {};
    qu.tap.config = extend(
        {
            initialCount: 1,
            noPlan: false,
            showModuleNameOnFailure: true,
            showTestNameOnFailure: true,
            showExpectationOnFailure: true,
            showSourceOnFailure: true
        },
        options
    );
    deprecateOption('count', function (count) {
        qu.tap.config.initialCount = (count + 1);
    });
    deprecateOption('showDetailsOnFailure', function (flag) {
        qu.tap.config.showModuleNameOnFailure = flag;
        qu.tap.config.showTestNameOnFailure = flag;
        qu.tap.config.showExpectationOnFailure = flag;
        qu.tap.config.showSourceOnFailure = flag;
    });
    qu.tap.puts = printLikeFunction;
    qu.tap.VERSION = qunitTapVersion;
    qu.tap.count = qu.tap.config.initialCount - 1;

    // detect QUnit's multipleCallbacks feature. see jquery/qunit@34f6bc1
    multipleLoggingCallbacksSupported =
        (typeof qu.config !== 'undefined' &&
         typeof qu.config.log !== 'undefined' &&
         typeof qu.config.done !== 'undefined' &&
         typeof qu.config.moduleStart !== 'undefined' &&
         typeof qu.config.testStart !== 'undefined');

    var isPassed = function (details) {
        return !!details.result;
    };

    var isFailed = function (details) {
        return !details.result;
    };

    // borrowed from prototype.js
    // not required since QUnit.log receives raw data (details). see jquery/qunit@c2cde34
    var stripTags = function (str) {
        if (!str) {
            return str;
        }
        return str.replace(/<\w+(\s+("[^"]*"|'[^']*'|[^>])+)?>|<\/\w+>/gi, '');
    };

    var escapeLineEndings = function (str) {
        return str.replace(/(\r?\n)/g, '$&# ');
    };

    var ltrim = function (str) {
        return str.replace(/^\s+/, '');
    };

    var quote = function (obj) {
        return '\'' + obj + '\'';
    };

    var noop = function (obj) {
        return obj;
    };

    var appendTo = function (desc, detailValue, fieldName, configName, formatter) {
        if (qu.tap.config[configName] && typeof detailValue !== 'undefined') {
            desc.push(fieldName + ': ' + formatter(detailValue));
        }
    };

    var formatDetails = function (details) {
        if (isPassed(details)) {
            return details.message;
        }
        var desc = [];
        if (details.message) {
            desc.push(details.message);
        }
        appendTo(desc, details.expected, 'expected', 'showExpectationOnFailure', quote);
        appendTo(desc, details.actual, 'got', 'showExpectationOnFailure', quote);
        appendTo(desc, details.name, 'test', 'showTestNameOnFailure', noop);
        appendTo(desc, details.module, 'module', 'showModuleNameOnFailure', noop);
        appendTo(desc, details.source, 'source', 'showSourceOnFailure', ltrim);
        return desc.join(', ');
    };

    var formatTestLine = function (testLine, rest) {
        if (!rest) {
            return testLine;
        }
        return testLine + ' - ' + escapeLineEndings(rest);
    };

    qu.tap.explain = function explain (obj) {
        if (typeof qu.jsDump !== 'undefined' && typeof qu.jsDump.parse === 'function') {
            return qu.jsDump.parse(obj);
        } else {
            return obj;
        }
    };

    qu.tap.note = function note (obj) {
        qu.tap.puts(escapeLineEndings('# ' + obj));
    };

    qu.tap.diag = function diag (obj) {
        qu.tap.note(obj);
        return false;
    };

    qu.tap.moduleStart = function (arg) {
        var name = (typeof arg === 'string') ? arg : arg.name;
        qu.tap.note('module: ' + name);
    };

    qu.tap.testStart = function (arg) {
        var name = (typeof arg === 'string') ? arg : arg.name;
        qu.tap.note('test: ' + name);
    };

    qu.tap.log = function () {
        var details, testLine = '';
        qu.tap.count += 1;
        switch (arguments.length) {
        case 1:  // details
            details = arguments[0];
            break;
        case 2:  // result, message(with tags)
            details = {result: arguments[0], message: stripTags(arguments[1])};
            break;
        case 3:  // result, message, details
            details = arguments[2];
            break;
        default:
            throw new Error('QUnit-TAP does not support QUnit#log arguments like this.');
        }
        if (isFailed(details)) {
            testLine += 'not ';
        }
        testLine += ('ok ' + qu.tap.count);
        qu.tap.puts(formatTestLine(testLine, formatDetails(details)));
    };

    // prop in arg: failed,passed,total,runtime
    qu.tap.done = function (arg) {
        if (!qu.tap.config.noPlan) {
            return;
        }
        qu.tap.puts(qu.tap.config.initialCount + '..' + qu.tap.count);
    };

    var addListener = function (target, name, listener) {
        var originalLoggingCallback = target[name];
        if (multipleLoggingCallbacksSupported) {
            originalLoggingCallback(listener);
        } else if (typeof originalLoggingCallback === 'function') {
            // add listener, not replacing former ones.
            target[name] = function () {
                var args = Array.prototype.slice.apply(arguments);
                originalLoggingCallback.apply(target, args);
                listener.apply(target, args);
            };
        }
    };
    addListener(qu, 'moduleStart', qu.tap.moduleStart);
    addListener(qu, 'testStart', qu.tap.testStart);
    addListener(qu, 'log', qu.tap.log);
    addListener(qu, 'done', qu.tap.done);
};

/*global exports:false*/
if (typeof exports !== 'undefined') {
    // exports qunitTap function to CommonJS world
    exports.qunitTap = qunitTap;
}
