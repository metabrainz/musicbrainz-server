package MusicBrainz::Server::Entity::EditorLanguage;
use Moose;
use namespace::autoclean;

has 'editor_id' => (
    is => 'rw',
);

has 'language_id' => (
    is => 'rw',
);

has 'language' => (
    is => 'rw',
);

has 'fluency' => (
    is => 'rw',
);

sub TO_JSON {
    my ($self) = @_;

    return {
        fluency => $self->fluency,
        language => $self->language->TO_JSON,
    };
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
