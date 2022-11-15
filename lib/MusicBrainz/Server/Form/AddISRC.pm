package MusicBrainz::Server::Form::AddISRC;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw( isrc ) }

has '+name' => ( default => 'add-isrc' );

has_field 'isrc' => (
    type      => '+MusicBrainz::Server::Form::Field::ISRC',
    required  => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
