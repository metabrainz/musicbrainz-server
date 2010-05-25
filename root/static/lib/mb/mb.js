
var mbz = (mbz) ? mbz : {};

mbz.Object = function ()
{
    var self = {};

    var parent = function (name)
    {
        var that = this;
        var method = this[name];
        return function ()
        {
            return method.apply (that, arguments);
        };
    };

    self.parent = parent;

    return self;
};

