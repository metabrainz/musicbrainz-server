package MusicBrainz::Server::Form::Release::EditCoverArt;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::ReleaseCoverArt';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-cover-art' );

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
