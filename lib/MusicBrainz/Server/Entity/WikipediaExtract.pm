package MusicBrainz::Server::Entity::WikipediaExtract;

use Moose;

has 'title' => (
    is => 'rw',
    isa => 'Str',
);

has 'content' => (
    is => 'rw',
    isa => 'Str'
);

has 'canonical' => (
    is => 'rw',
    isa => 'Str',
);

has 'language' => (
    is => 'rw',
    isa => 'Str',
);

has 'url' => (
    is => 'rw',
    isa => 'Str',
);

sub TO_JSON {
    my ($self) = @_;

    return {
        title       => $self->title,
        content     => $self->content,
        canonical   => $self->canonical,
        language    => $self->language,
        url         => $self->url,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Ian McEwen
Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
