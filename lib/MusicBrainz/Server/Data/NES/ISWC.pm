package MusicBrainz::Server::Data::NES::ISWC;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( object_to_revision_ids );

with 'MusicBrainz::Server::Data::Role::NES';

sub load_for_works {
    my ($self, @works) = @_;
    my %works_by_revision_id = object_to_revision_ids(@works);
    my %iswc_map = %{
        $self->request('/iswc/find-by-works', {
            revisions => [
                map +{ revision => $_->revision_id }, @works
            ]
        })
    };

    for my $key (keys %iswc_map) {
        for my $work (@{ $works_by_revision_id{$key} }) {
            $work->iswcs([
                map {
                    MusicBrainz::Server::Entity::ISWC->new( iswc => $_ )
                  } @{ $iswc_map{$key} }
            ]);
        }
    }

    return;
}

__PACKAGE__->meta->make_immutable;
1;
