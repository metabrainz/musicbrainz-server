$(function() {

    cardinalityMap = {
        'id': {
            '=': 1, '>': 1, '<': 1, 'BETWEEN': 2
        }
    };

    var conditionCounter = 0;


    $('#extra-condition select').live('change', function() {
        var container = $(this).parent('li');
        container.after(container.clone());
        container.attr('id', null);
        container.find('select').addClass('field').find('option:first').remove();
        container.find('select').trigger('change');
    })

    $('ul.conditions select.field').live('change', function() {
        var val = $(this).val();
        var $replacement = $('#fields .field-' + val).clone();
        if($replacement.length) {
            $(this).parent('li').find('span.field-container span.field').replaceWith($replacement);

            var $field = $(this).parent('li').find('span.field-container span.field');
            $field
                .show()
                .find('select.operator').trigger('change');

            conditionCounter++;
            $field.find(':input').each(function() {
                $input = $(this);
                $input.attr('name', 'conditions.' + conditionCounter + '.' + $input.attr('name'));
            });
        }
    });

    $('ul.conditions select.operator').live('change', function() {
        var $field = $(this).parent('span.field');

        var predicate = filteredClassName($field, 'predicate');
        var cardinality = cardinalityMap[predicate][$(this).val()];

        $field.find('.arg').hide();
        $field.find('.arg:lt(' + cardinality + ')').show();
        $field.find('.arg:first :input:first').focus();
    });

    function filteredClassName($element, prefix) {
        var classList = $element.attr('class').split(/\s+/);
        var ret;
        for (i = 0; i < classList.length; i++) {
            if(classList[i].substring(0, prefix.length) === prefix) {
                ret = classList[i].substring(10);
                break;
            }
        }

        return ret;
    }

});
