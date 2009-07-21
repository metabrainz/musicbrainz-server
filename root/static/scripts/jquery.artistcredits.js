/** Shit still to do:
 *
 * If there is a single artist in the artist credit, we should
 * just show a jQuery.autocomplete field, and a button for the 
 * full editor
 *
 * Sorting
 *
 */

jQuery.artistcredits = function(container)
{
    var $container = $(container);
    var field = $container.attr('id');

    var currentCredits = $('div.credit', container);
    var counter = currentCredits.length - 1;

    // Table for the artist credit editor
    var $tbody = $('<tbody>')
    var $tbl = $('<table>').addClass('credits').append(
        $('<thead>').append(
            $('<tr>')
                .append($('<th>').addClass('artist').text('Artist'))
                .append($('<th>').addClass('name').text('Display Name'))
                .append($('<th>').text('Join Phrase'))))
        .append($tbody);

    // Replace the current artist credits with the editor
    var $credits = $('div.credits', $container).hide().empty().append($tbl);

    // Load current credits into the artist credit editor
    currentCredits.each(function(i, oldRow) {
        id = $('input.id', oldRow);
        name = $('input.name', oldRow);
        join = $('input.join', oldRow);
        gid = $('input.gid', oldRow).val();
        row = createRow(id, name, join, {name:name.val(), gid:gid}).appendTo($tbody);
    });
    toggleRemove();

    // Add a new blank row to add extra artists
    var $createRow = $('<tr>').appendTo($tbody).addClass('add-new');
    cell = $('<td>').attr('colspan', 3).appendTo($createRow).append('Add another artist: ');

    // Setup the new artist lookup field
    var $newArtistLookup = $('<input>').appendTo(cell).autocomplete()
        .select(function(e, result) {
            // Try and auto-fill-in the previous join phrase
            var last = $('input.join:last', $tbody);
            if (last.val().length == 0)
            {
                last.val(", ").registerUndo("Automatically added ', ' as a joinphrase", function() {
                    last.val("");
                });
            }

            // Create a new row
            newRow = createNewRow(result).insertBefore($createRow);
            $newArtistLookup.reset();
            $('input.name', newRow).focus();

            updatePreview();
            toggleRemove();
        });

    // Build the preview span & toggle editor button
    var $preview = $('<span>').html($('p.preview', $container).html());
    var $showEditor = $('<input type="checkbox">').appendTo($('p.preview', $container).empty())
        .toggleButton()
        .on(function() { $credits.show() })
        .off(function() { $credits.hide() });

    $('p.preview').append(' ').append($preview);

    // Bind events to update the preview
    $('input.name', $tbody).live('keyup', updatePreview);
    $('input.join', $tbody).live('keyup', updatePreview);

    function updatePreview()
    {
        var previewText = "";
        $('tr', $tbody).each(function(i, credit) {
            if ($('input.id', this).length == 0) return;

            join = $('input.join', credit);
            name = $('input.name', credit);
            previewText += "<a>" + name.val() + "</a>";
            if (join.length) previewText += join.val();
        });
        $preview.html(previewText);
    };

    function deleteButton(button, row)
    {
        $(button).imageButton('/static/images/release_editor/remove-off.png', {
                disabled: '/static/images/release_editor/remove-disabled.png'
            }).click(function(e) {
                e.preventDefault();
                row.remove();
                updatePreview()
                toggleRemove();
            }).addClass('remove');
    }

    function toggleRemove() {
        buttons = $('tr button.remove', $tbody);
        if (buttons.length == 1)
            buttons.disable();
        else
            buttons.enable();
    }

    function createRow(id, name, join, ent)
    {
        row = $('<tr>');
        artistCell = $('<td>').appendTo(row);
        nameCell = $('<td>').appendTo(row);
        joinCell = $('<td>').appendTo(row);

        id.addClass('id').appendTo(artistCell).entitySelector({ initial_object: ent })
            .select(function(e, result) {
                oldName = name.val();
                if (result.name != oldName)
                {
                    name.registerUndo("Changed display name from " + oldName + " to " + result.name, function() {
                        name.val(oldName);
                    });
                    name.val(result.name);
                }
            });
        name.addClass('name').appendTo(nameCell);
        join.addClass('join').appendTo(joinCell);

        del = $('<button>').prependTo(artistCell);
        deleteButton(del, row);

        return row;
    };

    function createNewRow(result)
    {
        prefix = field + '.names.' + (counter++) + '.';
        id = $('<input type="hidden">').attr('name', prefix + 'artist_id').val(result.id ? result.id : '').appendTo(artistCell);
        name = $('<input>').attr('name', prefix + 'name').val(result.name);
        join = $('<input>').attr('name', prefix + 'join_phrase');
        return createRow(id, name, join, result);
    }
};
