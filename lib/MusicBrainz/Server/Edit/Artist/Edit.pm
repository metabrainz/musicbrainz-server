package MusicBrainz::Server::Edit::Artist::Edit;
use 5.10.0;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT );
use MusicBrainz::Server::Types qw( :edit_status );
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    date_closure
    merge_partial_date
);
use MusicBrainz::Server::Translation qw ( l ln );
use MusicBrainz::Server::Validation qw( normalise_strings );

use JSON::Any;
use Clone 'clone';
use Algorithm::Merge qw( diff3 );

use MooseX::Types::Moose qw( ArrayRef Int Maybe Str );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Artist';
with 'MusicBrainz::Server::Edit::CheckForConflicts';

sub edit_name { l('Edit artist') }
sub edit_type { $EDIT_ARTIST_EDIT }

sub _edit_model { 'Artist' }

sub change_fields
{
    return Dict[
        name       => Optional[Str],
        sort_name  => Optional[Str],
        type_id    => Nullable[Int],
        gender_id  => Nullable[Int],
        country_id => Nullable[Int],
        comment    => Nullable[Str],
        ipi_code   => Optional[Str],
        ipi_codes  => Optional[ArrayRef[Str]],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            name => Str
        ],
        new => change_fields(),
        old => change_fields(),
    ]
);

sub foreign_keys
{
    my ($self) = @_;
    my $relations = {};
    changed_relations($self->data, $relations, (
                          ArtistType => 'type_id',
                          Country => 'country_id',
                          Gender => 'gender_id',
                      ));
    $relations->{Artist} = [ $self->data->{entity}{id} ];

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        type       => [ qw( type_id ArtistType )],
        gender     => [ qw( gender_id Gender )],
        country    => [ qw( country_id Country )],
        name       => 'name',
        sort_name  => 'sort_name',
        ipi_code   => 'ipi_code',
        comment    => 'comment',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    $data->{artist} = $loaded->{Artist}{ $self->data->{entity}{id} }
        || Artist->new( name => $self->data->{entity}{name} );

    if (exists $self->data->{new}{begin_date}) {
        $data->{begin_date} = {
            new => PartialDate->new($self->data->{new}{begin_date}),
            old => PartialDate->new($self->data->{old}{begin_date}),
        };
    }

    if (exists $self->data->{new}{end_date}) {
        $data->{end_date} = {
            new => PartialDate->new($self->data->{new}{end_date}),
            old => PartialDate->new($self->data->{old}{end_date}),
        };
    }

    if (exists $self->data->{new}{end_date}) {
        $data->{end_date} = {
            new => PartialDate->new($self->data->{new}{end_date}),
            old => PartialDate->new($self->data->{old}{end_date}),
        };
    }

    if (exists $self->data->{new}{ipi_codes}) {
        my $ipi_changes = $self->ipi_changes (
            $self->data->{old}{ipi_codes},
            $self->data->{old}{ipi_codes},
            $self->data->{new}{ipi_codes});

        $data->{ipi_codes}->{added} = $ipi_changes->{add};
        $data->{ipi_codes}->{deleted} = $ipi_changes->{del};
    }

    return $data;
}

sub _mapping
{
    my $self = shift;

    return (
        begin_date => date_closure('begin_date'),
        end_date => date_closure('end_date'),
        ipi_codes => sub {
            my $ipis = $self->c->model('Artist')->ipi->find_by_entity_id(shift->id);
            return [ map { $_->ipi } @$ipis ];
        },
    );
}

sub allow_auto_edit
{
    my ($self) = @_;

    # Changing name or sortname is allowed if the change only affects
    # small things like case etc.
    my ($old_name, $new_name) = normalise_strings(
        $self->data->{old}{name}, $self->data->{new}{name});
    return 0 if $old_name ne $new_name;

    my ($old_sort_name, $new_sort_name) = normalise_strings(
        $self->data->{old}{sort_name}, $self->data->{new}{sort_name});
    return 0 if $old_sort_name ne $new_sort_name;

    my ($old_comment, $new_comment) = normalise_strings(
        $self->data->{old}{comment}, $self->data->{new}{comment});
    return 0 if $old_comment ne $new_comment;

    # Adding a date is automatic if there was no date yet.
    return 0 if exists $self->data->{old}{begin_date}
        and partial_date_from_row($self->data->{old}{begin_date})->format ne '';
    return 0 if exists $self->data->{old}{end_date}
        and partial_date_from_row($self->data->{old}{end_date})->format ne '';

    return 0 if exists $self->data->{old}{type_id}
        and defined($self->data->{old}{type_id}) && $self->data->{old}{type_id} != 0;

    return 0 if exists $self->data->{old}{gender_id}
        and defined($self->data->{old}{gender_id}) && $self->data->{old}{gender_id} != 0;

    return 0 if exists $self->data->{old}{country_id}
        and defined($self->data->{old}{country_id}) && $self->data->{old}{country_id} != 0;

    # FIXME: Adding IPIs should be automatic?
    if ($self->data->{old}{ipi_code}) {
        my ($old_ipi, $new_ipi) = normalise_strings($self->data->{old}{ipi_code},
                                                    $self->data->{new}{ipi_code});
        return 0 if $new_ipi ne $old_ipi;
    }

    if ($self->data->{old}{ipi_codes}) {
        warn "FIXME: Check if ipi_codes change, perhaps this is not an autoedit.\n";
    }

    return 1;
}

sub current_instance {
    my $self = shift;
    $self->c->model('Artist')->get_by_id($self->entity_id),
}

sub _edit_hash {
    my ($self, $data) = @_;
    return $self->merge_changes;
}

before initialize => sub {
    my ($self, %opts) = @_;
    die "You must specify ipi_codes" unless defined $opts{ipi_codes};
};


sub new_data {
    my $self = shift;
    my $new = clone ($self->data->{new});

    # merge_changes only looks at keys in whatever is returned from
    # new_data(), make it skip ipi_codes so we can handle that
    # seperately.
    delete $new->{ipi_codes};
    return $new;
}


sub ipi_changes
{
   my ($self, $old, $current, $new) = @_;

   # FIXME: check if these lists need to be sorted.
   my @changes = diff3([ sort @$old ], [ sort @$current ], [ sort @$new ]);

   my @add;
   my @del;

    for my $change (@changes)
    {
        given ($change->[0])
        {
            when ('c') { # c - conflict (no two are the same)
                MusicBrainz::Server::Edit::Exceptions::FailedDependency
                    ->throw('IPI codes have changed since this edit was created, and now conflict ' .
                            'with changes made in this edit.');
            }
            when ('l') { # l - left is different
                # other edit made some changes we didn't make, ignore.
            }
            when ('o') { # o - original is different
                # other edit made changes we also made, ignore.
            }
            when ('r') { # r - right is different

                # we made changes, apply.
                if (defined $change->[3])
                {
                    push @add, $change->[3];
                }
                else
                {
                    push @del, $change->[1];
                }
            }
            when ('u') { # u - unchanged
                # no changes at all.
            }
        }
    }

   return { add => \@add, del => \@del };
}


around merge_changes => sub {
    my $orig = shift;
    my $self = shift;

    my $merged = $self->$orig (@_);

    $merged->{ipi_codes} = $self->ipi_changes (
        $self->data->{old}->{ipi_codes},
        $self->c->model('Artist')->ipi->find_by_entity_id($self->entity_id),
        $self->data->{new}->{ipi_codes})
        if $self->data->{new}->{ipi_codes};

    return $merged;
};


around extract_property => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my ($property, $ancestor, $current, $new) = @_;
    given ($property) {
        when ('begin_date') {
            return merge_partial_date('begin_date' => $ancestor, $current, $new);
        }

        when ('end_date') {
            return merge_partial_date('end_date' => $ancestor, $current, $new);
        }
        default {
            return ($self->$orig(@_));
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
