(function(MB) {
    String.prototype.template = function (o) {
        return this.replace(/#{([^{}]*)}/g,
            function (a, b) {
                var r = o[b];
                return typeof r === 'string' || typeof r === 'number' ?
                    r : a;
            }
        );
    };

    var newRowTemplate = (
        '<li class="release-label">' +
            '<input type="checkbox" name="#{field}.removed" class="remove" /> ' +
            '<input type="hidden" name="#{field}.label_id" />' +
            '<input class="label-name" />' +
            ' &ndash; ' +
            '<input class="catalog-number" name="#{field}.catalog_number" size="8" />' +
        '</li>'
    );

    function createOverlay(input) {
        var text = input.val() ? MB.html.escape(MB.utility.displayedValue(input))
                               : MB.text.UnknownPlaceholder;
        var display = $('<span>#{overlay}</span>'.template({ overlay: text }))
            .toggleClass('unknown', input.val());

        var overlay = new MB.Control.Overlay(display);
        overlay.draw(input);
        return overlay;
    }

    $.extend(MB, {
        newRow: function(index) {
            var row = newRowTemplate.template({ field: 'edit-release.labels.' + index });
            return $(row);
        },
        setupRow: function(row) {
            row = $(row);

            var removeToggle = new MB.Control.ToggleButton(MB.url.ReleaseEditor.removeImages);
            removeToggle.draw(row.find('input.remove'));

            var nameInput = row.find('input.label-name');
            var lookup = new MB.Control.EntityLookup('label', {
                defaultValue: nameInput.val(),
                selection: function(result) {
                    nameOverlay.overlay.text(result.name).removeClass('unknown');
                    nameOverlay.showOverlay();
                }
            });
            row.find('input.label-name').replaceWith(lookup.query);

            var nameOverlay = createOverlay(lookup.query);
            var catOverlay  = createOverlay(row.find('input.catalog-number'));
        }
    });
})(MB);