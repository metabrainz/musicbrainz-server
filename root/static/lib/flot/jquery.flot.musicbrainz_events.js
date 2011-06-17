(function ($) {
    var options = {
        musicbrainz_events: {
            select_color: "rgba(170, 0, 0, 0.80)",
            deselect_color: "rgba(170, 170, 170, 0.80)",
            data: [],
            currentEvent: null
        }
    };

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

        plot.hooks.drawOverlay.push(function (plot, ctx) {
            var options = plot.getOptions().musicbrainz_events;

	    $.each(options.data, function(index, value) {
	            var color = (value.jsDate == options.currentEvent) ? options.select_color : options.deselect_color;
		    drawCrosshairLine(plot, ctx, value.jsDate, color);
	    });
        });
    }
    
    $.plot.plugins.push({
        init: init,
        options: options,
        name: 'musicbrainz_events',
        version: '1.0'
    });
})(jQuery);
