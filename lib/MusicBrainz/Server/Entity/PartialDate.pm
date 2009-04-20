package MusicBrainz::Server::Entity::PartialDate;

use Moose;

has 'year' => (
    is => 'rw',
    isa => 'Int'
);

has 'month' => (
    is => 'rw',
    isa => 'Int'
);

has 'day' => (
    is => 'rw',
    isa => 'Int'
);

sub is_empty
{
    my ($self) = @_;
    return !($self->year || $self->month || $self->day);
}

sub format
{
    my ($self) = @_;
    my $fmt = "";
    my @args;
    if ($self->year) {
        $fmt .= "%04d";
        push @args, $self->year;
        if ($self->month) {
            $fmt .= "-%02d";
            push @args, $self->month;
            if ($self->day) {
                $fmt .= "-%02d";
                push @args, $self->day;
            }
        }
    }
    return sprintf $fmt, @args;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
