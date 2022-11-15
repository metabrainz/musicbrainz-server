package MusicBrainz::Server::Form::Filter::Generic;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'filter' );

has 'entity_type' => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    default => '',
);

has_field 'cancel' => ( type => 'Submit' );
has_field 'submit' => ( type => 'Submit' );

sub filter_field_names {
    return qw/ name /;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{entity_type} = $self->entity_type;
    return $json;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
