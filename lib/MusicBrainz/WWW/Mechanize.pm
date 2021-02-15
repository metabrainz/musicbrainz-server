package MusicBrainz::WWW::Mechanize;

use Moose;
use LWP::Authen::Digest;

extends 'Test::WWW::Mechanize::Catalyst';

around '_make_request' => sub
{
    my $orig = shift;
    my $self = shift;
    my $request = shift;

    my $response = $self->$orig($request, @_);

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

            my ($username, $password) = $self->credentials(
                $request->uri->host.":".$request->uri->port, $challenge->{realm});

            my $size = length($request->content);
            $response = LWP::Authen::Digest->authenticate(
                $self, undef, $challenge, $response, $request, undef, $size);
            last;
        }
    }

    return $response;
};


1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
