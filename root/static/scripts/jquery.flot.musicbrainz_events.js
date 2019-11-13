(function ($) {
    var options = {
        musicbrainzEvents: {
            selectColor: "rgba(170, 0, 0, 1)",
            deselectColor: "rgba(170, 0, 0, 0.20)",
            data: [],
            currentEvent: {},
            enabled: true,
        },
    };

    function changeCurrentEvent(to) {
        this.getOptions().musicbrainzEvents.currentEvent = to;
        this.triggerRedrawOverlay();
    }

    function getEvent(pos, plot) {
        var plotEvent = false;
        var options = plot.getOptions();
        if (options.musicbrainzEvents.enabled) {
            $.each(options.musicbrainzEvents.data, function (index, value) {
                    if (((!options.xaxis.min || value.jsDate > options.xaxis.min) && (!options.xaxis.max || value.jsDate < options.xaxis.max)) &&
                        (plot.p2c({x: value.jsDate}).left > plot.p2c(pos).left - 5 && plot.p2c({x: value.jsDate}).left < plot.p2c(pos).left + 5)) {
                            plotEvent = value;
                    }
                    return !plotEvent;
            });
            return plotEvent;
        } 
        return false;
    }

    function drawCrosshairLine(plot, ctx, x, color) {

        var plotOffset = plot.getPlotOffset();

        x = plot.p2c({x: x}).left;

        if (x > 0) {
            ctx.save();
            ctx.translate(plotOffset.left, plotOffset.top);

            ctx.strokeStyle = color;
            ctx.lineWidth = 2;
            ctx.lineJoin = "round";

            ctx.beginPath();
            ctx.moveTo(x, 0);
            ctx.lineTo(x, plot.height());
            ctx.stroke();
            ctx.restore();
        }
    }

    function init(plot) {
        plot.changeCurrentEvent = changeCurrentEvent;
        plot.getEvent = function (pos) { return getEvent(pos, plot) };

        plot.hooks.drawOverlay.push(function (plot, ctx) {
            var options = plot.getOptions();

            if (options.musicbrainzEvents.enabled) {
                $.each(options.musicbrainzEvents.data, function (index, value) {
                        var color = (value.jsDate == options.musicbrainzEvents.currentEvent.jsDate) ? options.musicbrainzEvents.selectColor : options.musicbrainzEvents.deselectColor;
                        drawCrosshairLine(plot, ctx, value.jsDate, color);
                });
            }
        });
    }

    $.plot.plugins.push({
        init: init,
        options: options,
        name: 'musicbrainzEvents',
        version: '1.0',
    });
}(jQuery));
