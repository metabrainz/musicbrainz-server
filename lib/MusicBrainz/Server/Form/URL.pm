package MusicBrainz::Server::Form::URL;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-url' );

has_field 'url' => (
    type      => '+MusicBrainz::Server::Form::Field::URL',
    required  => 1,
);

# XXX Can't use Form::Role::Relationships because it conflicts with the url field.
has_field 'rel' => (
    type => 'Repeatable',
);

has_field 'rel.contains' => (
    type => '+MusicBrainz::Server::Form::Field::Relationship',
);

sub edit_field_names { qw( url ) }

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
