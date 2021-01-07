/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';
import * as ReactDOMServer from 'react-dom/server';

import MB from '../common/MB';
import DescriptiveLink from '../common/components/DescriptiveLink'
import expand2text from '../common/i18n/expand2text';
import {errorsExist} from '../edit/validation';

import utils from './utils';
import releaseEditor from './viewModel';

const validation = {};

releaseEditor.validation = validation;

// Allow for access in ko templates
validation.errorsExist = errorsExist;

function markTabWithErrors($panel) {
  /*
   * Don't mark the edit note tab, because it's the last one and only
   * can have one error, so the user will always see it anyway.
   */
  if ($panel.attr('id') === 'edit-note') {
    return;
  }
  // Mark the previous tab red if it has errors.
  var tabs = releaseEditor.uiTabs;

  var $errors = $('.field-error', $panel).filter(function () {
    return $(this).data('visible') && $(this).text();
  });

  tabs.tabs.eq(tabs.panels.index($panel))
    .toggleClass('error-tab', $errors.length > 0);
}


function showErrorHandler(handler) {
  return function (element, valueAccessor, allBindings, vm) {
    const $element = $(element).hide();
    const errorField = valueAccessor();

    // Binding may be running before element has been added to the DOM.
    setTimeout(function () {
      ko.computed({
        read: function () {
          const value = errorField.call(vm);
          const $panel = $element.parents('.ui-tabs-panel');

          if (typeof value === 'string') {
            $element.text(value || '');
          }
          handler(value, $element, $panel);
          markTabWithErrors($panel);
        },
        disposeWhenNodeIsRemoved: element,
      });
    }, 1);
  };
}


ko.bindingHandlers.showErrorRightAway = {

  init: showErrorHandler(function (value, $element) {
    $element.data('visible', !!value).toggle(!!value);
  }),
};

ko.bindingHandlers.showMessageRightAway =
  ko.bindingHandlers.showErrorRightAway;

ko.bindingHandlers.showErrorWhenTabIsSwitched = {

  init: showErrorHandler(function (value, $element, $panel) {
    var alreadyVisible = $element.is(':visible');

    if (!value && alreadyVisible) {
      $element.data('visible', false).hide();
    }

    var $hidden = $panel.data('hiddenErrors') || $();

    $panel.data('hiddenErrors',
                (value && !alreadyVisible)
                  ? $hidden.add($element) : $hidden.not($element));
  }),
};


$(function () {
  $('#release-editor').on('tabsbeforeactivate', function (event, ui) {

    /*
     * Show errors on and mark all tabs between the one we just
     * clicked on, including the one we left.
     */
    var oldPanel = ui.oldPanel;
    var newPanel = ui.newPanel;

    var $panels = (oldPanel.index() < newPanel.index())
      ? oldPanel.nextUntil(newPanel).andSelf()
      : newPanel.nextUntil(oldPanel).andSelf();

    $panels.each(function () {
      var $panel = $(this);

      ($panel.data('hiddenErrors') || $())
        .data('visible', true).show();

      $panel.data('hiddenErrors', $());

      markTabWithErrors($panel);
    });
  });
});


// Search releases with the same barcode
function searchExistingBarcode(field, barcode, releaseId) {
  utils.search('release', `barcode:${barcode}`, 1).done(data => {
    const releases = data.releases;
    const hasBarcodeInUse = releases.length > 1 ||
      (releases.length === 1 && releases[0].id !== releaseId);
    if (hasBarcodeInUse) {
      const msg = l(
        `The following releases with that barcode are already in the
         MusicBrainz database. Please make sure you are not adding an
         exact duplicate of any of these:`,
      );
      const releaseList = ReactDOMServer.renderToString(
        <>
          {msg}
          <ul>
            {data.releases.map(release => {
              const cleanedRelease = new MB.entity.Release(
                utils.cleanWebServiceData(release),
              );
              return (
                <li key={release.id}>
                  <DescriptiveLink
                    entity={cleanedRelease}
                  />
                </li>
              );
            })}
          </ul>
        </>,
      );
      field.existing(releaseList);
    }
  });
}

// Barcode should be a valid EAN/UPC.

utils.withRelease(function (release) {
  var field = release.barcode;

  field.error('');
  field.message('');
  field.existing('');

  var barcode = field.barcode();
  if (!barcode || barcode === field.original || field.confirmed()) {
    return;
  }

  var checkDigitText = l('The check digit is {checkdigit}.');
  var doubleCheckText = l('Please double-check the barcode on the release.');

  if (barcode.length === 11) {
    field.error(
      l(
        `The barcode you entered looks like a UPC code
         with the check digit missing.`,
      ) +
      ' ' +
      expand2text(
        checkDigitText, {checkdigit: field.checkDigit('0' + barcode)},
      ),
    );
  } else if (barcode.length === 12) {
    if (field.validateCheckDigit('0' + barcode)) {
      field.message(l('The barcode you entered is a valid UPC code.'));
      searchExistingBarcode(field, barcode, release.gid());
    } else {
      field.error(
        l(
          `The barcode you entered is either an invalid UPC code,
           or an EAN code with the check digit missing.`,
        ) +
        ' ' +
        doubleCheckText +
        ' ' +
        expand2text(
          checkDigitText,
          {checkdigit: field.checkDigit(barcode)},
        ),
      );
    }
  } else if (barcode.length === 13) {
    if (field.validateCheckDigit(barcode)) {
      field.message(l('The barcode you entered is a valid EAN code.'));
      searchExistingBarcode(field, barcode, release.gid());
    } else {
      field.error(
        l('The barcode you entered is not a valid EAN code.') +
        ' ' +
        doubleCheckText,
      );
    }
  } else {
    field.error(
      l('The barcode you entered is not a valid UPC or EAN code.') +
      ' ' +
      doubleCheckText,
    );
  }
});
