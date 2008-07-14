package MusicBrainz::Server::Form;

use strict;
use warnings;

use base 'Form::Processor';

sub context
{
    my ($self, $new) = @_;

    $self->{context} = $new
        if defined $new && ref $new;

    return $self->{context};
}

1;
