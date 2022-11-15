package MusicBrainz::Server::Edit::Recording::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_DELETE );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Delete';
with 'MusicBrainz::Server::Edit::Recording';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities';

sub edit_type { $EDIT_RECORDING_DELETE }
sub edit_name { N_l('Remove recording') }
sub _delete_model { 'Recording' }
sub recording_id { shift->entity_id }

override 'foreign_keys' => sub {
    my $self = shift;
    my $data = super();

    $data->{Recording} = {
        $self->recording_id => [ 'ArtistCredit' ]
    };
    return $data;
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
