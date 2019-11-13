// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';

import MB from '../../MB';

var SELECTED_CLASS = {
    '1':  'vote-yes',
    '0':  'vote-no',
    '-1': 'vote-abs',
};

MB.Control.EditList = function (container) {
    var self = {};

    var $container = $(container);

    self.initialize = function () {
        var $voteOptions = $container.find('input[type="radio"]')
            .first().parents('.voteopts').clone().addClass('overall-vote');

        $voteOptions.find('label').each(function () {
            $(this).attr('for', $(this).attr('for').replace(/id-enter-vote.vote.\d+/, 'vote-all'));
        });
        $voteOptions.find('input').each(function () {
            $(this).attr('id', $(this).attr('id').replace(/id-enter-vote.vote.\d+/, 'vote-all'));
            $(this).attr('name', 'vote-on-all');
        });

        $voteOptions.find(':input').prop('checked', false);

        $voteOptions.find('.vote').attr('class', 'vote');

        $voteOptions.prepend(
            $('<div>').text(l("Vote on all edits:")),
        );

        // :nth-child would make more sense, but I couldn't get it working
        // - ocharles
        $voteOptions.find('input').each(function (i) {
            $(this).click(function () {
                    $container.find('div.voteopts').each(function () {
                            $(this).find('input').eq(i)
                                .prop('checked', true)
                                .change();
                        });
            });
        });

        $container.before($voteOptions);
    }

    self.initialize()
    return self;
};

$(function () {
    $('div.vote input[type="radio"]').change(function () {
        $(this).parents('.voteopts').find('.vote').attr('class', 'vote');
        $(this).parent('label').parent('.vote').addClass(SELECTED_CLASS[$(this).val()]);
    })

    $('div.vote input[checked="checked"]').change();
});
