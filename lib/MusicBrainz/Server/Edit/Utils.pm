package MusicBrainz::Server::Edit::Utils;

use strict;
use warnings;

use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash artist_credit_to_ref );
use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;
use MusicBrainz::Server::Types qw( :edit_status :vote $AUTO_EDITOR_FLAG );

use aliased 'MusicBrainz::Server::Entity::Artist';

use base 'Exporter';

our @EXPORT_OK = qw(
    artist_credit_from_loaded_definition
    artist_credit_preview
    changed_relations
    changed_display_data
    clean_submitted_artist_credits
    date_closure
    edit_status_name
    load_artist_credit_definitions
    status_names
);

sub date_closure
{
    my $attr = shift;
    return sub {
        my $a = shift;
        return partial_date_to_hash($a->$attr);
    };
}

sub load_artist_credit_definitions
{
    my $ac = shift;
    my @ac = @{ $ac->{names} };

    my %load;
    while(@ac) {
        my $ac_name = shift @ac;

        next unless $ac_name->{name} && $ac_name->{artist}->{id};

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
        next unless $ac_name->{name} && $ac_name->{artist}->{id};

        my $ac = MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => $ac_name->{name},
            artist => $loaded->{Artist}->{ $ac_name->{artist}->{id} } ||
                Artist->new( $ac_name->{artist} )
        );

        $ac->join_phrase ($ac_name->{join_phrase}) if $ac_name->{join_phrase};
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
        next unless $ac_name->{name};

        my $ac = MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => $ac_name->{name} );

        $ac->artist(
            $loaded->{Artist}->{ $ac_name->{artist}->{id} } ||
            Artist->new( $ac_name->{artist} ) ) if $ac_name->{artist};

        $ac->join_phrase ($ac_name->{join_phrase}) if $ac_name->{join_phrase};

        push @names, $ac;
    }

    return MusicBrainz::Server::Entity::ArtistCredit->new(
        names => \@names
    );
}

sub clean_submitted_artist_credits
{
    my $ac = shift;

    return artist_credit_to_ref ($ac)
        if ref $ac eq 'MusicBrainz::Server::Entity::ArtistCredit';

    # Remove empty artist credits.
    my @delete;
    my @names = @{ $ac->{names} };
    for (0..$#names)
    {
        my $part = $names[$_];
        if (ref $part eq 'HASH')
        {
            push @delete, $_ unless ($part->{artist}->{id} || $part->{artist}->{name} || $part->{name});
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

our %STATUS_NAMES = (
    $STATUS_OPEN         => 'Open',
    $STATUS_APPLIED      => 'Applied',
    $STATUS_FAILEDVOTE   => 'Failed vote',
    $STATUS_FAILEDDEP    => 'Failed dependency',
    $STATUS_ERROR        => 'Error',
    $STATUS_FAILEDPREREQ => 'Failed prerequisite',
    $STATUS_NOVOTES      => 'No votes',
    $STATUS_TOBEDELETED  => 'Due to be cancelled',
    $STATUS_DELETED      => 'Cancelled',
);

sub edit_status_name
{
    my ($status) = @_;
    return $STATUS_NAMES{ $status };
}

sub status_names
{
    return %STATUS_NAMES
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
