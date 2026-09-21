package MusicBrainz::Server::Data::Role::SearchRequestHeaders;
use Moose::Role;
use namespace::autoclean;

use DBDefs;

=head1 NAME

MusicBrainz::Server::Data::Role::SearchRequestHeaders

=head1 DESCRIPTION

Provides C<build_search_request_headers>, which assembles a flat, ordered
list of C<X-MB-*> HTTP header key/value pairs used to tag requests sent to
the search server (Solr). Each piece of information is emitted as its own
header (one value per header, no packed key=value), so downstream proxies
such as HAProxy can capture each with C<req.hdr(...)> directly.

=head1 HEADERS

=over

=item C<X-MB-Version>

The running code version: C<< <GIT_SHA>@<GIT_BRANCH> >>.

=back

=head1 X-ACCEL-REDIRECT

When C<< DBDefs->SEARCH_X_ACCEL_REDIRECT >> is enabled, the web service does
not issue the Solr request itself; nginx does, following an
C<X-Accel-Redirect> response header (see
L<MusicBrainz::Server::ControllerBase::WS::2>). Because nginx makes the Solr
request from the C</internal/search> location, the C<X-MB-*> values — which
are set on the Catalyst I<response> from the application — must be copied onto
the I<request> nginx sends upstream. They are available inside the internal
location as C<$upstream_http_*> and forwarded with C<proxy_set_header>.

C<proxy_hide_header> can prevent the tags from leaking back to the
client. It isn't strictly needed as neither nginx nor the downstream
proxies to Solr do forward these headers back to the client by default
but it is defensive in case the configuration changes.

Adapt the existing C</internal/search> location in your nginx
configuration by adding the following directives:

    location /internal/search/ {
        internal;
        # ... existing proxy_pass to the search server ...

        # Copy the tags from the application response onto the Solr request.
        proxy_set_header X-MB-Version $upstream_http_x_mb_version;

        # Defensively prevent leaking the tags back to the client.
        proxy_hide_header X-MB-Version;
    }

Note that C<proxy_set_header> with an empty value omits the field.

References:

=over

=item * For nginx C<proxy_set_header> (empty value omits the field), C<proxy_hide_header>, and C<X-Accel-Redirect> handling; see: L<https://nginx.org/en/docs/http/ngx_http_proxy_module.html>

=item * For nginx C<$upstream_http_*> variables; see: L<https://nginx.org/en/docs/http/ngx_http_upstream_module.html#var_upstream_http_>

=back

=cut

# Assemble the X-MB-* header list for a search-server request.
#
# Values sourced centrally (code version, ...) are filled in here.
#
# Returns a flat list suitable for both:
#   $ua->get($url, @headers)
#   $c->res->headers->header(@headers)
sub build_search_request_headers {
    my ($self, %tags) = @_;

    my @headers;

    # The running code version.
    push @headers, ('X-MB-Version', DBDefs->GIT_SHA . '@' . DBDefs->GIT_BRANCH);

    return @headers;
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
