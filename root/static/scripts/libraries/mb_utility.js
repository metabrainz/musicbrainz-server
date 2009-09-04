/*jslint undef: true, browser: true*/
/*global jQuery, $, MusicBrainz */

/**
 * @fileOverview This file contains all utility functions used in MusicBrainz javascript code.
 * @author Brian Schweitzer (BrianFreud) brian.brianschweitzer@gmail.com
 * @requires html_factory.js
 * @requires jquery.js
 * @requires jquery.selectboxes.js
 * @requires jquery.unwrap.js
 * @requires text_strings.js
 */

"use strict";

/**
 * @description Generic utility functions.
 * @namespace
 */
MusicBrainz.utility = {
    /**
     * @description Creates a text overlay over an element, using the plaintext value of the original element as the text source.
     * @param {Object} $element A single jQuery-wrapped element over which to place an overlay.
     * @param {Function} [options.createOverlayText] A callback to create custom plaintext strings for use as the overlay text; if $element is not
     *        an &lt;input&gt; or a &lt;select&gt; and stringFormatter is omitted, an empty string will be returned.
     * @param {String} [options.textForUnknown] The text to use for overlaying fields which currently have no defined value; default text is stored in MusicBrainz.text.Unknown.
     * @param {String} [options.wrapper] Type of element to use to enclose the overlay; by default, $element's enclosing element type will be used.
     * @see <a href="#addOverlayThis"/>
     **/
    addOverlay: function ($element, options) {
        options = options || {};

        var $elementToOverlay = $element,
            html = MusicBrainz.html,
            textForUnknown = options.textForUnknown || MusicBrainz.text.UnknownPlaceholder,
            parentWrapped = false,
            $thisParent = $element.parent() || $element,
            elementValue, wrapper;

        if ($element.is('button, input, select, textarea')) {
            elementValue = MusicBrainz.utility.getValue($element);
            $elementToOverlay = $thisParent;
        } else {
            elementValue = options.createOverlayText ? options.createOverlayText($element) : textForUnknown;
        }
        elementValue = elementValue || textForUnknown;

        wrapper = options.wrapper || $elementToOverlay[0].tagName.toLowerCase();
        if ($elementToOverlay.parent().length === 0) { // .after() uses .parentNode.  This breaks in a shallow document fragment, so
            $thisParent.wrap('<div id="temp_wrapper"></div>'); // wrap $thisParent to ensure that it has a valid parentNode.
            parentWrapped = true;
        }

        $elementToOverlay.after(html[wrapper]({ cl: 'editable' }) + elementValue + html.close(wrapper));

        if (parentWrapped) {
            $("#temp_wrapper > *:first").unwrap(); // Remove the protective wrapper.
        }

        return $element;
    },
    /**
     * @description Interface wrapper for addOverlay; "this" is implicitly used as the target element, rather than (as in addOverlay) explicitly defined in $element.
     * @param {Object} [$eleInt] This variable is ignored.
     * @param {Object} [options] See <a href="#addOverlay"/>
     * @see <a href="#addOverlay">addOverlay</a>
     **/
    addOverlayThis: function ($eleInt, options) {
        return MusicBrainz.utility.addOverlay($(this), options || {});
    },
    /**
     * @description Returns a plaintext string based on the deliniated value(s) of text input(s) within a parent element.
     * @param {Object} $inputs A single jQuery-wrapped parent element containing child inputs of type text.
     * @param {String} [joinSeparator] The separator to use between the values of each input; default is '&nbsp;&ndash;&nbsp;'.
     **/
    getChildValues: function ($inputs, joinSeparator) {
        return $('input[type=text][value!=""]', $inputs).map(function () {
                                                                 return this.value;
                                                        })
                                                       .get()
                                                       .join(typeof joinSeparator === 'undefined' ? '&nbsp;&ndash;&nbsp;' : joinSeparator);
    },
    /**
     * @description Returns the plaintext value of an element; if $element is not an &lt;input&gt; of type text, or a &lt;select&gt;,
     *              an empty string will be returned.
     * @param {Object} $element A single jQuery-wrapped element for which to return the plaintext value.
     **/
    getValue: function ($element) {
        if ($element.is('select')) {
            return $element.selectedTexts()[0];
        } else if ($element.is('input')) {
            if ($element.is('[type=radio],[type=checkbox]')) {
                return $element.attr("checked");
            } else {
                return $element.val();
            }
        } else if ($element.is('textarea')) {
            return $element.html();
        } else if ($element.is('button')) {
            return $element.val();
        }
        return '';
    }
};
