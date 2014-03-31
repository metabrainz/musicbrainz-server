package MusicBrainz::Server::Edit::Recording::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_MERGE );
use MusicBrainz::Server::Translation qw ( N_l );
use List::MoreUtils qw( minmax );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities' => {
    -excludes => 'recording_ids'
};
with 'MusicBrainz::Server::Edit::Recording';

sub edit_name { N_l('Merge recordings') }
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
            } @{ $self->data->{old_entities} }
        }
    }
}

before build_display_data => sub {
    my ($self, $loaded) = @_;

    $self->c->model('ISRC')->load_for_recordings(
        grep { $_ && !$_->all_isrcs } map { $loaded->{Recording}{$_} } $self->recording_ids
    );
};

around build_display_data => sub {
    my ($orig, $self, @args) = @_;

    my $data = $self->$orig(@args);

    my @recording_lengths = grep { defined $_ } map { $_->length } (@{ $data->{old} }, $data->{new});
    if (@recording_lengths) {
        my ($min, $max) = minmax(@recording_lengths);
        $data->{large_spread} = 1 if $max - $min >= 15*1000; # 15 seconds
    }

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

