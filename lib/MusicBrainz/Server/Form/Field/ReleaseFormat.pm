package MusicBrainz::Server::Form::Field::ReleaseFormat;

use strict;
use warnings;

use base 'Form::Processor::Field::Select';

sub init_options
{
    return [0, 'hi', 1, 'boo', 56]; 
}

1;
