package MusicBrainz::Server::Form::Annotation::Edit;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    shift->with_mod_fields({
        optional => {
            annotation => {
                type => 'TextArea',
                style => 'large'
            },
            change_log => {
                type => 'Text',
                size => 100
            },
        }
    });
}

1;
