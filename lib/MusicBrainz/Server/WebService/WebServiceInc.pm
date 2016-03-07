package MusicBrainz::Server::WebService::WebServiceInc;

use Moose;
with qw(MooseX::Clone);
use MusicBrainz::Server::WebService::Exceptions;
use MusicBrainz::Server::Constants qw( entities_with );

has $_ => (
    is  => 'rw',
    isa => 'Int',
    default => 0
) for (qw(
          aliases discids isrcs media puids various_artists artist_credits
          artists labels recordings releases release_groups works
          tags ratings user_tags user_ratings collections user_collections
          recording_level_rels work_level_rels rels annotation release_events
), map { $_ . '_rels' } entities_with(['mbid', 'relatable']));

sub has_rels
{
    my ($self) = @_;

    for my $type (entities_with(['mbid','relatable'])) {
        my $meth = $type . '_rels';
        return 1 if $self->$meth;
    }

    return 0;
}

sub get_rel_types
{
    my ($self) = @_;

    my @rels;
    for my $type (entities_with(['mbid', 'relatable'])) {
        my $meth = $type . '_rels';
        push @rels, $type if ($self->$meth);
    }

    return \@rels;
}

sub BUILD
{
    my ($self, $args) = @_;

    my $meta = $self->meta;
    my %methods = map { $_->name => $_ } $meta->get_all_attributes;

    if (exists $args->{relations} && $args->{relations})
    {
        foreach my $rel (@{$args->{relations}})
        {
            $rel =~ s/-/_/g;
            $methods{$rel}->set_value($self, 1);
        }
    }

    foreach my $arg (@{$args->{inc}})
    {
        $arg = lc($arg);
        $arg =~ s/-/_/g;
        $arg =~ s/mediums/media/;

        MusicBrainz::Server::WebService::Exceptions::UnknownIncParameter->throw( parameter => $arg )
            if !exists($methods{$arg});
        $methods{$arg}->set_value($self, 1);
    }

    $self->media(1) if ($self->discids);
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
