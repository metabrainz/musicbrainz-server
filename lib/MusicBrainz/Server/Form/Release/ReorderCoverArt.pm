package MusicBrainz::Server::Form::Release::ReorderCoverArt;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'reorder-cover-art' );

has_field 'artwork' => ( type => 'Repeatable' );
has_field 'artwork.id' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'artwork.position' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );

sub edit_field_names { qw( artwork ) }

no Moose;
__PACKAGE__->meta->make_immutable;


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
