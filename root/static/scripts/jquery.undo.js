(function($) {

$.fn.extend({
    registerUndo: function(desc, undo) {
        $(document).trigger('undoManager.new', [ desc, undo, this ]);
    },
    undoInterface: function() {
        var rec = this;
        $(document).bind('undoManager.new', function(e, desc, undo, source) {
            // Handle the creation of new undo tasks
            link = $('<a>').attr('href', '#').click(function(ev) {
                ev.preventDefault();
                undo();
                rec.html("&nbsp;");
                source.focus();
            }).text('Undo?');

            source.glow();
            rec.empty().append(desc).append(' ').append(link).glow();
        });
    }
});

})(jQuery);
