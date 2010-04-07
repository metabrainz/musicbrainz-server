package MusicBrainz::Server::Controller::User::Donation;
use Moose;
use LWP;
use URI::Escape;

BEGIN { extends 'MusicBrainz::Server::Controller' };

sub view : Chained('/user/base') PathPart('donation') RequireAuth
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    $c->detach('/error_403')
        unless $c->{stash}->{viewing_own_profile};

    my $nag = 1;
    $nag = 0 if ($user->is_nag_free || $user->is_auto_editor || $user->is_bot ||
                 $user->is_relationship_editor || $user->is_wiki_transcluder);

    my $days = 0.0;
    if ($nag)
    {
        my $ua = LWP::UserAgent->new;
        $ua->agent("MusicBrainz server");
        $ua->timeout(5); # in seconds.

        my $response = $ua->request(HTTP::Request->new (GET => 
            'http://metabrainz.org/cgi-bin/nagcheck_days?moderator='. 
            uri_escape($user->name)));

        if ($response->is_success && $response->content =~ /\s*([-01]+),([-0-9.]+)\s*/)
        {
            $nag = $1;
            $days = $2;
        }
        else
        {
            $c->detach('/error_500');
        }
    }

    $c->stash(
        nag => $nag,
        days => sprintf ("%.0f", $days),
        template => 'user/donation.tt',
    );
}

1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
