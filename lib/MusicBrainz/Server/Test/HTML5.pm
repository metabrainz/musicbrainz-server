package MusicBrainz::Server::Test::HTML5;

use utf8;
use DBDefs;
use Encode;
use JSON;
use Sub::Exporter -setup => { exports => [ 'html5_ok' ] };


=func ignore_warning

Check if a particular warning should be ignored.

Currently we ignore the following warnings:

  1. rel attribute on elements other than a, area, link.
     HTML5 spec: http://developers.whatwg.org/section-index.html#attributes-1

     We use the rel attribute according to the RDFa spec.

  2. datatype attribute
     Not a valid attribute in HTML5, but used by RDFa.

  3. Bad value "foo:Bar" for attribute "rel"
     validator.nu requires rel="" values to be from a list of registered
     types, whereas in RDFa you can use anything if you link to a vocabulary
     which defines the type.

=cut

sub ignore_warning
{
    my $msg = shift;

    my @ignored = (
        '^Attribute .rel. not allowed on element',
        '^Attribute .datatype. not allowed on element',
        '^Bad value .* for attribute .rel. on element',
    );

    for my $test (@ignored)
    {
        return 1 if $msg->{message} =~ $test;
    }

    return 0;
}

=func format_message

Format a validator.nu message for display as a test result.

=cut

sub format_message
{
    my $msg = shift;
    my %opts = @_;

    use Data::Dumper;
    warn "msg:".Dumper ($msg)."\n";

    if ($opts{ignored})
    {
        return sprintf ("%s (ignored): %s", $msg->{type}, $msg->{message});
    }
    else
    {
        return sprintf (encode ("utf-8", "%s%s: %s\n ⤷ line %d (col %d): %s"),
        # return sprintf ("%s%s: %s\n -> line %d (col %d): %s",
                        $msg->{type}, $ignored, $msg->{message},
                        $msg->{lastLine}, $msg->{firstColumn}, $msg->{extract});
    }
}

=func html5_ok

Validate HTML5 using the validator.nu validator.

=cut

sub html5_ok
{
    my ($Test, $content, $message) = @_;

    $message ||= "valid HTML5";

    unless (utf8::is_utf8 ($content)) {
        $Test->ok(0, "$message, need to know encoding of content");
        return;
    }

    my $url = DBDefs::HTML_VALIDATOR;
    my $ua = LWP::UserAgent->new;
    $ua->timeout (10);

    my $request = HTTP::Request->new(POST => $url);
    $request->header ('Content-Type', 'text/html');
    $request->content (encode ("utf-8", $content));

    my $all_ok = 1;

    my $response = $ua->request($request);
    if ($response->is_success)
    {
        my $report = decode_json ($response->decoded_content);
        for my $msg (@{ $report->{messages} })
        {
            next if $msg->{type} eq "info";

            if (ignore_warning ($msg))
            {
                $Test->diag(format_message ($msg, "ignored" => 1));
            }
            else
            {
                $Test->diag(format_message ($msg));
                $all_ok = 0;
            }
        }
    }
    else
    {
        $all_ok = 0;
        $message .= ", Could not connect to ".$url;
    }

    $Test->ok($all_ok, $message);
}

1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
