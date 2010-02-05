package MusicBrainz::Server::WebService::WebServiceInc;

use Moose;

has $_ => (
    is  => 'rw',
    isa => 'Int',
    default => 0
) for qw( gid artists counts limit recordings duration artistrels releaserels discs
          recordingrels urlrels releaseevents artistid releaseid trackid title tracknum
          releases releasegroups releasegrouprels workrels puids isrcs aliases labels 
          labelrels tracklevelrels tags ratings usertags userratings rg_type rel_status);

sub has_rels
{
    my ($self) = @_;

    return 1 if ($self->artistrels || $self->releaserels || $self->workrels ||
                 $self->urlrels || $self->labelrels || $self->tracklevelrels ||
                 $self->releasegrouprels || $self->recordingrels); 
    return 0;
}

sub get_rel_types
{
    my ($self) = @_;

    my @rels;
    push @rels, 'artist' if ($self->artistrels);
    push @rels, 'release' if ($self->releaserels);
    push @rels, 'release_group' if ($self->releasegrouprels);
    push @rels, 'recording' if ($self->recordingrels);
    push @rels, 'label' if ($self->labelrels);
    push @rels, 'work' if ($self->workrels);
    push @rels, 'url' if ($self->urlrels);

    return \@rels;
}

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
    if (exists $args->{relations} && $args->{relations})
    {
        foreach my $rel (@{$args->{relations}})
        {
            $rel =~ s/-//g;
            $methods{$rel}->set_value($self, 1);
        }
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
