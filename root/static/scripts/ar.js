$(function() {

    function incrementLastPart(s) {
        var parts = s.split('.');
        parts[parts.length-1] = 1 + parseInt(parts[parts.length-1], 10);
        return parts.join('.');
    }

    function updateLinkType(select) {
        var id = select.options[select.selectedIndex].value;
        var message;
        var attrs;
        if (id) {
            var selected = typeInfo[id];
            if (selected.descr) {
                message = selected.descr;
            }
            else {
                message = MusicBrainz.text.PleaseSelectARSubtype;
            }
            attrs = selected.attrs;
        }
        else {
            message = MusicBrainz.text.PleaseSelectARType;
            attrs = {};
        }
        $('#type_descr').html(message);
        $('div.ar-attr').each(function() {
            var id = this.id.substr(13);
            var attrDiv = $(this);
            if (attrs[id]) {
                attrDiv.show();
                var attr = attrs[id];
                var selects = attrDiv.find('.selects');
                if (selects.length > 0) {
                    if (attr[1] == 1) {
                        selects.remove('div:not(:first)');
                        attrDiv.find('input:button').hide();
                    }
                    else {
                        attrDiv.find('input:button').show();
                    }
                }
            }
            else {
                attrDiv.hide();
            }
        });
    }

    function filterSelect($filter, direction) {
        var i, select = $filter.siblings('select')[0];
        var filterValue = $filter.val().toLowerCase();
        if (!direction) {
            i = 0;
            direction = 1;
        }
        else {
            i = select.selectedIndex + direction;
        }
        while (i >= 0 && i < select.options.length) {
            if (select.options[i].text.toLowerCase().indexOf(filterValue) != -1) {
                select.selectedIndex = i;
                return;
            }
            i += direction;
        }
    }

    $('div.ar-attr .selects').each(function() {
        var selects = $(this);
        var btn = $('<input type="button" value="' + MusicBrainz.text.AddAnother + '" />');
        btn.click(function() {
            var lastDiv = selects.find('div:last');
            var lastSelectName = lastDiv.find('select').attr('name');
            var newSelectName = incrementLastPart(lastSelectName);
            var newDiv = lastDiv.clone();
            var newSelect = newDiv.find('select');
            newSelect.attr('name', newSelectName);
            newSelect.attr('id', 'id-' + newSelectName);
            newSelect.val('');
            selects.append(newDiv);
        });
        selects.after(btn);
        selects.find('div').each(function() {
            $(this).append(' ')
                .append('<a href="#" class="selectFilterPrev">&#9668;</a>')
                .append('<input type="text" size="7" class="selectFilter">')
                .append('<a href="#" class="selectFilterNext">&#9658;</a>');
        });
    });

    $('a.selectFilterPrev').live('click', function() {
        var $input = $(this).siblings('input');
        $input.focus();
        filterSelect($input, -1);
        return false;
    });
    $('a.selectFilterNext').live('click', function() {
        var $input = $(this).siblings('input');
        $input.focus();
        filterSelect($input, 1);
        return false;
    });
    $('input.selectFilter').live('keyup', function() {
        filterSelect($(this), 0);
    });

    var linkTypeSelect = $("select[id='id-ar.link_type_id']");
    linkTypeSelect.change(function() { updateLinkType(this) });
    updateLinkType(linkTypeSelect[0]);

});
