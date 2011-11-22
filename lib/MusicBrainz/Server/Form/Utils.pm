package MusicBrainz::Server::Form::Utils;

use base 'Exporter';
use Scalar::Util qw( looks_like_number );

our @EXPORT = qw( expand_param expand_all_params collapse_param );

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
