package MusicBrainz::Server::Edit::Release::Edit;
use Moose;
use 5.10.0;

use MooseX::Types::Moose qw( Int Str Maybe );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Barcode';
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT );
use MusicBrainz::Server::Data::Utils qw(
    artist_credit_to_ref
    partial_date_to_hash
    partial_date_from_row
);
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    artist_credit_from_loaded_definition
    changed_relations
    changed_display_data
    clean_submitted_artist_credits
    load_artist_credit_definitions
    merge_artist_credit
    merge_barcode
    merge_partial_date
    verify_artist_credits
);
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( normalise_strings );

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::CheckForConflicts';

use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_type { $EDIT_RELEASE_EDIT }
sub edit_name { l('Edit release') }
sub _edit_model { 'Release' }
sub release_id { shift->data->{entity}{id} }

sub change_fields
{
    return Dict[
        name             => Optional[Str],
        artist_credit    => Optional[ArtistCreditDefinition],
        release_group_id => Optional[Int],
        comment          => Optional[Maybe[Str]],
        date             => Nullable[PartialDateHash],

        barcode          => Nullable[Str],
        country_id       => Nullable[Int],
        language_id      => Nullable[Int],
        packaging_id     => Nullable[Int],
        script_id        => Nullable[Int],
        status_id        => Nullable[Int],
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

around _build_related_entities => sub {
    my ($orig, $self) = @_;

    my $related = $self->$orig;
    if (exists $self->data->{new}{artist_credit}) {
        my %new = load_artist_credit_definitions($self->data->{new}{artist_credit});
        my %old = load_artist_credit_definitions($self->data->{old}{artist_credit});
        push @{ $related->{artist} }, keys(%new), keys(%old);
    }

    if ($self->data->{new}{release_group_id}) {
        push @{ $related->{release_group} },
            map { $self->data->{$_}{release_group_id} } qw( old new )
    }

    return $related;
};

sub foreign_keys
{
    my ($self) = @_;
    my $relations = {};
    changed_relations($self->data, $relations, (
        ReleasePackaging => 'packaging_id',
        ReleaseStatus    => 'status_id',
        Country          => 'country_id',
        Language         => 'language_id',
        Script           => 'script_id',
    ));

    if (exists $self->data->{new}{artist_credit}) {
        $relations->{Artist} = {
            map {
                load_artist_credit_definitions($self->data->{$_}{artist_credit})
            } qw( new old )
        }
    }

    $relations->{Release} = {
        $self->data->{entity}{id} => [ 'ArtistCredit' ]
    };

    if ($self->data->{new}{release_group_id}) {
        $relations->{ReleaseGroup} = {
            $self->data->{new}{release_group_id} => [ 'ArtistCredit' ],
            $self->data->{old}{release_group_id} => [ 'ArtistCredit' ]
        }
    }

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        packaging => [ qw( packaging_id ReleasePackaging )],
        status    => [ qw( status_id ReleaseStatus )],
        group     => [ qw( release_group_id ReleaseGroup )],
        country   => [ qw( country_id Country )],
        language  => [ qw( language_id Language )],
        script    => [ qw( script_id Script )],
        name      => 'name',
        comment   => 'comment',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    if (exists $self->data->{new}{artist_credit}) {
        $data->{artist_credit} = {
            new => artist_credit_from_loaded_definition($loaded, $self->data->{new}{artist_credit}),
            old => artist_credit_from_loaded_definition($loaded, $self->data->{old}{artist_credit})
        }
    }

    if (exists $self->data->{new}{barcode}) {
        $data->{barcode} = {
            new => Barcode->new($self->data->{new}{barcode}),
            old => Barcode->new($self->data->{old}{barcode}),
        };
    }

    if (exists $self->data->{new}{date}) {
        $data->{date} = {
            new => partial_date_from_row($self->data->{new}{date}),
            old => partial_date_from_row($self->data->{old}{date}),
        };
    }

    $data->{release} = $loaded->{Release}{ $self->data->{entity}{id} }
        || Release->new( name => $self->data->{entity}{name} );

    return $data;
}

sub _mapping
{
    return (
        date => sub { partial_date_to_hash(shift->date) },
        artist_credit => sub { clean_submitted_artist_credits (artist_credit_to_ref(shift->artist_credit)) },
        barcode => sub { shift->barcode->code }
    );
}

before 'initialize' => sub
{
    my ($self, %opts) = @_;
    my $release = $opts{to_edit} or return;

    if (exists $opts{artist_credit})
    {
        $opts{artist_credit} = clean_submitted_artist_credits ($opts{artist_credit});
    }

    if (exists $opts{artist_credit} && !$release->artist_credit) {
        $self->c->model('ArtistCredit')->load($release);
    }
};

around extract_property => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my ($property, $ancestor, $current, $new) = @_;
    given ($property) {
        when ('artist_credit') {
            return merge_artist_credit($self->c, $ancestor, $current, $new);
        }

        when ('date') {
            return merge_partial_date('date' => $ancestor, $current, $new);
        }

        when ('barcode') {
            return merge_barcode ($ancestor, $current, $new);
        }

        default {
            return ($self->$orig(@_));
        }
    }
};

sub current_instance {
    my $self = shift;
    return $self->c->model('Release')->get_by_id($self->entity_id);
}

sub _edit_hash
{
    my ($self, $data) = @_;

    $data = $self->merge_changes;
    if ($data->{artist_credit}) {
        $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert($data->{artist_credit});
    }

    return $data;
}

before accept => sub {
    my ($self) = @_;

    verify_artist_credits($self->c, $self->data->{new}{artist_credit});

    if ($self->data->{new}{release_group_id} &&
        $self->data->{new}{release_group_id} != $self->data->{old}{release_group_id} &&
       !$self->c->model('ReleaseGroup')->get_by_id($self->data->{new}{release_group_id})) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'The new release group does not exist.'
        );
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

    return 0 if defined $self->data->{old}{packaging_id};
    return 0 if defined $self->data->{old}{status_id};
    return 0 if defined $self->data->{old}{barcode};
    return 0 if defined $self->data->{old}{country_id};
    return 0 if defined $self->data->{old}{language_id};
    return 0 if defined $self->data->{old}{script_id};

    return 0 if exists $self->data->{old}{date} &&
        partial_date_from_row($self->data->{old}{date}) ne '';

    return 0 if exists $self->data->{old}{release_group_id};
    return 0 if exists $self->data->{new}{artist_credit};

    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
