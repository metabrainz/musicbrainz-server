(function ($) {
    var options = {
        musicbrainzEvents: {
            selectColor: "rgba(170, 0, 0, 1)",
            deselectColor: "rgba(170, 0, 0, 0.20)",
            data: [],
            currentEvent: {}
        }
    };

    function changeCurrentEvent(to) {
        this.getOptions().musicbrainzEvents.currentEvent = to; 
        this.triggerRedrawOverlay();
    }

    function drawCrosshairLine(plot, ctx, x, color) {

        var plotOffset = plot.getPlotOffset();

        x = plot.p2c({x: x}).left;

        ctx.save();
        ctx.translate(plotOffset.left, plotOffset.top);

        ctx.strokeStyle = color;
        ctx.lineWidth = 1;
        ctx.lineJoin = "round";

        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, plot.height());
        ctx.stroke();
        ctx.restore();
    }

    
    function init(plot) {
        plot.changeCurrentEvent = changeCurrentEvent;

        plot.hooks.drawOverlay.push(function (plot, ctx) {
            var options = plot.getOptions().musicbrainzEvents;

            $.each(options.data, function(index, value) {
                    var color = (value.jsDate == options.currentEvent.jsDate) ? options.selectColor : options.deselectColor;
                    drawCrosshairLine(plot, ctx, value.jsDate, color);
            });
        });
    }
    
    $.plot.plugins.push({
        init: init,
        options: options,
        name: 'musicbrainzEvents',
        version: '1.0'
    });
})(jQuery);
