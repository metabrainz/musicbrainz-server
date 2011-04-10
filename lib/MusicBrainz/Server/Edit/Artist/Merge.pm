package MusicBrainz::Server::Edit::Artist::Merge;
use Moose;

use MooseX::Types::Moose qw( ArrayRef Bool Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Role::MergeSubscription';
with 'MusicBrainz::Server::Edit::Artist';

sub edit_name { l('Merge artists') }
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

sub accept
{
    my $self = shift;
    $self->c->model('Artist')->merge(
        $self->new_entity->{id},
        [ $self->_old_ids ],
        rename => $self->data->{rename}
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
