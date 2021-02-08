package MusicBrainz::Server::Entity::CommonsImage;

use Moose;

has 'title' => (
    is => 'rw',
    isa => 'Str',
);

has 'image_url' => (
    is => 'rw',
    isa => 'Str',
);

has 'thumb_url' => (
    is => 'rw',
    isa => 'Str',
);

sub page_url
{
    my $self = shift;
    return sprintf "https://commons.wikimedia.org/wiki/%s", $self->title;
}

sub TO_JSON {
    my ($self) = @_;

    return {
        page_url => $self->page_url,
        thumb_url => $self->thumb_url,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
