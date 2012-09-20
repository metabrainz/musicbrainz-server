if (typeof incr === 'undefined') { incr = {}; }

incr.increment = function(val) {
    var add = math.add;
    return add(val, 1);
};
