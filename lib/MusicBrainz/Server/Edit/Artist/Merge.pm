package MusicBrainz::Server::Edit::Artist::Merge;
use utf8;
use Moose;

use MooseX::Types::Moose qw( ArrayRef Bool Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE $EDITOR_MODBOT );
use MusicBrainz::Server::Data::Utils qw(
    boolean_to_json
    conditional_merge_column_query
    localized_note
);
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

    my $new_id = $self->new_entity->{id};
    my @old_ids = $self->_old_ids;
    my $all_ids = [$new_id, @old_ids];

    my (undef, $dropped_columns) = $self->c->model('Artist')->merge(
        $new_id,
        \@old_ids,
        rename => $self->data->{rename}
    );

    if ($dropped_columns->{type}) {
        my $dropped_type =
            $self->c->model('ArtistType')->get_by_id($dropped_columns->{type});

        $self->c->model('EditNote')->add_note(
            $self->id => {
                editor_id => $EDITOR_MODBOT,
                text => localized_note(
                    'The “{artist_type}” type has not been added to the ' .
                    'destination artist because it conflicted with the ' .
                    'gender setting of one of the artists here. Group ' .
                    'artists cannot have a gender.',
                    vars => {
                        artist_type => localized_note(
                            $dropped_type->name,
                            function => 'lp',
                            domain => 'attributes',
                            args => ['artist_type'],
                        ),
                    },
                ),
            },
        );
    }

    if ($dropped_columns->{gender}) {
        my $dropped_gender =
            $self->c->model('Gender')->get_by_id($dropped_columns->{gender});

        $self->c->model('EditNote')->add_note(
            $self->id => {
                editor_id => $EDITOR_MODBOT,
                text => localized_note(
                    'The “{gender}” gender has not been added to the ' .
                    'destination artist because it conflicted with the ' .
                    'group type of one of the artists here. Group artists ' .
                    'cannot have a gender.',
                    vars => {
                        gender => localized_note(
                            $dropped_gender->name,
                            function => 'lp',
                            domain => 'attributes',
                            args => ['gender'],
                        ),
                    },
                ),
            },
        );
    }
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
