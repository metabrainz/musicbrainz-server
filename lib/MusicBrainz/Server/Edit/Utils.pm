package MusicBrainz::Server::Edit::Utils;

use strict;
use warnings;

use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash );
use MusicBrainz::Server::Entity::ArtistCredit;
use MusicBrainz::Server::Entity::ArtistCreditName;
use MusicBrainz::Server::Types qw( :edit_status :vote $AUTO_EDITOR_FLAG );

use base 'Exporter';

our @EXPORT_OK = qw(
    date_closure
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
    changed_relations
    changed_display_data
    edit_status_name
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
    return map { $_->{artist} => [] } map { @{ $_ } } @_;
}

sub artist_credit_from_loaded_definition
{
    my ($loaded, $definition) = @_;
    return MusicBrainz::Server::Entity::ArtistCredit->new(
        names => [
            map {
                MusicBrainz::Server::Entity::ArtistCreditName->new(
                    name => $_->{name},
                    artist => $loaded->{Artist}->{ $_->{artist} }
                );
            } @$definition,
        ]
    );
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
    $STATUS_TOBEDELETED  => 'Due to be deleted',
    $STATUS_DELETED      => 'Deleted',
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
