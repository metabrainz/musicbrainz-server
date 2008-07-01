package MusicBrainz::Server::Action::ArtistPage;

use strict;
use warnings;
use base 'Catalyst::Action';

=head1 NAME

MusicBrainz::Server::Actions::ArtistPage - Custom Action for creating artist pages.

=head1 DESCRIPTION

This fills the Catalyst stash with variables to display the Artist header on a page

=head1 METHODS

=head2 execute

Executes the ArtistPage Action after the action has completed. The action must add the
MusicBrainz::Server::Artist to display to the stash with the name "_artist" - eg:
$c->stash->{_artist} = $myArtist;

=cut

sub execute
{
    my $self = shift;

    my ($controller, $c) = @_;

    $self->NEXT::execute(@_);

    my $artist = $c->stash->{_artist};

    if (defined $artist)
    {
        $c->stash->{artist} = {
            name => $artist->GetName,
            type => 'artist',
            mbid => $artist->GetMBId,
            artist_type => MusicBrainz::Server::Artist::GetTypeName($artist->GetType),
            datespan => {
                start => $artist->GetBeginDate,
                end => $artist->GetEndDate
            },
            quality => ModDefs::GetQualityText($artist->GetQuality),
            resolution => $artist->GetResolution,
        };
    }
}

1;
