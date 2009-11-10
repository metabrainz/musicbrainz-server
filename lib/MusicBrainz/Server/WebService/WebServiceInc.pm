package MusicBrainz::Server::WebService::WebServiceInc;

use Moose;

has 'gid' => (
    is => 'rw',
    isa => 'Int'
);

has 'artist' => (
    is => 'rw',
    isa => 'Int'
);

has 'counts' => (
    is => 'rw',
    isa => 'Int'
);

has 'limit' => (
    is => 'rw',
    isa => 'Int'
);

has 'tracks' => (
    is => 'rw',
    isa => 'Int'
);

has 'duration' => (
    is => 'rw',
    isa => 'Int'
);

has 'artistrels' => (
    is => 'rw',
    isa => 'Int'
);

has 'releaserels' => (
    is => 'rw',
    isa => 'Int'
);

has 'discs' => (
    is => 'rw',
    isa => 'Int'
);

has 'trackrels' => (
    is => 'rw',
    isa => 'Int'
);

has 'urlrels' => (
    is => 'rw',
    isa => 'Int'
);

has 'releaseevents' => (
    is => 'rw',
    isa => 'Int'
);

has 'artistid' => (
    is => 'rw',
    isa => 'Int'
);

has 'releaseid' => (
    is => 'rw',
    isa => 'Int'
);

has 'trackid' => (
    is => 'rw',
    isa => 'Int'
);

has 'title' => (
    is => 'rw',
    isa => 'Int'
);

has 'tracknum' => (
    is => 'rw',
    isa => 'Int'
);

has 'trmids' => (
    is => 'rw',
    isa => 'Int'
);

has 'releases' => (
    is => 'rw',
    isa => 'Int'
);

has 'releasegroups' => (
    is => 'rw',
    isa => 'Int'
);

has 'puids' => (
    is => 'rw',
    isa => 'Int'
);

has 'aliases' => (
    is => 'rw',
    isa => 'Int'
);

has 'labels' => (
    is => 'rw',
    isa => 'Int'
);

has 'labelrels' => (
    is => 'rw',
    isa => 'Int'
);

has 'tracklevelrels' => (
    is => 'rw',
    isa => 'Int'
);

has 'tags' => (
    is => 'rw',
    isa => 'Int'
);

has 'ratings' => (
    is => 'rw',
    isa => 'Int'
);

has 'usertags' => (
    is => 'rw',
    isa => 'Int'
);

has 'userratings' => (
    is => 'rw',
    isa => 'Int'
);

has 'rg_type' => (
    is => 'rw',
    isa => 'Int'
);

has 'rel_status' => (
    is => 'rw',
    isa => 'Int'
);

sub BUILD
{
    my ($self, $args) = @_;

    my $meta = __PACKAGE__->meta;
    my %methods = map { $_->name => $_ } $meta->get_all_attributes;

    if (exists $args->{rel_status} && $args->{rel_status})
    {
        $methods{rel_status}->set_value($self, $args->{rel_status});
    }
    if (exists $args->{rg_type} && $args->{rg_type})
    {
        $methods{rg_type}->set_value($self, $args->{rg_type});
    }

    foreach my $arg (@{$args->{inc}})
    {
        $arg =~ s/-//;
        $arg = lc($arg);

        die "Unknown inc parameter $arg" if !exists($methods{$arg});
        $methods{$arg}->set_value($self, 1);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT

Copyright (C) 2009 Robert Kaye

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
