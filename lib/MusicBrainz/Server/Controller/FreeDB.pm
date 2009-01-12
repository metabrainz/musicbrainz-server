package MusicBrainz::Server::Controller::FreeDB;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

sub index : Local
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    use MusicBrainz::Server::Form::Search::Query;
    use MusicBrainz::Server::Form::Search::External;

    $c->stash->{search} = MusicBrainz::Server::Form::Search::External->new;
    $c->stash->{import} = MusicBrainz::Server::Form::Search::Query->new;

    $c->stash->{search}->field("type")->value('freedb');
}

sub import : Local
{
    my ($self, $c) = @_;

    my $cat_id = $c->req->query_params->{catid};

    unless (defined $cat_id)
    {
        $c->forward("index");
    }

    my ($cat, $id) = $cat_id =~ /
                                   ^\s*                       # start of line, leading space
                                   (\w*)                      # category (e.g. misc)
                                   (?:                        # either:
                                       \s*\/\s*               #  a slash (optional whitespace)
                                   |                          # or:
                                       \s+                    #  mandatory whitespace
                                   )
                                   ([0-9A-Fa-f]{8})           # data ID (e.g. 12345678)
                                   (?:\s*,\s*[0-9A-Fa-f]{8})? # additional IDs
                                   \s*$                       # trailing space, end of line
                                /x;

    if (!defined $cat)
    {
        die "Invalid FreeDB catalog number!";
    }

    my $freedb_entry = $c->model('FreeDB')->load($id, $cat)
        or die "Could not load FreeDB entry";

    my $track_count = scalar @{ $freedb_entry->{tracks} };
    my @durations = split ' ', $freedb_entry->{durations};

    require MusicBrainz::Server::Release;
    my $release = MusicBrainz::Server::Release->new(undef,
        name => $freedb_entry->{album},
        track_count => $track_count,
    );

    require MusicBrainz::Server::Track;
    my @tracks;
    for my $i (0 .. $track_count - 1)
    {
        my $track = MusicBrainz::Server::Track->new();
        $track->name($freedb_entry->{tracks}->[$i]->{track});
        $track->sequence($i + 1);
        $track->length($durations[$i]);

        push @tracks, $track;
    }

    $c->session->{freedb_entry} = {
        release => $release,
        artist  => $freedb_entry->{artist},
        tracks  => \@tracks,
    };

    $c->session->{freedb_step}  = 'choose_artist';
    $c->forward($c->session->{freedb_step});
}

sub choose_artist : Private
{
    my ($self, $c) = @_;

    $c->stash->{template} = 'freedb/choose_artist.tt';

    my $entry = $c->session->{freedb_entry};
    $c->stash->{release} = $entry->{release};
    $c->stash->{tracks}  = $entry->{tracks};
    $c->stash->{single_artist}   = $entry->{artist};
}

1;
