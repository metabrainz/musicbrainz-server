package MusicBrainz::Server::Controller::Role::WikipediaExtract;
use Moose::Role;
use namespace::autoclean;

after show => sub {
    my ($self, $c) = @_;

    my $entity = $c->stash->{entity};
    my $wp_link = shift @{ $entity->relationships_by_link_type_names('wikipedia') };

    if ($wp_link) {
        my $wanted_lang = $c->stash->{current_language} // 'en';
        if ($self->isa('MusicBrainz::Server::Controller::Work')) {
            $wp_link = $wp_link->entity0;
        } else {
            $wp_link = $wp_link->entity1;
        }

        my $wp_extract = $c->model('WikipediaExtract')->get_extract($wp_link->page_name, $wanted_lang, $wp_link->language);
        if ($wp_extract) {
            $c->stash->{wikipedia_extract} = $wp_extract;
        }
    }
};
1;
