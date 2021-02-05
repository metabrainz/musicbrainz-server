package MusicBrainz::Server::Form::Role::Relationships;
use HTML::FormHandler::Moose::Role;

has_field 'url' => (
    type => 'Repeatable',
);

has_field 'url.contains' => (
    type => '+MusicBrainz::Server::Form::Field::Relationship',
);

has_field 'rel' => (
    type => 'Repeatable',
);

has_field 'rel.contains' => (
    type => '+MusicBrainz::Server::Form::Field::Relationship',
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
