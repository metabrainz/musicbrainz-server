package MusicBrainz::Server::Edit::Event::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw ( N_lp );

extends 'MusicBrainz::Server::Edit';

with 'MusicBrainz::Server::Edit::Annotation::Edit' => {
    model => 'Event',
    edit_name => N_lp('Add event annotation', 'edit type'),
    edit_type => $EDIT_EVENT_ADD_ANNOTATION,
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
