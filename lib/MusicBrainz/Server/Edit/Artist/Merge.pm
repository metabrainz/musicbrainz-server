package MusicBrainz::Server::Edit::Artist::Merge;
use Moose;

use MooseX::Types::Moose qw( ArrayRef Bool Int Str );
use MooseX::Types::Structured qw( Dict );
use List::MoreUtils qw( any );
use MusicBrainz::Server::Constants qw( $ARTIST_TYPE_GROUP $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Translation qw( N_l );
use Hash::Merge qw( merge );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Role::MergeSubscription';
with 'MusicBrainz::Server::Edit::Artist';

sub edit_name { N_l('Merge artists') }
sub edit_type { $EDIT_ARTIST_MERGE }

sub _merge_model { 'Artist' }
sub subscription_model { shift->c->model('Artist')->subscription }

sub foreign_keys
{
    my $self = shift;
    return {
        Artist => {
            map {
                $_ => [ 'ArtistType', 'Gender', 'Area' ]
            } (
                $self->data->{new_entity}{id},
                map { $_->{id} } @{ $self->data->{old_entities} },
            )
        }
    }
}

has '+data' => (
    isa => Dict[
        new_entity => Dict[
            id   => Int,
            name => Str
        ],
        old_entities => ArrayRef[ Dict[
            name => Str,
            id   => Int
        ] ],
        rename => Bool
    ]
);

sub do_merge
{
    my $self = shift;

    my $new_artist = $self->c->model('Artist')->get_by_id($self->new_entity->{id});
    my @old_artists = values %{ $self->c->model('Artist')->get_by_ids($self->_old_ids) };

    my $old_groups = any {
        ($_->type_id == $ARTIST_TYPE_GROUP) || $self->c->sql->select_single_value(
            'SELECT 1 FROM artist_type WHERE id = ? AND parent = ?',
            $_->type_id, $ARTIST_TYPE_GROUP,
        );
    } @old_artists;

    if (defined $new_artist->gender_id && !defined $new_artist->type_id && $old_groups) {
        MusicBrainz::Server::Edit::Exceptions::GeneralError->throw(
            'This edit would create a group artist with a gender, '.
            'but a group cannot have a gender. '.
            'Please correct the data as needed and re-enter the merge.'
        );
    }

    $self->c->model('Artist')->merge(
        $self->new_entity->{id},
        [ $self->_old_ids ],
        rename => $self->data->{rename}
    );
};

around _build_related_entities => sub {
    my ($orig, $self, @args) = @_;
    my $related_entities = $self->$orig(@args);

    if ($self->data->{rename}) {
        for my $ac (map { @{ $self->c->model('ArtistCredit')->find_by_artist_id($_->{id}) } } @{ $self->data->{old_entities} }) {
            # It would make sense to include only those artist credits that
            # will actually change, but the target name may change before
            # this edit is accepted.
            my $r = $self->c->model('ArtistCredit')->related_entities($ac);
            $related_entities = merge($related_entities, $r);
        }
    }
    return $related_entities;
};

around build_display_data => sub {
    my ($orig, $self, @args) = @_;

    my $data = $self->$orig(@args);

    $data->{rename} = boolean_to_json($self->data->{rename});

    return $data;
};

sub edit_template_react { 'MergeArtists' };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
