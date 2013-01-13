package MusicBrainz::Server::Test::HTML5;

use utf8;
use DBDefs;
use Encode;
use File::Temp qw( tempfile );
use JSON;
use XML::LibXML;

use Sub::Exporter -setup => { exports => [ qw(xhtml_ok html5_ok) ] };

=func ignore_warning

Check if a particular warning should be ignored.

Currently we ignore the following warnings:

  1. rel attribute on elements other than a, area, link.
     HTML5 spec: http://developers.whatwg.org/section-index.html#attributes-1

     We use the rel attribute according to the RDFa spec.

  2. datatype attribute
     Not a valid attribute in HTML5, but used by RDFa.

  3. resource attribute
     Not a valid attribute in HTML5, but used by RDFa.

  4. content attribute
     Not a valid attribute in HTML5, but used by RDFa.

  5. xmlns attributes on <html>
     Not valid in html5, required for RDFa 1.0.  Upgrading our implementation
     to RDFa 1.1 hopefully will solve this.  See MBS-xxxx.

  6. Bad value "foo:Bar" for attribute "rel"
     validator.nu requires rel="" values to be from a list of registered
     types, whereas in RDFa you can use anything if you link to a vocabulary
     which defines the type.

  7. <img> tags without alt attributes
     Not all img elements must have an alt attribute, although we could
     probably do do better here.  For now, just ignore it.

  8. <input type="button"> without value
     In a few spots we use <input type="button"> for buttons which get
     their appearance from a background image instead of the value
     attribute.  <button><img src="" alt="" /></button> would be better
     solution.  See MBS-xxxx.

  9. Element "foo" now allowed as child of element "bar" ...
     These are problems with how our HTML is structured, and these should
     be fixed.  See MBS-xxxx.

 10. about attribute
     Not a valid attribute in HTML5, but used by RDFa.

 11. Bad value ... for attribute “resource” on element ...
     We seem to be using values that are not proper resource attribute values.

=cut

sub ignore_warning
{
    my $msg = shift;

    my @ignored = (
        '^Attribute .rel. not allowed on element',
        '^Attribute .datatype. not allowed on element',
        '^Attribute .resource. not allowed on element',
        '^Attribute .content. not allowed on element',
        '^Attribute .xmlns:[A-Za-z0-9]*. not allowed here',
        '^Bad value .* for attribute .rel. on element',
        '^An .img. element must have an .alt. attribute',
        '^Element .input. with attribute .type. whose value is .button.',
        '^Element .* not allowed as child of element .* in this context.',
        '^Attribute .about. not allowed on element',
        '^Bad value .* for attribute .resource. on element .*: Illegal character in scheme component.'
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
        return sprintf ("%s (ignored): %s", $msg->{type}, $msg->{message});
    }
    else
    {
        return sprintf ("%s%s: %s\n ⤷ line %d (col %d): %s", $msg->{type},
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
        my ($fh, $filename) = tempfile (
            "html5_ok_XXXX", SUFFIX => $suffix, TMPDIR => 1);
        print $fh encode ("utf-8", $content);
        close ($fh);
        $Test->diag ("failed output written to $filename");
    };
}


=func xhtml_ok

Check if the document is well-formed xhtml. (== well-formed xml, but
html character entities are allowed without an external DTD).

=cut

sub xhtml_ok
{
    my ($Test, $content, $message) = @_;

    $message ||= "well-formed XHTML";

    eval { XML::LibXML->load_xml (string => $content); };
    if ($@)
    {
        foreach (split "\n", $@->as_string ())
        {
            $Test->diag($_);
        }
        save_html ($Test, $content, ".xml");
        return $Test->ok (0, $message);
    }
    else
    {
        return $Test->ok (1, $message);
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

    my $url = DBDefs->HTML_VALIDATOR;

    unless ($url) {
        $Test->skip("No HTML_VALIDATOR configured, skip html validation");
        return;
    }


    my $ua = LWP::UserAgent->new;
    $ua->timeout (10);

    my $request = HTTP::Request->new(POST => $url);
    $request->header ('Content-Type', 'text/html');
    $request->content (encode ("utf-8", $content));

    my $all_ok = 1;

    my $response = $ua->request($request);
    if ($response->is_success)
    {
        my $report = decode_json ($response->content);
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

    save_html ($Test, $content, ".html") unless $all_ok;

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
