package MusicBrainz::Server::Edit::Relationship::RelatedEntities;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( type_to_model );

requires 'directly_related_entities';

my %expand = map { $_ => 1 } qw( recording release release_group );

around _build_related_entities => sub {
    my ($orig, $self) = @_;
    my $direct = $self->directly_related_entities;

    for my $type (keys %$direct) {
        next unless $expand{$type};
        my $model = type_to_model($type);
        my @ids = @{ $direct->{$type} };
        my @entities = values %{ $self->c->model($model)->get_by_ids(@ids) };
        $self->c->model('ArtistCredit')->load(@entities);
        $direct->{artist} ||= [];
        push @{ $direct->{artist} }, map { $_->artist_id }
            map { $_->artist_credit->all_names }
                @entities
    }

    return $direct;
};

1;
