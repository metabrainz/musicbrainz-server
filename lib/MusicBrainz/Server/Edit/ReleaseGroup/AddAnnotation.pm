package MusicBrainz::Server::Edit::ReleaseGroup::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities',
     'MusicBrainz::Server::Edit::Annotation::Edit' => {
        model => 'ReleaseGroup',
        edit_name => N_lp('Add release group annotation', 'edit type'),
        edit_type => $EDIT_RELEASEGROUP_ADD_ANNOTATION,
     };

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
