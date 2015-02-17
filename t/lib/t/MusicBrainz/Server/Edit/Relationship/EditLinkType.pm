package t::MusicBrainz::Server::Edit::Relationship::EditLinkType;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_EDIT_LINK_TYPE );

with 't::Edit';
with 't::Context';

test 'Can change relationship documentation by editing' => sub {
    my $test = shift;
    my $c = $test->c;

    my $new_documentation = 'New documentation string';
    my $old_documentation = "Not $new_documentation";

    my $lt = $c->model('LinkType')->insert({
        entity0_type => 'artist',
        entity1_type => 'label',
        name => 'founded',
        link_phrase => 'founded',
        reverse_link_phrase => 'founded',
        long_link_phrase  => 'founded',
        attributes => [],
        documentation => $old_documentation
    });

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_EDIT_LINK_TYPE,
        editor_id => 1,
        old => {
            documentation => $old_documentation
        },
        new => {
            documentation => $new_documentation
        },
        link_id => $lt->id,
    );

    $edit->accept;

    my $link_type = $c->model('LinkType')->get_by_id($lt->id);
    $c->model('LinkType')->load_documentation($link_type);

    is($link_type->documentation, $new_documentation);
};

1;
