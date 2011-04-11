package MusicBrainz::Server::Edit::Utils;

use strict;
use warnings;

use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash artist_credit_to_ref );
use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Types qw( :edit_status :vote $AUTO_EDITOR_FLAG );

use aliased 'MusicBrainz::Server::Entity::Artist';

use base 'Exporter';

our @EXPORT_OK = qw(
    date_closure
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
    artist_credit_preview
    clean_submitted_artist_credits
    changed_relations
    changed_display_data
    edit_status_name
    status_names
    verify_artist_credits
);

sub verify_artist_credits
{
    my ($c, @credits) = @_;
    my @artist_ids;
    for my $ac (grep { defined } @credits) {
        while(@$ac) {
            my $artist = shift @$ac;
            my $join   = shift @$ac;

            push @artist_ids, $artist->{artist};
        }
    }

    my @artists = values %{ $c->model('Artist')->get_by_ids(@artist_ids) };

    if (@artists != @artist_ids) {
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

sub load_artist_credit_definitions
{
    my $ac = shift;
    my @ac = @$ac;

    my %load;
    while(@ac) {
        my $artist = shift @ac;
        my $join   = shift @ac;

        next unless $artist->{name} && $artist->{artist};

        $load{ $artist->{artist} } = [];
    }

    return %load;
}

sub artist_credit_from_loaded_definition
{
    my ($loaded, $definition) = @_;

    my @names;
    my @def = @$definition;

    while (@def)
    {
        my $artist = shift @def;
        my $join = shift @def;

        next unless $artist->{name} && $artist->{artist};

        my $ac = MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => $artist->{name},
            artist => $loaded->{Artist}->{ $artist->{artist} } ||
                Artist->new( name => $artist->{name} )
        );
        $ac->join_phrase($join) if $join;

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
    my @def = @$definition;

    while (@def)
    {
        my $artist = shift @def;
        my $join = shift @def;

        next unless $artist->{name};

        my $ac = MusicBrainz::Server::Entity::ArtistCreditName->new(
            name => $artist->{name});

        $ac->artist(
            $loaded->{Artist}->{ $artist->{artist} }
                || Artist->new( name => $artist->{name} )
        ) if $artist->{artist};
        $ac->join_phrase($join) if $join;

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
    my $max = scalar @{ $ac } - 1;
    for (0..$max)
    {
        my $part = $ac->[$_];
        if (ref $part eq 'HASH')
        {
            push @delete, $_ unless ($part->{artist} || $part->{name});
        }
        elsif (! $part)
        {
            push @delete, $_;
        }
    }

    for (@delete)
    {
        delete $ac->[$_];
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
