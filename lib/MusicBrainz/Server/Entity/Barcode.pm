package MusicBrainz::Server::Entity::Barcode;
use Moose;
use MusicBrainz::Server::Translation qw( l );

has 'code' => (
    is => 'rw',
    isa => 'Maybe[Str]',
);

use overload '""' => sub { shift->code }, fallback => 1;

sub type {
    my ($self) = @_;
    return 'EAN' if length($self->code) == 8;
    return 'UPC' if length($self->code) == 12;
    return 'EAN' if length($self->code) == 13;
}

sub format
{
    my $self = shift;

    return '' unless defined $self->code;

    return $self->code eq '' ? l('[none]') : $self->code;
}

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    if ( @_ == 1 && ! ref $_[0] ) {
        return $class->$orig(code => $_[0]);
    }
    else {
        return $class->$orig(@_);
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;
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
