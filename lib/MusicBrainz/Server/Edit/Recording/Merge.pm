package MusicBrainz::Server::Edit::Recording::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_MERGE );
use MusicBrainz::Server::Translation qw( N_lp );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Utils qw( large_spread );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities' => {
        -excludes => 'recording_ids',
     },
     'MusicBrainz::Server::Edit::Recording';

sub edit_name { N_lp('Merge recordings', 'edit type') }
sub edit_type { $EDIT_RECORDING_MERGE }
sub _merge_model { 'Recording' }

sub recording_ids { @{ shift->_entity_ids } }

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => {
            $self->data->{new_entity}{id} => [ 'ArtistCredit' ],
            map {
                $_->{id} => [ 'ArtistCredit' ]
            } @{ $self->data->{old_entities} },
        },
    };
}

before build_display_data => sub {
    my ($self, $loaded) = @_;

    $self->c->model('ISRC')->load_for_recordings(
        grep { $_ && !$_->all_isrcs } map { $loaded->{Recording}{$_} } $self->recording_ids,
    );
};

around build_display_data => sub {
    my ($orig, $self, @args) = @_;

    my $data = $self->$orig(@args);

    my @recording_lengths = map { $_->{length} } (@{ $data->{old} }, $data->{new});
    $data->{large_spread} = boolean_to_json(large_spread(@recording_lengths));

    return $data;
};

sub edit_template { 'MergeRecordings' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
