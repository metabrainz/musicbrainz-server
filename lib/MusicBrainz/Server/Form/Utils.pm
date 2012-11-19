package MusicBrainz::Server::Form::Utils;

use strict;
use warnings;

use Scalar::Util qw( looks_like_number );
use MusicBrainz::Server::Translation qw( lp );
use List::UtilsBy qw( sort_by );

use Sub::Exporter -setup => {
    exports => [qw(
                      collapse_param
                      expand_all_params
                      expand_param
                      language_options
                      script_options
              )]
};

sub _expand
{
    my $ret = shift;
    my $value = pop;
    my @parts = @_;

    if (scalar @parts == 0)
    {
        $$ret = $value eq '' ? undef : $value;
    }
    else
    {
        my $key = shift @parts;

        if (looks_like_number ($key))
        {
            _expand (\$$ret->[$key], @parts, $value);
        }
        else
        {
            _expand (\$$ret->{$key}, @parts, $value);
        }
    }
}


sub expand_param
{
    my ($values, $query) = @_;

    my $ret;
    for my $key (keys %$values)
    {
        my $val = $values->{$key};
        my @parts = split (/\./, $key);
        next if shift @parts ne $query;

        _expand (\$ret, @parts, $val);
    }

    return $ret;
}

sub expand_all_params
{
    my $values = shift;

    my %ret;
    for my $key (keys %$values)
    {
        my $val = $values->{$key};
        my @parts = split (/\./, $key);

        my $field_name = shift @parts;

        _expand (\$ret{$field_name}, @parts, $val);
    }

    return \%ret;
}

sub collapse_param
{
    my ($store, $name, $new_value) = @_;

    if (ref $new_value eq 'HASH')
    {
        while (my ($key, $value) = each %$new_value)
        {
            my $tmp = {};
            collapse_param ($tmp, $key, $value);

            while (my ($subkey, $subvalue) = each %$tmp)
            {
                $store->{"$name.$subkey"} = $subvalue;
            }
        }
    }
    elsif (ref $new_value eq 'ARRAY')
    {
        for my $idx (0..$#$new_value)
        {
            my $tmp = {};
            collapse_param ($tmp, $idx, $new_value->[$idx]);

            while (my ($subkey, $subvalue) = each %$tmp)
            {
                $store->{"$name.$subkey"} = $subvalue;
            }
        }
    }
    else
    {
        $store->{$name} = $new_value;
    }
}

sub language_options {
    my $c = shift;

    # group list of languages in <optgroups>.
    # most frequently used languages have hardcoded value 2.
    # languages which shouldn't be shown have hardcoded value 0.

    my $frequent = 2;
    my $skip = 0;

    my @sorted = sort_by { $_->{label} } map {
        {
            'value' => $_->id,
            'label' => $_->l_name,
            'class' => 'language',
            'optgroup' => $_->{frequency} eq $frequent ? lp('Frequently used', 'language optgroup') : lp('Other', 'language optgroup'),
            'optgroup_order' => $_->{frequency} eq $frequent ? 1 : 2,
        }
    } grep { $_->{frequency} ne $skip } $c->model('Language')->get_all;

    return \@sorted;
}

sub script_options {
    my $c = shift;

    # group list of scripts in <optgroups>.
    # most frequently used scripts have hardcoded value 4.
    # scripts which shouldn't be shown have hardcoded value 1.

    my $frequent = 4;
    my $skip = 1;

    my @sorted = sort_by { $_->{label} } map {
        {
            'value' => $_->id,
            'label' => $_->l_name,
            'class' => 'script',
            'optgroup' => $_->{frequency} eq $frequent ? lp('Frequently used', 'script optgroup') : lp('Other', 'script optgroup'),
            'optgroup_order' => $_->{frequency} eq $frequent ? 1 : 2,
        }
    } grep { $_->{frequency} ne $skip } $c->model('Script')->get_all;
    return \@sorted;
}

1;

=head1 COPYRIGHT

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
