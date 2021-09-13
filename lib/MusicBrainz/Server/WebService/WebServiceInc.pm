package MusicBrainz::Server::WebService::WebServiceInc;

use Moose;
with qw(MooseX::Clone);
use MusicBrainz::Server::WebService::Exceptions;
use MusicBrainz::Server::Constants qw( @RELATABLE_ENTITIES );

has $_ => (
    is  => 'rw',
    isa => 'Int',
    default => 0
) for (qw(
          aliases discids isrcs media puids various_artists artist_credits
          artists labels recordings releases release_groups works
          tags genres ratings user_tags user_genres user_ratings collections user_collections
          recording_level_rels release_group_level_rels work_level_rels rels annotation release_events
), map { $_ . '_rels' } @RELATABLE_ENTITIES);

has has_rels => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

sub get_rel_types
{
    my ($self) = @_;

    my @rels;
    for my $type (@RELATABLE_ENTITIES) {
        my $method = $type . '_rels';
        push @rels, $type if ($self->$method);
    }

    return \@rels;
}

sub BUILD
{
    my ($self, $args) = @_;

    my $meta = $self->meta;
    my %methods = map { $_->name => $_ } $meta->get_all_attributes;
    my @relations = @{$args->{relations} // []};

    if (@relations)
    {
        foreach my $rel (@relations)
        {
            $rel =~ tr/-/_/;
            $methods{$rel}->set_value($self, 1);
        }
        $self->has_rels(1);
    }

    foreach my $arg (@{$args->{inc}})
    {
        $arg = lc($arg);
        $arg =~ tr/-/_/;
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
