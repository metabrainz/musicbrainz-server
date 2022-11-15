package MusicBrainz::Server::Edit::Release::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Release',
    edit_name => N_l('Add release annotation'),
    edit_type => $EDIT_RELEASE_ADD_ANNOTATION,
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
