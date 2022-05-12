package MusicBrainz::Server::Form::Filter::Event;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( lp );
extends 'MusicBrainz::Server::Form::Filter::Generic';

has 'types' => (
    isa => 'ArrayRef[EventType]',
    is => 'ro',
    required => 1,
);

has_field 'type_id' => (
    type => 'Select',
);

sub filter_field_names {
    return qw/ name type_id /;
}

sub options_type_id {
    my ($self, $field) = @_;
    return [
        { value => '-1', label => lp('[none]', 'event type') },
        map +{ value => $_->id, label => $_->l_name },
        @{ $self->types }
    ];
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{options_type_id} = $self->options_type_id;
    return $json;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
