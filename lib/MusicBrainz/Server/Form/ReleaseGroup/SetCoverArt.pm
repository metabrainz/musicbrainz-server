package MusicBrainz::Server::Form::ReleaseGroup::SetCoverArt;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'set-cover-art' );

has_field 'release' => (
    type      => '+MusicBrainz::Server::Form::Field::GID',
    required  => 1,
);

sub edit_field_names
{
    return qw( release );
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
