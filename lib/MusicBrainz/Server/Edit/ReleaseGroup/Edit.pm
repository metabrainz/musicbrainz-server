package MusicBrainz::Server::Edit::ReleaseGroup::Edit;
use 5.10.0;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_EDIT );
use MusicBrainz::Server::Data::Utils qw(
    artist_credit_to_ref
    partial_date_to_hash
);
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    artist_credit_from_loaded_definition
    changed_display_data
    changed_relations
    load_artist_credit_definitions
    merge_artist_credit
    merge_value
    verify_artist_credits
);
use MusicBrainz::Server::Translation qw ( N_l );
use MusicBrainz::Server::Validation qw( normalise_strings );

use MooseX::Types::Moose qw( ArrayRef Maybe Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use Scalar::Util qw( looks_like_number );

use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities';
with 'MusicBrainz::Server::Edit::ReleaseGroup';
with 'MusicBrainz::Server::Edit::CheckForConflicts';

sub edit_type { $EDIT_RELEASEGROUP_EDIT }
sub edit_name { N_l("Edit release group") }
sub _edit_model { 'ReleaseGroup' }
sub release_group_id { shift->data->{entity}{id} }

around _build_related_entities => sub {
    my ($orig, $self, @args) = @_;
    my %rel = %{ $self->$orig(@args) };
    if ($self->data->{new}{artist_credit}) {
        my %new = load_artist_credit_definitions($self->data->{new}{artist_credit});
        my %old = load_artist_credit_definitions($self->data->{old}{artist_credit});
        push @{ $rel{artist} }, keys(%new), keys(%old);
    }

    return \%rel;
};

sub change_fields
{
    return Dict[
        name => Optional[Str],
        type_id => Nullable[Int],
        artist_credit => Optional[ArtistCreditDefinition],
        comment => Nullable[Str],
        secondary_type_ids => Optional[ArrayRef[Int]]
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            name => Str
        ],
        new => change_fields(),
        old => change_fields()
    ]
);

sub foreign_keys
{
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations,
        ReleaseGroupType => 'type_id',
    );

    if (exists $self->data->{new}{artist_credit}) {
        $relations->{Artist} = {
            map {
                load_artist_credit_definitions($self->data->{$_}{artist_credit})
            } qw( new old )
        }
    }

    $relations->{ReleaseGroup} = {
        $self->data->{entity}{id} => [ 'ArtistCredit' ]
    };

    $relations->{ReleaseGroupSecondaryType} = [
        map { @{ $self->data->{$_}{secondary_type_ids} || [] } } qw( old new )
    ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        name    => 'name',
        comment => 'comment',
        type    => [ qw( type_id ReleaseGroupType ) ],
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    if (exists $self->data->{new}{artist_credit}) {
        $data->{artist_credit} = {
            new => artist_credit_from_loaded_definition($loaded, $self->data->{new}{artist_credit}),
            old => artist_credit_from_loaded_definition($loaded, $self->data->{old}{artist_credit})
        }
    }

    $data->{release_group} = $loaded->{ReleaseGroup}{
        $self->data->{entity}{id}
    } || ReleaseGroup->new( name => $self->data->{entity}{name} );

    $data->{secondary_types} = {
        map {
            $_ => join(' + ', map { $loaded->{ReleaseGroupSecondaryType}{$_}->name }
                           @{ $self->data->{$_}{secondary_type_ids} })
        } qw( old new )
    };

    return $data;
}

sub _mapping
{
    return (
        artist_credit => sub {
            return artist_credit_to_ref(shift->artist_credit, []);
        },
        secondary_type_ids => sub {
            return [ map { $_->id } shift->all_secondary_types ]
        },
        type_id => 'primary_type_id'
    );
}

around initialize => sub
{
    my $orig = shift;
    my ($self, %opts) = @_;
    my $release_group = $opts{to_edit} or return;
    if (exists $opts{artist_credit} && !$release_group->artist_credit) {
        $self->c->model('ArtistCredit')->load($release_group);
    }
    $opts{type_id} = delete $opts{primary_type_id};

    $opts{secondary_type_ids} = [
        grep { looks_like_number($_) } @{ $opts{secondary_type_ids} }
    ] if $opts{secondary_type_ids};

    $self->$orig(%opts);
};

around extract_property => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my ($property, $ancestor, $current, $new) = @_;
    given ($property) {
        when ('artist_credit') {
            return merge_artist_credit($self->c, $ancestor, $current, $new);
        }
        when ('type_id') {
            return (
                merge_value($ancestor->{type_id}),
                merge_value($current->primary_type_id),
                merge_value($new->{type_id})
            )
        }
        when ('secondary_type_ids') {
            my $type_list_gen = sub {
                my $type = shift;
                return [ join(',', sort @$type), $type ];
            };
            return (
                $type_list_gen->( $ancestor->{secondary_type_ids} ),
                $type_list_gen->( [ map { $_->id } $current->all_secondary_types ] ),
                $type_list_gen->( $new->{secondary_type_ids} ),
            )
        }
        default {
            return $self->$orig(@_);
        }
    }
};

sub current_instance {
    my $self = shift;
    my $rg = $self->c->model('ReleaseGroup')->get_by_id($self->entity_id);
    $self->c->model('ReleaseGroupSecondaryType')->load_for_release_groups($rg);
    return $rg;
}

sub _edit_hash
{
    my ($self, $data) = @_;
    $data = $self->merge_changes;
    $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert($data->{artist_credit})
        if (exists $data->{artist_credit});
    $data->{primary_type_id} = delete $data->{type_id}
        if exists $data->{type_id};
    return $data;
}

before accept => sub {
    my ($self) = @_;

    verify_artist_credits($self->c, $self->data->{new}{artist_credit});

    if (my $type_id = $self->data->{new}{type_id}) {
        if (!$self->c->model('ReleaseGroupType')->get_by_id($type_id)) {
            MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
                "This edit changes the release group's primary type to a type that no longer exists."
            );
        }
    }
};

sub allow_auto_edit
{
    my $self = shift;

    my ($old_name, $new_name) = normalise_strings($self->data->{old}{name},
                                                  $self->data->{new}{name});
    return 0 if $old_name ne $new_name;

    my ($old_comment, $new_comment) = normalise_strings(
        $self->data->{old}{comment}, $self->data->{new}{comment});
    return 0 if $old_comment ne $new_comment;

    return 0 if defined $self->data->{old}{type_id};

    return 0 if exists $self->data->{new}{artist_credit};

    return 0 if $self->data->{old}{secondary_type_ids}
        && @{ $self->data->{old}{secondary_type_ids} };

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
