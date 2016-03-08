package MusicBrainz::Server::Edit::Utils;
use strict;
use warnings;
use 5.10.0;

use JSON;
use List::MoreUtils qw( minmax uniq );
use MusicBrainz::Server::Constants qw( :edit_status :vote $AUTO_EDITOR_FLAG );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref coordinates_to_hash sanitize trim partial_date_to_hash );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;
use MusicBrainz::Server::Translation qw( N_l );
use Scalar::Util qw( blessed );
use Set::Scalar;
use Try::Tiny;

use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Barcode';
use aliased 'MusicBrainz::Server::Entity::Coordinates';

use base 'Exporter';

our @EXPORT_OK = qw(
    artist_credit_from_loaded_definition
    artist_credit_preview
    calculate_recording_merges
    changed_relations
    changed_display_data
    clean_submitted_artist_credits
    coordinate_closure
    date_closure
    time_closure
    edit_status_name
    gid_or_id
    hash_artist_credit
    hash_artist_credit_without_join_phrases
    large_spread
    merge_artist_credit
    merge_barcode
    merge_coordinates
    merge_partial_date
    merge_set
    merge_time
    merge_value
    load_artist_credit_definitions
    status_names
    verify_artist_credits
);

sub verify_artist_credits
{
    my ($c, @credits) = @_;
    my @artist_ids;
    for my $ac (grep { defined } @credits)
    {
        for (@{ $ac->{names} })
        {
            push @artist_ids, $_->{artist}->{id};
        }
    }

    my @artists = values %{ $c->model('Artist')->get_by_ids(@artist_ids) };

    if (@artists != uniq @artist_ids) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'An artist that is used in the new artist credits has been deleted'
        )
    }
}

sub date_closure
{
    my $attr = shift;
    return sub {
        my $a = shift;
        return partial_date_to_hash($a->$attr);
    };
}

sub coordinate_closure
{
    my $attr = shift;
    return sub {
        my $a = shift;
        return coordinates_to_hash($a->$attr);
    };
}

sub time_closure
{
    my $attr = shift;
    return sub {
        my $a = shift;
        return $a->$attr ? $a->$attr->strftime('%H:%M') : undef;
    };
}

sub load_artist_credit_definitions
{
    my $ac = shift;
    my @ac = @{ $ac->{names} };

    my %load;
    while (@ac) {
        my $ac_name = shift @ac;

        next unless defined $ac_name->{name} && $ac_name->{artist}->{id};

        $load{ $ac_name->{artist}->{id} } = [];
    }

    return %load;
}

sub artist_credit_from_loaded_definition
{
    my ($loaded, $definition) = @_;

    my @names;
    for my $ac_name (@{ $definition->{names} })
    {
        next unless defined $ac_name->{name} && $ac_name->{artist}->{id};

        my $ac = MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => $ac_name->{name},
            artist => $loaded->{Artist}->{ $ac_name->{artist}->{id} } ||
                Artist->new( $ac_name->{artist} )
        );

        $ac->join_phrase($ac_name->{join_phrase}) if defined $ac_name->{join_phrase};
        push @names, $ac;
    }

    return MusicBrainz::Server::Entity::ArtistCredit->new(
        names => \@names
    );
}

sub artist_credit_preview
{
    my ($loaded, $definition) = @_;

    my @names;
    for my $ac_name (@{ $definition->{names} })
    {
        next unless defined $ac_name->{name};

        my $ac = MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => $ac_name->{name} );

        if (my $loaded_artist = defined($ac_name->{artist}{id}) &&
                                  $loaded->{Artist}->{ $ac_name->{artist}->{id} })
        {
            $ac->artist($loaded_artist);
        }
        elsif ($ac_name->{artist})
        {
            delete $ac_name->{artist}->{id};
            delete $ac_name->{artist}->{gid} unless $ac_name->{artist}->{gid};
            $ac->artist(Artist->new( $ac_name->{artist} ));
        }

        $ac->join_phrase($ac_name->{join_phrase}) if defined $ac_name->{join_phrase};

        push @names, $ac;
    }

    return MusicBrainz::Server::Entity::ArtistCredit->new(
        names => \@names
    );
}

sub clean_submitted_artist_credits
{
    my $ac = shift;

    $ac = artist_credit_to_ref($ac)
        if ref $ac eq 'MusicBrainz::Server::Entity::ArtistCredit';

    # Remove empty artist credits.
    my @delete;
    my @names = @{ $ac->{names} };
    for (0..$#names)
    {
        my $part = $names[$_];
        if (ref $part eq 'HASH')
        {
            $part->{artist}->{name} = trim($part->{artist}->{name}) if defined $part->{artist}->{name};
            $part->{name} = trim($part->{name}) if defined $part->{name};

            push @delete, $_ unless (defined $part->{artist}->{name} || defined $part->{name});

            # MBID is only used for display purposes so remove it (we
            # use the id in edits, and that should determine if an
            # artist changed in Edit::WithDifferences).
            delete $part->{artist}->{gid};

            # Fill in the artist credit from the artist name if no artist credit
            # was submitted.
            $part->{name} //= $part->{artist}->{name};

            # MBS-3226, Fill in the artist name from the artist credit if the user
            # didn't enter an artist name.
            $part->{artist}->{name} //= $part->{name};

            # Set to empty string if join_phrase is undef.
            $part->{join_phrase} //= '';
            $part->{join_phrase} = sanitize($part->{join_phrase});

            # Remove trailing whitespace from a trailing join phrase.
            $part->{join_phrase} =~ s/\s+$// if $_ == $#names;
        }
        elsif (! $part)
        {
            push @delete, $_;
        }
    }

    for (@delete)
    {
        delete $ac->{names}->[$_];
    }

    # The preview should also not be considered when comparing artists in
    # Edit::WithDifferences.
    delete $ac->{preview};

    return $ac;
}

sub changed_relations
{
    my ($data, $relations, %mapping) = @_;
    while (my ($model, $field) = each %mapping) {
        next unless exists $data->{new}{$field};
        $relations->{$model} ||= {};

        $relations->{$model}->{ $data->{new}{$field} } = []
            if defined $data->{new}{$field};

        $relations->{$model}->{ $data->{old}{$field} } = []
            if defined $data->{old}{$field};
    }

    return $relations;
}

sub changed_display_data
{
    my ($data, $loaded, %mapping) = @_;
    my $display = {};
    while (my ($tt_field, $accessor) = each %mapping) {
        my ($field, $model) = ref $accessor ? @$accessor : ( $accessor );
        next unless exists $data->{new}{$field};
        my ($old, $new) = ($data->{old}{$field}, $data->{new}{$field});
        $display->{$tt_field} = {
            new => defined $new ? (defined $model ? $loaded->{$model}->{$new} : $new) : undef,
            old => defined $old ? (defined $model ? $loaded->{$model}->{$old} : $old) : undef,
        }
    }

    return $display;
}

our @STATUS_MAP = (
    [ $STATUS_OPEN         => N_l('Open') ],
    [ $STATUS_APPLIED      => N_l('Applied') ],
    [ $STATUS_FAILEDVOTE   => N_l('Failed vote') ],
    [ $STATUS_FAILEDDEP    => N_l('Failed dependency') ],
    [ $STATUS_ERROR        => N_l('Error') ],
    [ $STATUS_FAILEDPREREQ => N_l('Failed prerequisite') ],
    [ $STATUS_NOVOTES      => N_l('No votes') ],
    [ $STATUS_DELETED      => N_l('Cancelled') ],
);
our %STATUS_NAMES = map { @$_ } @STATUS_MAP;

sub edit_status_name
{
    my ($status) = @_;
    return $STATUS_NAMES{ $status };
}

sub gid_or_id {
    my $entity = shift;

    return $entity->gid // $entity->id if blessed($entity);
    return $entity->{gid} // $entity->{id};
}

sub status_names
{
    return \@STATUS_MAP;
}

sub hash_artist_credit {
    return _hash_artist_credit(shift)
}

sub hash_artist_credit_without_join_phrases {
    return _hash_artist_credit(shift, 1)
}

sub _hash_artist_credit {
    my ($artist_credit, $visible_only) = @_;
    return join(', ', map {
        '[' .
            join(',',
                 $_->{name},
                 $_->{artist}{id} // -1)
            . (!$visible_only ? ',' . $_->{join_phrase} // '' : '')
            .
        ']'
    } @{ $artist_credit->{names} });
}

=method merge_artist_credit

Merge artist credits from ancestor, current and new data, using a canonical hash
(which allows minor variations in data if they all really represent the same
artist credit).

=cut

sub merge_artist_credit {
    my ($c, $ancestor, $current, $new) = @_;
    $c->model('ArtistCredit')->load($current)
        unless $current->artist_credit;

    my $an = hash_artist_credit($ancestor->{artist_credit});
    my $cu = hash_artist_credit(artist_credit_to_ref($current->artist_credit));
    my $ne = hash_artist_credit($new->{artist_credit});
    return (
        [$an, $ancestor->{artist_credit}],
        [$cu, artist_credit_to_ref($current->artist_credit)],
        [$ne, $new->{artist_credit}]
    );
}

=method merge_partial_date

Merge partial dates, using a canonical hash and allowing for slightly different
representations of data.

=cut

sub merge_partial_date {
    my ($name, $ancestor, $current, $new) = @_;

    return (
        [ PartialDate->new($ancestor->{$name})->format, $ancestor->{$name} ],
        [ $current->$name->format, partial_date_to_hash($current->$name) ],
        [ PartialDate->new($new->{$name})->format, $new->{$name} ],
    );
}

=method merge_coordinates

Merge coordinates, using a canonical hash and allowing for slightly different representations of data.

=cut

sub merge_coordinates {
    my ($name, $ancestor, $current, $new) = @_;

    return (
        [ defined $ancestor->{$name} ? Coordinates->new($ancestor->{$name})->format : '', $ancestor->{$name} ],
        [ defined $current->$name ? $current->$name->format : '', coordinates_to_hash($current->$name) ],
        [ defined $new->{$name} ? Coordinates->new($new->{$name})->format : '', $new->{$name} ],
    );
}

=method merge_barcode

Merge barcodes, using the formatted representation as the hash key.

=cut

sub merge_barcode {
    my ($ancestor, $current, $new) = @_;

    return (
        [ Barcode->new($ancestor->{barcode})->format, $ancestor->{barcode} ],
        [ $current->barcode->format, $current->barcode->code ],
        [ Barcode->new($new->{barcode})->format, $new->{barcode} ],
    );
}

sub merge_time {
    my ($name, $ancestor, $current, $new) = @_;

    $current = $current->$name ? $current->$name->strftime('%H:%M') : undef;
    return (
        [$ancestor->{$name}, $ancestor->{$name}],
        [$current, $current],
        [$new->{$name}, $new->{$name}],
    );
}

sub merge_value {
    my $v = shift;
    state $json = JSON->new->allow_blessed->canonical;
    return [ ref($v) ? $json->encode($v) : defined($v) ? "'$v'" : 'undef', $v ];
}

sub merge_set {
    my ($old, $current, $new) = @_;

    my $old_set     = Set::Scalar->new(@$old);
    my $current_set = Set::Scalar->new(@$current);
    my $new_set     = Set::Scalar->new(@$new);

    # An element can be present or absent from each set.
    # There are these seven possible cases:
    #   OCN: never changed
    #   O-N: removed by previous edit, we shouldn't undo that (*)
    #   O--: has already been deleted by previous edit
    #   -CN: has already been added by previous edit
    #   -C-: has been added by previous edit (*)
    #   --N: add completely new element
    #   OC-: delete elements that weren't touched by previous edit
    # (*) marks the cases where the intended result diverges from N.

    my $result_set = ($new_set
        - ($old_set - $current_set))  # leave out those removed in the meantime
        + ($current_set - $old_set);  # ... and include those added

    return $result_set->members;
}

sub calculate_recording_merges {
    my ($new, $old) = @_;
    my $recording_merges = [];
    for my $medium ($new->all_mediums) {
        for my $track ($medium->all_tracks) {
            try {
                my @sources;
                for my $source_medium (map { $_->all_mediums } @{ $old }) {
                    if ($source_medium->position == $medium->position) {
                        push @sources, map { $_->recording }
                            grep { $_->position == $track->position } $source_medium->all_tracks;
                    }
                }
                @sources = grep { $_->id != $track->recording->id } @sources;
                push(@$recording_merges, {
                         medium => $medium->position,
                         track => $track->number,
                         sources => \@sources,
                         destination => $track->recording}) if scalar @sources;
            };
        }
    }
    return $recording_merges;
}

sub large_spread {
    my @lengths = grep { defined $_ } @_;
    return unless @lengths;

    my ($min, $max) = minmax(@lengths);
    return 1 if $max - $min >= 15*1000; # 15 seconds
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles
Copyright (C) 2011 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
