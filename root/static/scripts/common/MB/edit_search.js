$(function() {

    cardinalityMap = {
        'id': {
            '=': 1, '!=': 1, '>': 1, '<': 1, 'BETWEEN': 2
        },
        'date': {
            '=': 1, '!=': 1, '>': 1, '<': 1, 'BETWEEN': 2
        },
        'set': {
            '=': 1, '!=': 1 // Not directly true, but it here it means "show one argument control"
        },
        'vote': {
            '=': 1, '!=': 1 // Not directly true, but it here it means "show one argument control"
        },
        'subscription': {
            '=': 1, '!=': 1, 'subscribed': 0
        },
        'link_type': {
            '=': 1
        }
    };

    var conditionCounter = 0;

    $(document).on("change", "#extra-condition select", function() {
        var newCondition = $(this).parent('li');

        var append = newCondition.clone();
        append.find('select').val('');

        newCondition
            .after(append)
            .attr('id', null)
            .addClass('condition');

        newCondition.find('select:first')
            .addClass('field')
            .find('option:first').remove();

        newCondition.find('button.remove').show();

    }).on("click", "ul.conditions li.condition button.remove", function() {
        $(this).parent('li').remove();

    }).on("change", "ul.conditions select.field", function() {
        var val = $(this).val();
        var $replacement = $('#fields .field-' + val).clone();
        if($replacement.length) {
            var $li = $(this).parent('li');
            $li.find('span.field-container span.field').replaceWith($replacement);

            var $field = $(this).parent('li').find('span.field-container span.field');
            $field
                .show()
                .find('select.operator').trigger('change');

            $li.find('span.autocomplete').each(function() {
                MB.Control.EntityAutocomplete({ 'inputs': $(this) });
            });

            $li.find(':input').each(function() {
                addInputNamePrefix($(this));
            });

            conditionCounter++;
        }
        else {
            console.error('There is no field-' + val);
        }

    }).on("change", "ul.conditions select.operator", function() {
        var $field = $(this).parent('span.field');

        var predicate = filteredClassName($field, 'predicate-');
        var cardinality = cardinalityMap[predicate][$(this).val()];

        $field.find('.arg').hide();
        $field.find('.arg:lt(' + cardinality + ')').show();
        $field.find('.arg:first :input:first').focus();
    });

    function prefixedInputName($element) {
        return 'conditions.' + conditionCounter + '.' + $element.attr('name').replace(/conditions\.\d+\./, '');
    }

    function addInputNamePrefix($input) {
        if ($input.attr ('name'))
        {
            $input.attr('name', prefixedInputName($input));
        }
    }

    function filteredClassName($element, prefix) {
        var classList = $element.attr('class').split(/\s+/);
        var ret;
        for (i = 0; i < classList.length; i++) {
            if(classList[i].substring(0, prefix.length) === prefix) {
                ret = classList[i].substring(prefix.length);
                break;
            }
        }

        return ret;
    }

    $('ul.conditions li.condition span.field').show();
    $('ul.conditions li.condition select.operator').trigger('change');
    $('ul.conditions li.condition button.remove').show();

    $('ul.conditions li.condition').each(function() {
        $(this).find(':input').each(function() {
            addInputNamePrefix($(this));
        });
        conditionCounter++;
    });

    $('ul.conditions span.autocomplete').each(function() {
        MB.Control.EntityAutocomplete({ 'inputs': $(this) });
    });

    if ($('#edit-search').length)
    {
        MB.utility.setDefaultAction('#edit-search', '#edit-search-submit button');
    }
});
