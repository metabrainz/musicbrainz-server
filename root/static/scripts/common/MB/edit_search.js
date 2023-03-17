import $ from 'jquery';

import MB from '../MB.js';

$(function () {
  /* eslint-disable sort-keys */
  const cardinalityMap = {
    id: {
      '=': 1, '!=': 1, '>': 1, '<': 1, 'BETWEEN': 2,
    },
    date: {
      '=': 1, '!=': 1, '>': 1, '<': 1, 'BETWEEN': 2,
    },
    set: {
      // Not directly true, but it here it means "show one argument control"
      '=': 1, '!=': 1,
    },
    edit_note_content: {
      'includes': 1,
      'not-includes': 1,
    },
    edit_subscription: {
      subscribed: 0,
      not_subscribed: 0,
    },
    voter: {
      '=': 1,
      '!=': 1,
      'me': 0,
      'not_me': 0,
      'subscribed': 0,
      'not_subscribed': 0,
      'limited': 0,
    },
    subscription: {
      '=': 1, '!=': 1, 'subscribed': 0, 'not_subscribed': 0,
    },
    link_type: {
      '=': 1,
      '!=': 1,
    },
    user: {
      '=': 1,
      '!=': 1,
      'me': 0,
      'not_me': 0,
      'subscribed': 0,
      'not_subscribed': 0,
      'beginner': 0,
    },
  };
  /* eslint-enable sort-keys */

  let conditionCounter = 0;

  $(document).on('change', '#extra-condition select', function () {
    const newCondition = $(this).parent('li');

    const append = newCondition.clone();
    append.find('select').val('');

    newCondition
      .after(append)
      .attr('id', null)
      .addClass('condition');

    newCondition.find('select:first')
      .addClass('field')
      .find('option:first')
      .remove();

    newCondition.find('button.remove-item').show();
  }).on('click', 'ul.conditions li.condition button.remove-item',
        function () {
          $(this).parent('li').remove();
        })
    .on('change', 'ul.conditions select.field', function () {
      const val = $(this).val();
      const $replacement = $('#fields .field-' + val).clone();
      if ($replacement.length) {
        const $li = $(this).parent('li');
        $li.find('span.field-container span.field').replaceWith($replacement);

        const $field =
          $(this).parent('li').find('span.field-container span.field');
        $field
          .show()
          .find('select.operator').trigger('change');

        $li.find('span.autocomplete').each(function () {
          MB.Control.EntityAutocomplete({inputs: $(this)});
        });

        $li.find(':input').each(function () {
          addInputNamePrefix($(this));
        });

        conditionCounter++;
      } else {
        console.error('There is no field-' + val);
      }
    })
    .on('change', 'ul.conditions select.operator', function () {
      const $field = $(this).parent('span.field');

      const predicate = filteredClassName($field, 'predicate-');
      const cardinality = cardinalityMap[predicate][$(this).val()];

      $field.find('.arg').hide();
      $field.find('.arg:lt(' + cardinality + ')').show();
    });

  function prefixedInputName($element) {
    return 'conditions.' + conditionCounter + '.' + $element.attr('name').replace(/conditions\.\d+\./, '');
  }

  function addInputNamePrefix($input) {
    if ($input.attr('name')) {
      $input.attr('name', prefixedInputName($input));
    }
  }

  function filteredClassName($element, prefix) {
    const classList = $element.attr('class').split(/\s+/);
    let ret;
    for (let i = 0; i < classList.length; i++) {
      if (classList[i].substring(0, prefix.length) === prefix) {
        ret = classList[i].substring(prefix.length);
        break;
      }
    }

    return ret;
  }

  $('ul.conditions li.condition span.field').show();
  $('ul.conditions li.condition select.operator').trigger('change');
  $('ul.conditions li.condition button.remove-item').show();

  $('ul.conditions li.condition').each(function () {
    $(this).find(':input').each(function () {
      addInputNamePrefix($(this));
    });
    conditionCounter++;
  });

  $('ul.conditions span.autocomplete').each(function () {
    MB.Control.EntityAutocomplete({inputs: $(this)});
  });
});
