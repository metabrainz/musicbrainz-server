package MusicBrainz::Server::Form::Admin::LinkType::Edit;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Admin::LinkType';

has_field 'examples' => (
    type => 'Repeatable',
    num_when_empty => 0
);

has_field 'examples.relationship' => (
    type => 'Compound',
    required => 1
);

has_field 'examples.relationship.id' => (
    type => 'Integer',
    required => 1
);

has_field 'examples.name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    not_nullable => 1
);

override edit_field_names => sub {
    my $self = shift;
    return ( super(), 'examples' );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
