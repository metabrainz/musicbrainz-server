// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (releaseEditor) {

    var validation = releaseEditor.validation = releaseEditor.validation || {};
    var utils = releaseEditor.utils;


    var releaseField = ko.observable().subscribeTo("releaseField", true);
    var errorFields = validation.errorFields = ko.observableArray([]);


    validation.errorField = function (func) {
        var observable = ko.isObservable(func) ? func : ko.computed(func);
        errorFields.push(observable);
        return observable;
    };

    validation.errorsExist = ko.computed(function () {
        var fields = errorFields();
        for (var i = 0, len = fields.length; i < len; i++) {
            if (fields[i]()) return true;
        }
        return false;
    });


    function markTabWithErrors($panel) {
        // Don't mark the edit note tab, because it's the last one and only
        // can have one error, so the user will always see it anyway.
        if ($panel.attr("id") === "edit-note") {
            return;
        }
        // Mark the previous tab red if it has errors.
        var tabs = releaseEditor.uiTabs;

        var $errors = $(".field-error", $panel).filter(function () {
            return $(this).data("visible") && $(this).text();
        });

        tabs.tabs.eq(tabs.panels.index($panel))
            .toggleClass("error-tab", $errors.length > 0);
    }


    function showErrorHandler(handler) {
        return function (element, valueAccessor, allBindings, vm) {
            var $element = $(element).hide(),
                errorField = valueAccessor();

            // Binding may be running before element has been added to the DOM.
            _.defer(function () {
                ko.computed({
                    read: function () {
                        var value = errorField.call(vm),
                            $panel = $element.parents(".ui-tabs-panel");

                        if (_.isString(value)) {
                            $element.text(value || "")
                        }
                        handler(value, $element, $panel);
                        markTabWithErrors($panel);
                    },
                    disposeWhenNodeIsRemoved: element
                });
            });
        };
    }


    ko.bindingHandlers.showErrorRightAway = {

        init: showErrorHandler(function (value, $element) {
            $element.data("visible", !!value).toggle(!!value);
        })
    };


    ko.bindingHandlers.showErrorWhenTabIsSwitched = {

        init: showErrorHandler(function (value, $element, $panel) {
            var alreadyVisible = $element.is(":visible");

            if (!value && alreadyVisible) {
                $element.data("visible", false).hide();
            }

            var $hidden = $panel.data("hiddenErrors") || $();

            $panel.data("hiddenErrors",
                (value && !alreadyVisible)
                    ? $hidden.add($element) : $hidden.not($element));
        })
    };


    $(function () {
        $("#release-editor").on("tabsbeforeactivate", function (event, ui) {

            // Show errors on and mark all tabs between the one we just
            // clicked on, including the one we left.
            var oldPanel = ui.oldPanel;
            var newPanel = ui.newPanel;

            var $panels = (oldPanel.index() < newPanel.index())
                ? oldPanel.nextUntil(newPanel).andSelf()
                : newPanel.nextUntil(oldPanel).andSelf();

            $panels.each(function () {
                var $panel = $(this);

                ($panel.data("hiddenErrors") || $())
                    .data("visible", true).show();

                $panel.data("hiddenErrors", $());

                markTabWithErrors($panel);
            });
        });
    });


    // Barcode should be a valid EAN/UPC.

    utils.withRelease(function (release) {
        var field = release.barcode;

        field.error("");
        field.message("");

        var barcode = field.barcode();
        if (!barcode || field.confirmed()) return;

        var checkDigitText = MB.i18n.l("The check digit is {checkdigit}.");
        var doubleCheckText = MB.i18n.l("Please double-check the barcode on the release.");

        if (barcode.length === 11) {
            field.error(
                MB.i18n.l("The barcode you entered looks like a UPC code with the check digit missing.") +
                " " +
                MB.i18n.expand(checkDigitText, { checkdigit: field.checkDigit("0" + barcode) })
            );
        } else if (barcode.length === 12) {
            if (field.validateCheckDigit("0" + barcode)) {
                field.message(MB.i18n.l("The barcode you entered is a valid UPC code."));
            } else {
                field.error(
                    MB.i18n.l("The barcode you entered is either an invalid UPC code, or an EAN code with the check digit missing.") +
                    " " +
                    doubleCheckText +
                    " " +
                    MB.i18n.expand(checkDigitText, { checkdigit: field.checkDigit(barcode) })
                );
            }
        } else if (barcode.length === 13) {
            if (field.validateCheckDigit(barcode)) {
                field.message(MB.i18n.l("The barcode you entered is a valid EAN code."));
            } else {
                field.error(
                    MB.i18n.l("The barcode you entered is not a valid EAN code.") +
                    " " +
                    doubleCheckText
                );
            }
        } else {
            field.error(
                MB.i18n.l("The barcode you entered is not a valid UPC or EAN code.") +
                " " +
                doubleCheckText
            );
        }
    });

}(MB.releaseEditor = MB.releaseEditor || {}));
