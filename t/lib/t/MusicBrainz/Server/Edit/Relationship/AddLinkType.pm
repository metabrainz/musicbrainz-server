package t::MusicBrainz::Server::Edit::Relationship::AddLinkType;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_ADD_TYPE );

with 't::Edit';
with 't::Context';

test 'Can create relationship types with documentation' => sub {
    my $test = shift;
    my $c = $test->c;

    my $documentation = 'To be used when a relationship is founded by an artist';
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_ADD_TYPE,
        editor_id => 1,
        entity0_type => 'artist',
        entity1_type => 'label',
        name => 'founded',
        link_phrase => 'founded',
        reverse_link_phrase => 'was founded by',
        documentation => $documentation,
        attributes => [],
        long_link_phrase => 'founded'
    );

    $edit->accept;

    my $link_type = $c->model('LinkType')->get_by_id($edit->entity_id);
    $c->model('LinkType')->load_documentation($link_type);

    is($link_type->documentation, $documentation);
};

1;
