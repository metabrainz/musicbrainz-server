package MusicBrainz::Server::Controller::Moderation;

use strict;
use warnings;

use base 'Catalyst::Controller';

sub moderation : Chained CaptureArgs(1)
{
    my ($self, $c, $mod_id) = @_;

    my $moderation = $c->model('Moderation')->load($mod_id);
    $c->stash->{moderation} = $moderation;
}

=head2 list

Show all open moderations in chronological order

=cut

sub show : Chained('moderation')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    $c->stash->{expire_action} = \&ModDefs::GetExpireActionText;

    my $moderation = $c->stash->{moderation};

    if (defined $moderation->{'trackid'})
    {
        my $track = $c->model('Track')->load($moderation->{'trackid'});
        $c->stash->{track} = $track;
    }

    if (defined $moderation->{'albumid'})
    {
        my $release = $c->model('Release')->load($moderation->{'albumid'});
        $c->stash->{release} = $release;
    }

    unless ($moderation->{'dont-display-artist'})
    {
        my $artist = $c->model('Artist')->load($moderation->artist);
        $c->stash->{artist} = $artist;
    }


    my $comp = ref $moderation;
    $comp =~ s/.*::MOD_(.*)/$1/;

    $c->stash->{mod_template} = lc $comp;
}

1;
