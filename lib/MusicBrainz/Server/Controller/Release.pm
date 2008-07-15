package MusicBrainz::Server::Controller::Release;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use MusicBrainz;
use MusicBrainz::Server::Release;
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
# releaseLink {{{
=head2 releaseLink

Create stash data to link to a Release entity using root/components/entity-link.tt

=cut

sub releaseLink
{
    my $release = shift;
    $release->ExportStash qw( name mbid )
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

    $c->stash->{release} = {
        title => $release->GetName
    };

    my $puid_counts = $release->LoadPUIDCount;
    # }}}

    # Load Artist {{{
    my $artist = MusicBrainz::Server::Artist->new($c->mb->{DBH});
    $artist->SetId($release->GetArtist);
    $artist->LoadFromId(1)
        or die "Failed to load the artist of this release";

    $c->stash->{artist} = $artist->ExportStash qw/ name mbid type date quality
                                                   resolution /;
    # }}}

    # Tracks {{{
    my @tracks = $release->LoadTracks;
    $c->stash->{tracks} = [];
    for my $track (@tracks)
    {
        push @{ $c->stash->{tracks} }, {
            number => $track->GetSequence,
            title => $track->GetName,
            puids => $puid_counts->{ $track->GetId },
            duration => MusicBrainz::Server::Track::FormatTrackLength($track->GetLength)
        };
    }
    # }}}

    $c->stash->{template} = 'releases/show.tt';
}

=head1 AUTHOR

Oliver Charles <oliver.g.charles@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under the same terms as Perl
itself.

=cut

1;
