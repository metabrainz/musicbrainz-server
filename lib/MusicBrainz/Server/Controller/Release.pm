package MusicBrainz::Server::Controller::Release;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use ModDefs;
use MusicBrainz;
use MusicBrainz::Server::Adapter::Relations;
use MusicBrainz::Server::CoverArt;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Tag;
use MusicBrainz::Server::Track;
use MusicBrainz::Server::Validation;

=head1 NAME

MusicBrainz::Server::Controller::Release - Catalyst Controller for working with Release entities

=cut

=head1 DESCRIPTION

=head1 METHODS

=cut

# releaseLinkRaw {{{
=head2 releaseLinkRaw

Create stash data to link to a Release entity using root/components/entity-link.tt

=cut

sub releaseLinkRaw
{
    my ($name, $mbid) = @_;

    {
        name => $name,
        mbid => $mbid,
        link_type => 'release'
    };
}
# }}}

# show {{{
sub show : Path Local Args(1) {
    my ($self, $c, $mbid) = @_;

    # Load Release {{{
    my $release = MusicBrainz::Server::Release->new($c->mb->{DBH});

    unless (MusicBrainz::Server::Validation::IsGUID($mbid))
    {
        if (MusicBrainz::Server::Validation::IsNonNegInteger($mbid))
            { $release->SetId($mbid); }
        else
            { die "Not a valid GUID or row ID"; }
    }
    else { $release->SetMBId($mbid); }

    $release->LoadFromId(1)
        or die "Failed to load release";

    $c->stash->{release} = $release->ExportStash qw/ puids track_count quality language type /;
    # }}}

    # Load Release Relationships {{{
    my $link = MusicBrainz::Server::Link->new($c->mb->{DBH});
    my @arLinks = $link->FindLinkedEntities($release->GetId, 'album');

    MusicBrainz::Server::Adapter::Relations::NormaliseLinkDirections(\@arLinks, $release->GetId, 'album');
    @arLinks = MusicBrainz::Server::Adapter::Relations::SortLinks(\@arLinks);
    $c->stash->{relations} = MusicBrainz::Server::Adapter::Relations::ExportLinks(\@arLinks);
    # }}}

    # Load Artist {{{
    my $artist = MusicBrainz::Server::Artist->new($c->mb->{DBH});
    $artist->SetId($release->GetArtist);
    $artist->LoadFromId(1)
        or die "Failed to load the artist of this release";

    # Export enough to display the artist header
    $c->stash->{artist} = $artist->ExportStash qw/ name mbid type date quality
                                                   resolution /;
    # }}}
    
    # Tracks {{{
    my $puid_counts = $release->LoadPUIDCount;
    my @tracks = $release->LoadTracks;

    $c->stash->{tracks} = [];

    for my $track (@tracks)
    {
        my @trackLinks = $link->FindLinkedEntities($track->GetId, 'track');
        MusicBrainz::Server::Adapter::Relations::NormaliseLinkDirections(\@trackLinks, $track->GetId, 'track');
        @trackLinks = MusicBrainz::Server::Adapter::Relations::SortLinks(\@trackLinks);

        push @{ $c->stash->{tracks} }, {
            number => $track->GetSequence,
            title => $track->GetName,
            puids => $puid_counts->{ $track->GetId },
            duration => MusicBrainz::Server::Track::FormatTrackLength($track->GetLength),
            relations => MusicBrainz::Server::Adapter::Relations::ExportLinks(\@trackLinks),
        };
    }
    # }}}

    # Tags {{{
    my $t = MusicBrainz::Server::Tag->new($c->mb->{DBH});
    my $num = 5;
    my $tags = $t->GetTagHashForEntity('release', $release->GetId, $num + 1);

    $c->stash->{tags} = sort { $tags->{$b} <=> $tags->{$a}; } keys %{$tags};
    $c->stash->{more_tags} = scalar(keys %$tags) > $num;
    # }}}

    $c->stash->{template} = 'releases/show.tt';
}
# }}}

=head1 AUTHOR

Oliver Charles <oliver.g.charles@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under the same terms as Perl
itself.

=cut

1;
