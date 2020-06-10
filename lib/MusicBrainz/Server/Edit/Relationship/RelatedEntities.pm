package MusicBrainz::Server::Edit::Relationship::RelatedEntities;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( type_to_model );

requires 'directly_related_entities';

my %expand = map { $_ => 1 } qw( recording release release_group work );

around _build_related_entities => sub {
    my ($orig, $self) = @_;
    my $direct = $self->directly_related_entities;

    for my $type (keys %$direct) {
        next unless $expand{$type};
        my $model = type_to_model($type);
        my @ids = @{ $direct->{$type} };
        my @entities = values %{ $self->c->model($model)->get_by_any_ids(@ids) };
        if ($ENTITIES{$type}{artist_credits}) {
            $self->c->model('ArtistCredit')->load(@entities);
            $direct->{artist} ||= [];
            push @{ $direct->{artist} }, map { $_->artist_id }
                map { $_->artist_credit->all_names }
                    @entities;
        }

        # For works, we want relationship edits to also appear on the recordings and releases they're linked to
        my @work_ids = map { $_->id } grep { $_->isa('MusicBrainz::Server::Entity::Work') } @entities;
        my ($recordings, $hits) = $self->c->model('Recording')->find_by_works(\@work_ids);
        my @work_recording_ids = map { $_->id } @$recordings;
        push @{ $direct->{recording} }, @work_recording_ids;


        # For recordings, we want relationship edits to also appear on the releases they're on
        my @recording_ids = map { $_->id } grep { $_->isa('MusicBrainz::Server::Entity::Recording') } @entities;
        push @recording_ids, @work_recording_ids;
        my ($releases, $hits) = $self->c->model('Release')->find_by_recording(\@recording_ids);
        push @{ $direct->{release} }, map { $_->id } @$releases;
    }

    # Extract attributes from delete relationship edits
    my @gids = ();
    if ($self->data->{relationship}) {
        my $attributes = $self->data->{relationship}->{link}->{attributes};
        @gids = map { $_->{type}{gid} } @$attributes;
    }

    # Extract attributes from add/edit relationship edits
    my $attributes = $self->c->model('LinkAttributeType')->get_by_ids(
        map { $_->{type}{id} } (
            @{ $self->data->{attributes} },
            @{ $self->data->{old}->{attributes} },
            @{ $self->data->{new}->{attributes} }
        )
    );

    # Use gids to find matching instrument entities, so that we can show relationship edits in instrument edit histories
    my $instruments = $self->c->model('Instrument')->get_by_gids(@gids, map { $_->gid } values %$attributes);
    push @{ $direct->{instrument} }, map { $_->id } values %$instruments;

    return $direct;
};

1;
