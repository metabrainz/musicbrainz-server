/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

MB.constants.SELECTED_CLASS = {
    '1':  'vote-yes',
    '0':  'vote-no',
    '-1': 'vote-abs'
}

MB.Control.EditList = function(container) {
    var self = MB.Object();

    var $container = $(container);

    self.initialize = function() {
        var $voteOptions = $container.find('input[type="radio"]')
            .first().parents('.voteopts').clone().addClass('overall-vote');

        $voteOptions.find('label').each(function() {
            $(this).attr('for', $(this).attr('for').replace(/id-enter-vote.vote.\d+/, 'vote-all'));
        });
        $voteOptions.find('input').each(function() {
            $(this).attr('id', $(this).attr('id').replace(/id-enter-vote.vote.\d+/, 'vote-all'));
            $(this).attr('name', 'vote-on-all');
        });

        $voteOptions.find(':input').prop('checked', false);

        $voteOptions.find('.vote').attr('class', 'vote');

        $voteOptions.prepend(
            $('<div>').text(MB.text.VoteOnAllEdits)
        );

        // :nth-child would make more sense, but I couldn't get it working
        // - ocharles
        $voteOptions.find('input').each(function(i) {
            $(this).click(function() {
                    $container.find('div.voteopts').each(function() {
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

$(function() {
    $('div.vote input[type="radio"]').change(function() {
        $(this).parents('.voteopts').find('.vote').attr('class', 'vote');
        $(this).parent('label').parent('.vote').addClass(MB.constants.SELECTED_CLASS[ $(this).val() ]);
    })

    $('div.vote input[checked="checked"]').change();
});
