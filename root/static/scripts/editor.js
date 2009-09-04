/*jslint undef: true, browser: true*/
/*global jQuery, $, MusicBrainz, notLive */

/** 
 * @fileOverview This file contains all functions to initialize and run the MusicBrainz inline editor. 
 * @author Brian Schweitzer (BrianFreud) brian.brianschweitzer@gmail.com
 * @requires html_factory.js
 * @requires jquery.js
 * @requires jquery.selectboxes.js
 * @requires jquery.jquery.js
 * @requires mb_utilities.js
 */

"use strict";

/**
 * @description Contains all functionality for the inline editor.
 * @namespace
 */
MusicBrainz.editor = {
    /**
     * @description Stores static selectors.
     * @namespace
     */
    $cache: {
        /** 
         * @description Stores sidebar-specific collections of static selectors.
         */
        $sidebar: {},
        /**
         * @description Initializes cache data for derived variables, onReady.
         **/
        init: function ($) {
            var $sidebar = MusicBrainz.editor.$cache.$sidebar,
                $sidebarDDs;
            /* Sidebar initiation */
            $sidebarDDs = $sidebar.$DDs = $('#sidebar dd');
            $sidebar.$DateDDs = $sidebarDDs.filter('.date');
            $sidebar.$InputDDs = $sidebarDDs.filter(':has(input):not(.date)');
            $sidebar.$SelectDDs = $sidebarDDs.filter(':has(select)');
        }
    },
    /**
     * @description Stores sidebar-specific functionality.
     * @namespace
     */
    sidebar: {
        /**
         * @description Initializes sidebar functionality, onReady.
         **/
        init: function ($) {
            var mb = MusicBrainz,
                $sidebar = mb.editor.$cache.$sidebar,
                utility = mb.utility,
                addOverlay = utility.addOverlay,
                addOverlayThis = utility.addOverlayThis,
                getChildValues = utility.getChildValues;
            $sidebar.$DateDDs.each(function (i) {
                addOverlay($(this), {
                                    createOverlayText: getChildValues
                                    });
            });
            $sidebar.$InputDDs.find('input')
                              .add($sidebar.$SelectDDs.find('select'))
                              .each(addOverlayThis);
        },
        /** 
         * @description Stores sidebar-specific event bindings.
         */
        events: {
            showEditFieldsOnClick: function ($) {
                $('#sidebar').bind('click', function (e) {
                    if ($(e.target).parents("dl")) { // Don't toggle if the click wasn't within a dl.
                        $(e.target).closest('.editable')
                                   .addClass('hidden')
                                   .prev()
                                   .show();
                    }
                });
            }
        }
    }
};
/**
 * @description Initialize initial page-load functionality.
 */
($(function ($) {
    if (typeof notLive === 'undefined') { // Prevent self-initiation when loaded for unit-tests.
        var mbEditor = MusicBrainz.editor,
            sidebar = mbEditor.sidebar;
        mbEditor.$cache.init($);
        sidebar.init($);
        sidebar.events.showEditFieldsOnClick($);
    }
}));
