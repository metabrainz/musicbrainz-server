package MusicBrainz::Server::Renderer;

use strict;
use warnings;

use base 'Exporter';
use DBDefs;
use feature 'state';
use JSON -convert_blessed_universally;
use MusicBrainz::Server::Entity::Util::JSON qw(
    encode_with_linked_entities
);

our @EXPORT_OK = qw(
    render_component
    send_to_renderer
);

sub send_to_renderer {
    my ($c, $message, $expect_response) = @_;

    my $socket = $c->stash->{renderer_socket};
    return unless defined $socket;

    require bytes;

    state $body_json = JSON->new->utf8->allow_unknown(0)->allow_blessed(0);
    my $encoded_body = encode_with_linked_entities($body_json, $message);

    $socket->send(pack('V', bytes::length($encoded_body)));
    $socket->send($encoded_body);

    if ($expect_response) {
        my $buffer;
        my $response = '';

        $socket->recv($buffer, 4);
        my ($length) = unpack('V', $buffer);
        my $remaining = $length;

        while (bytes::length($response) < $length) {
            $socket->recv($buffer, $remaining);
            $response .= $buffer;
            $remaining -= bytes::length($buffer);
        }

        return $body_json->decode($response);
    }

    return;
}

sub render_component {
    my ($c, $component, $props) = @_;

    my %body = (
        component => $component,
        props => $props,
    );
    return send_to_renderer($c, \%body, 1);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
