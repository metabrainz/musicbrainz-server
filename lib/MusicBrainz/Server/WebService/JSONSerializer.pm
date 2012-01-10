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

sub serialize_data
{
    my ($self, $data) = @_;

    my $json = JSON::Any->new;

    return $json->encode($data);
}

sub autocomplete_generic
{
    my ($self, $output, $pager) = @_;

    my $json = JSON::Any->new;

    my @output = map $self->_generic($_), @$output;

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return $json->encode (\@output);
}

sub _generic
{
    my ($self, $entity) = @_;

    return {
        name    => $entity->name,
        id      => $entity->id,
        gid     => $entity->gid,
        comment => $entity->comment,
        $entity->meta->has_attribute('sort_name')
            ? (sortname => $entity->sort_name) : ()
    };
}

sub autocomplete_editor
{
    my ($self, $output, $pager) = @_;

    my $json = JSON::Any->new;
    return $json->encode([
        (map +{
            name => $_->name,
            id => $_->id,
        }, @$output),
        {
            pages => $pager->last_page,
            current => $pager->current_page
        }
    ]);
}

sub generic
{
    my ($self, $response) = @_;
    my $json = JSON::Any->new;
    return $json->encode($response);
}

sub output_error
{
    my ($self, $err) = @_;

    my $json = JSON::Any->new;

    return $json->encode ({ error => $err });
}

sub autocomplete_release_group
{
    my ($self, $results, $pager) = @_;

    my $json = JSON::Any->new;

    my @output;
    push @output, $self->_release_group($_) for @$results;

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return $json->encode (\@output);
}

sub _release_group
{
    my ($self, $item) = @_;

    return {
        name    => $item->name,
        id      => $item->id,
        gid     => $item->gid,
        comment => $item->comment,
        artist  => $item->artist_credit->name,
        type    => $item->type_id,
    };
}

sub autocomplete_recording
{
    my ($self, $results, $pager) = @_;

    my $json = JSON::Any->new;

    my @output;
    push @output, $self->_recording($_) for @$results;

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return $json->encode (\@output);
}

sub _recording
{
    my ($self, $item) = @_;

    return {
        name    => $item->{recording}->name,
        id      => $item->{recording}->id,
        gid     => $item->{recording}->gid,
        comment => $item->{recording}->comment,
        length  => format_track_length ($item->{recording}->length),
        artist  => $item->{recording}->artist_credit->name,
        isrcs   => [ map { $_->isrc } @{ $item->{recording}->isrcs } ],
        appears_on  => {
            hits    => $item->{appears_on}{hits},
            results => [ map { {
                'name' => $_->name,
                'gid'  => $_->gid
            } } @{ $item->{appears_on}{results} } ],
        }
    };
}

sub autocomplete_work
{
    my ($self, $results, $pager) = @_;

    my $json = JSON::Any->new;

    my @output;
    push @output, $self->_work($_) for (@$results);

    push @output, {
        pages => $pager->last_page,
        current => $pager->current_page
    } if $pager;

    return $json->encode (\@output);
}

sub _work
{
    my ($self, $item) = @_;

    return {
        name    => $item->{work}->name,
        id      => $item->{work}->id,
        gid     => $item->{work}->gid,
        comment => $item->{work}->comment,
        artists => $item->{artists},
    };
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
