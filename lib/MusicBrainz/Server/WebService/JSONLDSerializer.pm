package MusicBrainz::Server::WebService::JSONLDSerializer;

use Moose;
use JSON;

extends 'MusicBrainz::Server::WebService::JSONSerializer';

# The current working draft specifies the following values for mime
# type and file extension respectively.
# http://json-ld.org/spec/latest/json-ld-syntax/#iana-considerations

override mime_type => sub { 'application/ld+json' };
override fmt => sub { 'jsonld' };

override finalize_body => sub {
    my ($self, $data) = @_;

    # To ensure the best possible performance, it is a best practice
    # to put the context definition at the top of the JSON-LD
    # document [1].
    # Obviously the key order isn't guarenteed when feeding encode_json
    # a simple hash.  So, to make sure @context is at the start we just
    # perform a bit of string manipulation.
    #
    # [1] http://json-ld.org/spec/latest/json-ld-syntax/#the-context

    return '{ "@context":"http://localhost:5000/static/context.json", ' .
        substr encode_json ($data), 1;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 Kuno Woudt <kuno@frob.nl>

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
