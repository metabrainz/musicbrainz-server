package MusicBrainz::Server::Edit::Release::Edit;
use Moose;
use 5.10.0;

use MooseX::Types::Moose qw( ArrayRef Int Str Maybe );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Barcode';
use Clone 'clone';
use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_CREATE
    $EDIT_RELEASE_EDIT
);
use MusicBrainz::Server::Data::Utils qw(
    partial_date_to_hash
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
    verify_artist_credits
);
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

no if $] >= 5.018, warnings => 'experimental::smartmatch';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Role::EditArtistCredit';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities';
with 'MusicBrainz::Server::Edit::Release';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Role::AllowAmending' => {
    create_edit_type => $EDIT_RELEASE_CREATE,
    entity_type => 'release',
};

use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_type { $EDIT_RELEASE_EDIT }
sub edit_name { N_l('Edit release') }
sub _edit_model { 'Release' }
sub release_id { shift->data->{entity}{id} }
sub edit_template_react { 'EditRelease' }

sub change_fields
{
    return Dict[
        name             => Optional[Str],
        artist_credit    => Optional[ArtistCreditDefinition],
        release_group_id => Optional[Int],
        comment          => Optional[Maybe[Str]],
        barcode          => Nullable[Str],
        language_id      => Nullable[Int],
        packaging_id     => Nullable[Int],
        script_id        => Nullable[Int],
        status_id        => Nullable[Int],
        events           => Optional[ArrayRef[Dict[
          country_id => Nullable[Int],
          date => Nullable[PartialDateHash],
        ]]]
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            gid => Optional[Str],
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

    $relations->{Area} = [
        map { $_->{country_id} }
        map { @{ $self->data->{$_}{events} // [] } }
        qw( old new )
    ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        packaging       => [ qw( packaging_id ReleasePackaging )],
        status          => [ qw( status_id ReleaseStatus )],
        release_group   => [ qw( release_group_id ReleaseGroup )],
        language        => [ qw( language_id Language )],
        script          => [ qw( script_id Script )],
        name            => 'name',
        comment         => 'comment',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    if (exists $self->data->{new}{artist_credit}) {
        $data->{artist_credit} = {
            new => to_json_object(artist_credit_from_loaded_definition($loaded, $self->data->{new}{artist_credit})),
            old => to_json_object(artist_credit_from_loaded_definition($loaded, $self->data->{old}{artist_credit}))
        }
    }

    if (exists $self->data->{new}{barcode}) {
        $data->{barcode} = {
            new => $self->data->{new}{barcode},
            old => $self->data->{old}{barcode},
        };
    }

    if (exists $data->{packaging}) {
        $data->{packaging}{old} = to_json_object($data->{packaging}{old});
        $data->{packaging}{new} = to_json_object($data->{packaging}{new});
    }

    if (exists $data->{status}) {
        $data->{status}{old} = to_json_object($data->{status}{old});
        $data->{status}{new} = to_json_object($data->{status}{new});
    }

    if (exists $data->{language}) {
        $data->{language}{old} = to_json_object($data->{language}{old});
        $data->{language}{new} = to_json_object($data->{language}{new});
    }

    if (exists $data->{script}) {
        $data->{script}{old} = to_json_object($data->{script}{old});
        $data->{script}{new} = to_json_object($data->{script}{new});
    }

    if (exists $data->{release_group}) {
        $data->{release_group}{old} = to_json_object($data->{release_group}{old});
        $data->{release_group}{new} = to_json_object($data->{release_group}{new});
    }

    if (exists $self->data->{new}{events}) {
        my $inflate_event = sub {
            my $event = shift;
            my $country_id = $event->{country_id};
            return MusicBrainz::Server::Entity::ReleaseEvent->new(
                country_id => $country_id,
                defined $country_id ? (country => $loaded->{Area}{$country_id}) : (),
                date => MusicBrainz::Server::Entity::PartialDate->new_from_row($event->{date}),
            )
        };

        $data->{events} = {
            map {
                $_ => to_json_array([
                    map { $inflate_event->($_) } @{ $self->data->{$_}{events} }
                ])
            } qw( old new )
        };
    }

    $data->{release} = to_json_object(
        $loaded->{Release}{ $self->data->{entity}{id} } ||
        Release->new( name => $self->data->{entity}{name} )
    );

    return $data;
}

sub _mapping
{
    my $self = shift;
    return (
        artist_credit => sub {
            clean_submitted_artist_credits(shift->artist_credit)
        },
        barcode => sub { shift->barcode->code },
        events => sub {
            my $id = shift->id;
            my $events = $self->c->model('Release')->find_release_events($id);
            return [ map +{
                date => partial_date_to_hash($_->date),
                country_id => $_->country_id
            }, @{ $events->{$id} } ];
        }
    );
}

around 'initialize' => sub
{
    my ($orig, $self, %opts) = @_;
    return unless $opts{to_edit};

    $self->check_event_countries($opts{events} // []);

    $self->$orig(%opts);
};

around extract_property => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my ($property, $ancestor, $current, $new) = @_;
    given ($property) {
        when ('artist_credit') {
            return merge_artist_credit($self->c, $ancestor, $current, $new);
        }

        when ('barcode') {
            return merge_barcode($ancestor, $current, $new);
        }

        default {
            return ($self->$orig(@_));
        }
    }
};

sub current_instance {
    my $self = shift;
    my $release = $self->c->model('Release')->get_by_id($self->entity_id);
    $self->c->model('ArtistCredit')->load($release);
    $self->c->model('Release')->load_release_events($release);
    return $release;
}

sub _edit_hash
{
    my ($self, $data) = @_;

    $data = $self->merge_changes;
    if ($data->{artist_credit}) {
        $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert($data->{artist_credit});
    }

    if (exists $data->{events}) {
        $data->{events} = [
            grep {
                # The new release events for a release must contain either a
                # country_id or at least one date field.
                $_->{country_id} ||
                    (exists($_->{date}) && (
                        $_->{date}{year} ||
                        $_->{date}{month} ||
                        $_->{date}{day}))
            }
            @{ $data->{events} }
        ];
    }

    $data->{comment} //= '' if exists $data->{comment};

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

around allow_auto_edit => sub {
    my ($orig, $self, @args) = @_;

    return 1 if $self->can_amend($self->release_id);

    return 0 if defined $self->data->{old}{packaging_id};
    return 0 if defined $self->data->{old}{status_id};
    return 0 if defined $self->data->{old}{barcode};
    return 0 if defined $self->data->{old}{language_id};
    return 0 if defined $self->data->{old}{script_id};

    my $events = $self->data->{old}{events};
    return 0 if defined $events && scalar @{$events};

    return 0 if exists $self->data->{old}{release_group_id};

    return $self->$orig(@args);
};

sub restore {
    my ($self, $data) = @_;
    if (exists $data->{new}{date} || exists $data->{new}{country_id}) {
        $data->{$_}{events} = [
            {
                exists $data->{$_}{date}
                    ? (date => delete $data->{$_}{date}) : (),

                exists $data->{$_}{country_id}
                    ? (country_id => delete $data->{$_}{country_id}) : ()
            }
        ] for qw( old new );
    }

    $self->data($data);
}

around new_data => sub {
    my $orig = shift;
    my $self = shift;
    my $new = clone($self->$orig(@_));

    delete $new->{events};
    return $new;
};

around merge_changes => sub {
    my $orig = shift;
    my $self = shift;

    my $merged = $self->$orig(@_);

    $merged->{events} = $self->data->{new}{events}
        if exists $self->data->{new}{events};

    return $merged;
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;
