package MusicBrainz::Server::Edit::Artist::Merge;
use Moose;

use MooseX::Types::Moose qw( ArrayRef Bool Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Translation qw ( N_l );
use Hash::Merge qw( merge );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Role::MergeSubscription';
with 'MusicBrainz::Server::Edit::Artist';

sub edit_name { N_l('Merge artists') }
sub edit_type { $EDIT_ARTIST_MERGE }

sub _merge_model { 'Artist' }
sub subscription_model { shift->c->model('Artist')->subscription }

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

__PACKAGE__->meta->make_immutable;
no Moose;

1;
