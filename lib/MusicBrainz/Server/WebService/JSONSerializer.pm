package MusicBrainz::Server::WebService::JSONSerializer;

use Moose;
use JSON::Any;
use MusicBrainz::Server::Track qw( format_track_length );

sub mime_type { 'application/json' }

sub serialize
{
    my ($self, $type, @data) = @_;

    return $self->$type(@data);
}

sub generic
{
    my ($self, $response) = @_;

    my $json = JSON::Any->new;

    return $json->encode ($response);
}

sub output_error
{
    my ($self, $err) = @_;

    my $json = JSON::Any->new;

    return $json->encode ({ error => $err });
}

sub autocomplete_recording
{
    my ($self, $results, $pager) = @_;

    my $json = JSON::Any->new;

    my @output;

    for my $item (@$results) {
        push @output, {
            name => $item->{recording}->name,
            id => $item->{recording}->id,
            gid => $item->{recording}->gid,
            comment => $item->{recording}->comment,
            length => format_track_length ($item->{recording}->length),
            artist => $item->{recording}->artist_credit->name,
            isrcs => [ map { $_->isrc } @{ $item->{recording}->isrcs } ],
            appears_on => {
                hits => $item->{appears_on}{hits},
                results => [ map { {
                    'name' => $_->name,
                    'gid' => $_->gid
                    } } @{ $item->{appears_on}{results} } ],
            }
        };
    };

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return $json->encode (\@output);
}

__PACKAGE__->meta->make_immutable;
no Moose;
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
