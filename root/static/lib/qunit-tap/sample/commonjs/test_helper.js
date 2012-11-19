var tryRequireThese = function() {
    var i, args = Array.prototype.slice.apply(arguments);
    for(i = 0; i < args.length; i += 1) {
        try {
            return require(args[i]);
        } catch(e) {
            // ignore
        }
    }
    throw new Error("cannot find module: " + args);
},
    QUnit = require("../../test/compatibility/stable/qunit"),
    qunitTap = require("../../lib/qunit-tap").qunitTap,
    sys = tryRequireThese("util", "sys", "system"),
    puts = (typeof sys.puts === 'function') ? sys.puts : sys.print;

qunitTap(QUnit, puts, {noPlan: true});

QUnit.init();
QUnit.config.updateRate = 0;

exports.QUnit = QUnit;
