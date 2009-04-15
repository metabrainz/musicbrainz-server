package MusicBrainz::Server::Form::AutoEditorElection::Vote;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        required => {
            vote => {
                type             => 'Select',
                auto_widget_size => 3,
            }
        }
    }
}

sub options_vote
{
    return [
        ModDefs::VOTE_YES, "Yes",
        ModDefs::VOTE_NO, "No",
        ModDefs::VOTE_ABS, "Abstain",
    ];
}

1;