
/* temporary mb namespace with functions required by the GuessCase module.
   all of this needs to be refactored away eventually (FIXME). --warp. */

mb = {};
mb.log = {};
mb.log.debug = function () {};
mb.log.enter = function () {};
mb.log.error = function (msg) { MB.utility.exception ('GuessCaseError', msg); };
mb.log.exit = function (ret) { return ret; };
mb.log.info = function () {};
mb.log.isDebugMode = function () { return false; }
mb.log.trace = function () {};

mb.utils = {};

// mb.utils.leadZero = function() {
//     var n = arguments[0];
//     var s = (arguments[1] ? arguments[1] : '0');
//     return (n < 10 ? new String(s)+n : n);
// };

// mb.utils.getInt = function(s) { return parseInt(("0" + s), 10); };
// mb.utils.trim = function(s) {
//     return mb.utils.isNullOrEmpty(s) ? "" : s.replace(/^\s*/, "").replace(/\s*$/, "");
// };

// mb.utils.isArray =       function(o) { return (o instanceof Array    || typeof o == "array"); };
// mb.utils.isBoolean =     function(o) { return (o instanceof Boolean  || typeof o == "boolean"); };
// mb.utils.isFunction =    function(o) { return (o instanceof Function || typeof o == "function"); };
// mb.utils.isNumber =      function(o) { return (o instanceof Number   || typeof o == "number"); };

mb.utils.isString =      function(o) { return (o instanceof String   || typeof o == "string"); };
/*
mb.utils.isUndefined =   function(o) { return ((o == undefined) && (typeof o == "undefined")); };
*/
mb.utils.isNullOrEmpty = function(o) { return (!o || o == ""); };
