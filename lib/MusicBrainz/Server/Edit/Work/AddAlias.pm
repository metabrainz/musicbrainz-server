package MusicBrainz::Server::Edit::Work::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities',
     'MusicBrainz::Server::Edit::Alias::Add' => {
        model => 'Work',
        edit_name => N_lp('Add work alias', 'edit type'),
        edit_type => $EDIT_WORK_ADD_ALIAS,
     };

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
