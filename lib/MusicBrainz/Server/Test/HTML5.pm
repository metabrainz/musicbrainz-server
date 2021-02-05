package MusicBrainz::Server::Test::HTML5;

use utf8;
use DBDefs;
use Encode;
use File::Temp qw( tempfile );
use JSON;

use Sub::Exporter -setup => { exports => [ qw(html5_ok) ] };

=func ignore_warning

Check if a particular warning should be ignored.

Currently we ignore the following warnings:

  1. <img> tags without alt attributes
     Not all img elements must have an alt attribute, although we could
     probably do do better here.  For now, just ignore it.

  2. <input type="button"> without value
     In a few spots we use <input type="button"> for buttons which get
     their appearance from a background image instead of the value
     attribute.  <button><img src="" alt="" /></button> would be better
     solution.  See MBS-xxxx.

  3. Element "foo" now allowed as child of element "bar" ...
     These are problems with how our HTML is structured, and these should
     be fixed.  See MBS-xxxx.

  4. Bad value "X-UA-Compatible" for attribute "http-equiv" on element "meta".
     I assume this is some whitelist it has, and it's an IE workaround anyway,
     so I'm ignoring it.

=cut

sub ignore_warning
{
    my $msg = shift;

    my @ignored = (
        '^An .img. element must have an .alt. attribute',
        '^Element .input. with attribute .type. whose value is .button.',
        '^Element .* not allowed as child of element .* in this context.',
        '^Bad value .X-UA-Compatible. for attribute .http-equiv. on element .meta..',
        '^Bad value .dialog. for attribute .aria-haspopup. on element .button..',
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

    if ($opts{ignored})
    {
        return sprintf("%s (ignored): %s", $msg->{type}, $msg->{message});
    }
    else
    {
        return sprintf("%s%s: %s\n ⤷ line %d (col %d): %s", $msg->{type},
                        $ignored, $msg->{message}, $msg->{lastLine},
                        $msg->{firstColumn}, $msg->{extract});

    }
}

=func save_html

If html validation fails, optionally write the failed output to a file
in /tmp so a developer running tests can investigate the output.

Example:

    SAVE_HTML=1 prove -v t/tests.t :: --tests Browse::Entities

=cut

sub save_html
{
    my ($Test, $content, $suffix) = @_;

    if ($ENV{SAVE_HTML}) {
        my ($fh, $filename) = tempfile(
            "html5_ok_XXXX", SUFFIX => $suffix, TMPDIR => 1);
        print $fh encode("utf-8", $content);
        close($fh);
        $Test->diag("failed output written to $filename");
    };
}

=func html5_ok

Validate HTML5 using the validator.nu validator.

=cut

sub html5_ok
{
    my ($Test, $content, $message) = @_;

    $message ||= "valid HTML5";

    unless (utf8::is_utf8($content)) {
        $Test->ok(0, "$message, need to know encoding of content");
        return;
    }

    my $url = DBDefs->HTML_VALIDATOR;

    unless ($url) {
        $Test->skip("No HTML_VALIDATOR configured, skip html validation");
        return;
    }


    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);

    my $request = HTTP::Request->new(POST => $url);
    $request->header('Content-Type', 'text/html');
    $request->content(encode("utf-8", $content));

    my $all_ok = 1;

    my $response = $ua->request($request);
    if ($response->is_success)
    {
        my $report = decode_json($response->content);
        for my $msg (@{ $report->{messages} })
        {
            next if $msg->{type} eq "info";

            if (ignore_warning($msg))
            {
                $Test->diag(format_message($msg, "ignored" => 1));
            }
            else
            {
                $Test->diag(format_message($msg));
                $all_ok = 0;
            }
        }
    }
    else
    {
        $all_ok = 0;
        $message .= ", Could not connect to ".$url;
    }

    save_html($Test, $content, ".html") unless $all_ok;

    $Test->ok($all_ok, $message);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
