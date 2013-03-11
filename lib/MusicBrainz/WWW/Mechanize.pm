package MusicBrainz::WWW::Mechanize;

use Moose;
use LWP::Authen::Digest;

extends 'Test::WWW::Mechanize::Catalyst';

around '_make_request' => sub
{
    my $orig = shift;
    my $self = shift;
    my $request = shift;

    my $response = $self->$orig ($request, @_);

    # Test::WWW::Mechanize::Catalyst doesn't seem to do digest authentication.
    # So let's do it ourselves here, every request which results in a '401'
    # response is attempted again with the credentials set using ->credentials.

    if ($response->headers->{status} eq '401' && defined($response->headers->{'www-authenticate'})) {
        my @challenge = $response->headers->header('WWW-Authenticate');
        for my $challenge (@challenge) {
            $challenge =~ tr/,/;/;
            ($challenge) = HTTP::Headers::Util::split_header_words($challenge);
            my $scheme = shift(@$challenge);
            next unless $scheme eq 'digest';
            shift(@$challenge); # no value
            $challenge = { @$challenge };  # make rest into a hash

            my ($username, $password) = $self->credentials (
                $request->uri->host.":".$request->uri->port, $challenge->{realm});

            my $size = length ($request->content);
            $response = LWP::Authen::Digest->authenticate (
                $self, undef, $challenge, $response, $request, undef, $size);
            last;
        }
    }

    return $response;
};


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
