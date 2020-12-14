package MusicBrainz::Server::Form::Release::AddCoverArt;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::ReleaseCoverArt';
with 'MusicBrainz::Server::Form::Role::AddArt';

has '+name' => ( default => 'add-cover-art' );

sub art_archive_model { shift->ctx->model('CoverArtArchive') }

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
