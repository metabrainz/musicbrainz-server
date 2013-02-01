package MusicBrainz::Server::Data::NES::URL;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Tree::URL;
use MusicBrainz::Server::Entity::URL;

with 'MusicBrainz::Server::Data::Role::NES';
with 'MusicBrainz::Server::Data::NES::CoreEntity' => {
    root => '/url'
};

sub find_or_insert {
    my ($self, $edit, $editor, $url) = @_;
    $self->create(
        $edit, $editor,
        MusicBrainz::Server::Entity::Tree::URL->new(
            url => MusicBrainz::Server::Entity::URL->new(
                url => $url
            )
        )
    );
}

sub tree_to_json {
    my ($self, $tree) = @_;

    return (
        url => $tree->url->url->as_string
    );
}

sub map_core_entity {
    my ($self, $response) = @_;
    my %data = %{ $response->{data} };
    return MusicBrainz::Server::Entity::URL->new(
        url => $data{url},

        gid => $response->{mbid},
        revision_id => $response->{revision}
    );
}

1;
