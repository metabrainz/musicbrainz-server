package MusicBrainz::Server::Edit::Historic::MoveReleaseToRG;
use Moose;
use namespace::autoclean;

use List::MoreUtils qw( uniq );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MOVE );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release';

sub edit_name { N_l('Edit release') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_RELEASE_MOVE }
sub edit_template_react { 'historic/MoveReleaseToReleaseGroup' }

sub release_id { shift->data->{release}{id} }
sub release_ids { shift->release_id }

has '+data' => (
    isa => Dict[
        release => Dict[
            id => Int,
            name => Str
        ],
        old_release_group => Dict[
            id => Int,
            name => Str
        ],
        new_release_group => Dict[
            id => Int,
            name => Str
        ]
    ]
);

sub _build_related_entities
{
    my $self = shift;

    my @releases = values %{ $self->c->model('Release')->get_by_ids($self->data->{release}{id}) };
    my @groups = values %{ $self->c->model('ReleaseGroup')->get_by_ids($self->data->{old_release_group}{id},
                                                                       $self->data->{new_release_group}{id}) };

    $self->c->model('ArtistCredit')->load(@releases, @groups);

    return {
        artist => [
            uniq map { $_->artist_id } map { @{ $_->artist_credit->names } }
                @releases, @groups
        ],
        release =>       [ uniq map { $_->id } @releases ],
        release_group => [ uniq map { $_->id } @groups ],
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { $self->data->{release}{id} => [ 'ArtistCredit' ] },
        ReleaseGroup => {
            $self->data->{old_release_group}{id} => [ 'ArtistCredit' ],
            $self->data->{new_release_group}{id} => [ 'ArtistCredit' ],
        },
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        release => to_json_object(
            $loaded->{Release}{ $self->data->{release}{id} } ||
            Release->new(
                id => $self->data->{release}{id},
                name => $self->data->{release}{name},
            )
        ),
        release_group => {
            old => to_json_object(
                $loaded->{ReleaseGroup}{ $self->data->{old_release_group}{id} } ||
                ReleaseGroup->new(
                    id => $self->data->{old_release_group}{id},
                    name => $self->data->{old_release_group}{name},
                )
            ),
            new => to_json_object(
                $loaded->{ReleaseGroup}{ $self->data->{new_release_group}{id} } ||
                ReleaseGroup->new(
                    id => $self->data->{new_release_group}{id},
                    name => $self->data->{new_release_group}{name},
                )
            ),
        }
    };
}

1;
