package t::TemplateMacros;

use utf8;
use Catalyst::Test 'MusicBrainz::Server';
use JSON::XS;
use MusicBrainz::Server::Entity::Preferences;
use Scalar::Util qw( blessed );
use String::ShellQuote qw( shell_quote );
use Test::More;
use Test::Routine;
use Text::Trim qw( trim );

use aliased 'MusicBrainz::Server::Entity::Area';
use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::ArtistCreditName';
use aliased 'MusicBrainz::Server::Entity::Editor';
use aliased 'MusicBrainz::Server::Entity::Event';
use aliased 'MusicBrainz::Server::Entity::Label';
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Place';
use aliased 'MusicBrainz::Server::Entity::Recording';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';
use aliased 'MusicBrainz::Server::Entity::URL';
use aliased 'MusicBrainz::Server::Entity::Work';

test all => sub {
    my ($test) = @_;

    my ($res, $ctx) = ctx_request('/');

    # Requesting / sets current_view to Node, which is not what we want
    # to render TT.
    undef $ctx->stash->{current_view};

    my $chicago = Area->new(
        gid => '29a709d8-0320-493e-8d0c-f2c386662b7f',
        id => 5099,
        name => 'Chicago',
        containment => [
            Area->new(
                gid => '8c2196d9-b7be-4051-90d1-ac81895355f1',
                id => 276,
                name => 'Illinois',
            ),
            Area->new(
                gid => '489ce91b-6658-3307-9877-795b68554c98',
                id => 222,
                name => 'United States',
            ),
        ],
    );

    my @tests = (
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<span class="flag flag-US">' .
                '<a href="/area/489ce91b-6658-3307-9877-795b68554c98">' .
                    '<bdi>United States</bdi>' .
                '</a>' .
            '</span>',

            Area->new(
                id => 222,
                gid => '489ce91b-6658-3307-9877-795b68554c98',
                name => 'United States',
                iso_3166_1 => ['US'],
            ),
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<span class="flag flag-US">' .
                '<span class="mp">' .
                    '<a href="/area/489ce91b-6658-3307-9877-795b68554c98">' .
                        '<bdi>United States</bdi>' .
                    '</a>' .
                '</span>' .
            '</span>',

            Area->new(
                id => 222,
                gid => '489ce91b-6658-3307-9877-795b68554c98',
                name => 'United States',
                iso_3166_1 => ['US'],
                edits_pending => 1,
            ),
        ],
        [
            "link_entity(entity, 'edit', l('Edit'))",
            "React.createElement(EntityLink, {entity: entity, subPath: '/edit', content: l('Edit')})",

            '<a href="/area/489ce91b-6658-3307-9877-795b68554c98/edit">' .
                '<bdi>Edit</bdi>' .
            '</a>',

            Area->new(
                id => 222,
                gid => '489ce91b-6658-3307-9877-795b68554c98',
                name => 'United States',
            ),
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<a href="/area/32f90933-b4b4-3248-b98c-e573d5329f57">' .
                '<bdi>Soviet Union</bdi>' .
            '</a> ' . # space required
            '<span class="historical">(<bdi>historical, 1922-1991</bdi>)</span>',

            Area->new(
                id => 243,
                gid => '32f90933-b4b4-3248-b98c-e573d5329f57',
                name => 'Soviet Union',
                begin_date => PartialDate->new(year => 1922),
                end_date => PartialDate->new(year => 1991),
                ended => 1,
            ),
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            # same as above, except with comment
            '<a href="/area/32f90933-b4b4-3248-b98c-e573d5329f57">' .
                '<bdi>Soviet Union</bdi>' .
            '</a> ' . # space required
            '<span class="comment">(<bdi>Сове́тский Сою́з</bdi>)</span> ' .
            '<span class="historical">(<bdi>historical, 1922-1991</bdi>)</span>',

            Area->new(
                id => 243,
                gid => '32f90933-b4b4-3248-b98c-e573d5329f57',
                name => 'Soviet Union',
                comment => 'Сове́тский Сою́з',
                begin_date => PartialDate->new(year => 1922),
                end_date => PartialDate->new(year => 1991),
                ended => 1,
            ),
        ],
        [
            "descriptive_link(entity)",
            "React.createElement(DescriptiveLink, {entity: entity})",

            '<a href="/area/29a709d8-0320-493e-8d0c-f2c386662b7f">' .
                '<bdi>Chicago</bdi>' .
            '</a>, ' .
            '<a href="/area/8c2196d9-b7be-4051-90d1-ac81895355f1">' .
                '<bdi>Illinois</bdi>' .
            '</a>, ' .
            '<a href="/area/489ce91b-6658-3307-9877-795b68554c98">' .
                '<bdi>United States</bdi>' .
            '</a>',

            $chicago,
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<a href="/artist/070d193a-845c-479f-980e-bef15710653e" title="Prince (“The Artist Formerly Known as…”)">' .
                '<bdi>Prince</bdi>' .
            '</a> ' . # space required
            '<span class="comment">(<bdi>“The Artist Formerly Known as…”</bdi>)</span>',

            Artist->new(
                id => 153,
                gid => '070d193a-845c-479f-980e-bef15710653e',
                name => 'Prince',
                sort_name => 'Prince',
                comment => '“The Artist Formerly Known as…”',
            ),
        ],
        [
            "link_entity(entity, 'show', 'The Artist Formerly Known as Prince')",
            "React.createElement(EntityLink, {entity: entity, content: 'The Artist Formerly Known as Prince'})",

            '<span class="mp">' .
                '<span class="name-variation">' .
                    '<a href="/artist/070d193a-845c-479f-980e-bef15710653e" title="Prince – Prince">' .
                        '<bdi>The Artist Formerly Known as Prince</bdi>' .
                    '</a>' .
                '</span>' .
            '</span>',
            # disambiguation comment is supressed if name-variation is used

            Artist->new(
                id => 153,
                gid => '070d193a-845c-479f-980e-bef15710653e',
                name => 'Prince',
                sort_name => 'Prince',
                edits_pending => 1,
            ),
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<span class="deleted tooltip" title="This entity has been removed, and cannot be displayed correctly.">' .
                '<bdi>[removed]</bdi>' .
            '</span>',

            Artist->new,
        ],
        [
            "allow_new=1; link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity, allowNew: true})",

            '<span class="tooltip" title="This entity will be created by this edit.">' .
                '<bdi>[removed]</bdi>' .
            '</span>',

            Artist->new,
        ],
        [
            "link_entity(entity)",
            "React.createElement(EditorLink, {editor: entity})",

            '<a href="/user/%3C%2FBitmap%3E">' .
                '<img src="//gravatar.com/avatar/9636b32d588adb5f86431818cbb630bd?d=mm&amp;s=24" height="12" width="12" class="gravatar" alt="" />' .
                '<bdi>&lt;/Bitmap&gt;</bdi>' .
            '</a>',

            Editor->new(
                id => 58244,
                name => '</Bitmap>',
                email => 'Bitmap@example.com',
                preferences => MusicBrainz::Server::Entity::Preferences->new(
                    show_gravatar => 1,
                ),
            ),
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<span class="mp">' .
                '<a href="/event/8dcc36ec-d5eb-40a6-86c0-1111dbdf6f7e">' .
                    '<bdi>Wussy / The Royal Pines at The Red Line Tap</bdi>' .
                '</a>' .
            '</span> ' . # space required
            '(2014-11-22) ' . # space required
            '<span class="cancelled">(<bdi>cancelled</bdi>)</span> ' . # space required
            '<span class="comment">(<bdi>&lt;/div&gt;</bdi>)</span>',

            Event->new(
                id => 3,
                gid => '8dcc36ec-d5eb-40a6-86c0-1111dbdf6f7e',
                name => 'Wussy / The Royal Pines at The Red Line Tap',
                comment => '</div>',
                cancelled => 1,
                begin_date => PartialDate->new(year => 2014, month => 11, day => 22),
                end_date => PartialDate->new(year => 2014, month => 11, day => 22),
                edits_pending => 1,
            ),
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<a href="/label/59fd412e-71df-45b7-97be-37874136fe33">' .
                '<bdi>Flying Nun Records</bdi>' .
            '</a>',

            Label->new(
                id => 7108,
                gid => '59fd412e-71df-45b7-97be-37874136fe33',
                name => 'Flying Nun Records',
            ),
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<span class="deleted tooltip" title="This entity has been removed, and cannot be displayed correctly.">' .
                '<bdi>Flying Nun Records</bdi>' .
            '</span>',

            Label->new(
                name => 'Flying Nun Records',
            ),
        ],
        [
            "allow_new=1; link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity, allowNew: true})",

            '<span class="tooltip" title="This entity will be created by this edit.">' .
                '<bdi>Flying Nun Records</bdi>' .
            '</span>',

            Label->new(
                name => 'Flying Nun Records',
            ),
        ],
        [
            "descriptive_link(entity)",
            "React.createElement(DescriptiveLink, {entity: entity})",

            '<a href="/place/c4962c57-0bd7-48b1-9e38-eef6c6f331e3">' .
                '<bdi>Empty Bottle</bdi>' .
            '</a> in ' .
            '<a href="/area/29a709d8-0320-493e-8d0c-f2c386662b7f">' .
                '<bdi>Chicago</bdi>' .
            '</a>, ' .
            '<a href="/area/8c2196d9-b7be-4051-90d1-ac81895355f1">' .
                '<bdi>Illinois</bdi>' .
            '</a>, ' .
            '<a href="/area/489ce91b-6658-3307-9877-795b68554c98">' .
                '<bdi>United States</bdi>' .
            '</a>',

            Place->new(
                area => $chicago,
                gid => 'c4962c57-0bd7-48b1-9e38-eef6c6f331e3',
                id => 6479,
                name => 'Empty Bottle',
            ),
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<a href="/recording/6a77d9f9-1641-4fc9-98a8-9f29552b0d40">' .
                '<bdi>Foo</bdi>' .
            '</a>',

            Recording->new(
                id => 1,
                gid => '6a77d9f9-1641-4fc9-98a8-9f29552b0d40',
                name => 'Foo',
            ),
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<span class="video" title="This recording is a video"></span>' .
            '<a href="/recording/6a77d9f9-1641-4fc9-98a8-9f29552b0d40">' .
                '<bdi>Foo</bdi>' .
            '</a>',

            Recording->new(
                id => 1,
                gid => '6a77d9f9-1641-4fc9-98a8-9f29552b0d40',
                name => 'Foo',
                video => 1,
            ),
        ],
        [
            "link_entity(entity, 'show', 'Bar')",
            "React.createElement(EntityLink, {entity: entity, content: 'Bar'})",

            '<span class="name-variation">' .
                '<a href="/recording/6a77d9f9-1641-4fc9-98a8-9f29552b0d40" title="Foo">' .
                    '<bdi>Bar</bdi>' .
                '</a>' .
            '</span>',

            Recording->new(
                id => 1,
                gid => '6a77d9f9-1641-4fc9-98a8-9f29552b0d40',
                name => 'Foo',
            ),
        ],
        [
            "descriptive_link(entity, 'Bar')",
            "React.createElement(DescriptiveLink, {entity: entity, content: 'Bar'})",

            '<span class="name-variation">' .
                '<a href="/recording/6a77d9f9-1641-4fc9-98a8-9f29552b0d40" title="Foo">' .
                    '<bdi>Bar</bdi>' .
                '</a>' .
            '</span>' .
            ' by ' .
            '<span class="name-variation">' .
                '<a href="/artist/91d882b6-5bf8-4d14-b261-15ea9b1d7eae" title="FooArtist – FooArtist">' .
                    '<bdi>BarArtist</bdi>' .
                '</a>' .
            '</span>' .
            ' &amp; ' .
            '<a href="/artist/9395ab04-7421-4091-ab7d-31a09c78d761" title="Collaborator">' .
                '<bdi>Collaborator</bdi>' .
            '</a>',

            Recording->new(
                id => 1,
                gid => '6a77d9f9-1641-4fc9-98a8-9f29552b0d40',
                name => 'Foo',
                artist_credit => ArtistCredit->new(
                    names => [
                        ArtistCreditName->new(
                            name => 'BarArtist',
                            artist => Artist->new(
                                id => 1,
                                gid => '91d882b6-5bf8-4d14-b261-15ea9b1d7eae',
                                name => 'FooArtist',
                                sort_name => 'FooArtist',
                            ),
                            join_phrase => ' & ',
                        ),
                        ArtistCreditName->new(
                            name => '',
                            artist => Artist->new(
                                id => 1,
                                gid => '9395ab04-7421-4091-ab7d-31a09c78d761',
                                name => 'Collaborator',
                                sort_name => 'Collaborator',
                            ),
                            join_phrase => '',
                        ),
                    ],
                ),
            ),
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<span class="mp">' .
                '<a href="http://www.example.com/%C3%A4%C3%9F%C3%B0">' .
                    '<bdi>http://www.example.com/äßð</bdi>' .
                '</a>' .
            '</span> ' . # space required
            '[<a href="/url/bb390409-9d96-4ac8-b02c-0f5ec289cd26">info</a>]',

            URL->new(
                id => 1,
                gid => 'bb390409-9d96-4ac8-b02c-0f5ec289cd26',
                name => 'http://www.example.com/äßð',
                edits_pending => 1,
            ),
        ],
        [
            "link_entity(entity, 'edit', '<foo> & \"')",
            "React.createElement(EntityLink, {entity: entity, subPath: 'edit', content: '<foo> & \"'})",

            '<a href="/url/f6337023-05b6-41eb-9031-b9bab8acae6a/edit">' .
                '<bdi>&lt;foo&gt; &amp; &quot;</bdi>' .
            '</a>',

            URL->new(
                id => 1,
                gid => 'f6337023-05b6-41eb-9031-b9bab8acae6a',
                name => 'http://www.example.com/',
            ),
        ],
        [
            "link_entity(entity)",
            "React.createElement(EntityLink, {entity: entity})",

            '<a href="http://xn--80aeafihs7aqfneip9p.xn--p1ai/">' .
                '<bdi>http://здравствуйпесня.рф/</bdi>' .
            '</a> ' . # space required
            '[<a href="/url/2de1616a-7ca0-4688-92cc-0a8373190ede">info</a>]',

            URL->new(
                id => 1705433,
                gid => '2de1616a-7ca0-4688-92cc-0a8373190ede',
                name => 'http://xn--80aeafihs7aqfneip9p.xn--p1ai/',
            ),
        ],
        [
            q(
                USE Diff;
                acdiff = Diff.diff_artist_credits(entity.old, entity.new);
                '<div class="old">' _ acdiff.old _ '</div>';
                '<div class="new">' _ acdiff.new _ '</div>';
            ),

            q((function () {
                const acdiff = diffArtistCredits(entity['old'], entity['new']);
                return React.createElement(
                    React.Fragment,
                    null,
                    React.createElement('div', {className: 'old'}, acdiff.old),
                    React.createElement('div', {className: 'new'}, acdiff.new),
                );
            }())),

            '<div class="old">' .
                '<a href="/artist/3215500f-f03e-4adf-94fe-5ca842e17f5b" title="Hoenig, Michael">' .
                    '<bdi><span class="diff-only-a">Michael </span>Hoenig</bdi>' .
                '</a>' .
                ' <span class="diff-only-a">and</span> ' .
                '<a href="/artist/00e3ab6b-4c4f-4ed6-991f-461a0ffa01b3" title="Göttsching, Manuel">' .
                    '<bdi><span class="diff-only-a">Manuel </span>Göttsching</bdi>' .
                '</a>' .
            '</div>' .
            '<div class="new">' .
                '<span class="name-variation">' .
                    '<a href="/artist/3215500f-f03e-4adf-94fe-5ca842e17f5b" title="Michael Hoenig – Hoenig, Michael">' .
                        '<bdi>Hoenig</bdi>' .
                    '</a>' .
                '</span>' .
                ' <span class="diff-only-b">•</span> ' .
                '<span class="name-variation">' .
                    '<a href="/artist/00e3ab6b-4c4f-4ed6-991f-461a0ffa01b3" title="Manuel Göttsching – Göttsching, Manuel">' .
                        '<bdi>Göttsching</bdi>' .
                    '</a>' .
                '</span>' .
            '</div>',

            {
                old => ArtistCredit->new(
                    names => [
                        ArtistCreditName->new(
                            name => 'Michael Hoenig',
                            artist => Artist->new(
                                gid => '3215500f-f03e-4adf-94fe-5ca842e17f5b',
                                id => 105321,
                                name => 'Michael Hoenig',
                                sort_name => 'Hoenig, Michael',
                            ),
                            join_phrase => ' and ',
                        ),
                        ArtistCreditName->new(
                            name => 'Manuel Göttsching',
                            artist => Artist->new(
                                gid => '00e3ab6b-4c4f-4ed6-991f-461a0ffa01b3',
                                id => 117488,
                                name => 'Manuel Göttsching',
                                sort_name => 'Göttsching, Manuel',
                            ),
                            join_phrase => '',
                        ),
                    ],
                ),
                new => ArtistCredit->new(
                    names => [
                        ArtistCreditName->new(
                            name => 'Hoenig',
                            artist => Artist->new(
                                gid => '3215500f-f03e-4adf-94fe-5ca842e17f5b',
                                id => 105321,
                                name => 'Michael Hoenig',
                                sort_name => 'Hoenig, Michael',
                            ),
                            join_phrase => ' • ',
                        ),
                        ArtistCreditName->new(
                            name => 'Göttsching',
                            artist => Artist->new(
                                gid => '00e3ab6b-4c4f-4ed6-991f-461a0ffa01b3',
                                id => 117488,
                                name => 'Manuel Göttsching',
                                sort_name => 'Göttsching, Manuel',
                            ),
                            join_phrase => '',
                        ),
                    ],
                ),
            },
        ],
        # MBS-8709
        [
            q(
                USE Diff;
                acdiff = Diff.diff_artist_credits(entity.old, entity.new);
                '<div class="old">' _ acdiff.old _ '</div>';
                '<div class="new">' _ acdiff.new _ '</div>';
            ),

            q((function () {
                const acdiff = diffArtistCredits(entity['old'], entity['new']);
                return React.createElement(
                    React.Fragment,
                    null,
                    React.createElement('div', {className: 'old'}, acdiff.old),
                    React.createElement('div', {className: 'new'}, acdiff.new),
                );
            }())),

            '<div class="old">' .
                '<a href="/artist/f27ec8db-af05-4f36-916e-3d57f91ecf5e" title="Jackson, Michael">' .
                    '<bdi><span class="diff-only-a">Michael Jackson</span></bdi>' .
                '</a>' .
            '</div>' .
            '<div class="new">' .
                '<span class="deleted tooltip" title="This entity has been removed, and cannot be displayed correctly.">' .
                    '<bdi><span class="diff-only-b">The Jacksons</span></bdi>' .
                '</span>' .
            '</div>',

            {
                old => ArtistCredit->new(
                    names => [
                        ArtistCreditName->new(
                            name => 'Michael Jackson',
                            artist => Artist->new(
                                gid => 'f27ec8db-af05-4f36-916e-3d57f91ecf5e',
                                id => 519,
                                name => 'Michael Jackson',
                                sort_name => 'Jackson, Michael',
                            ),
                            join_phrase => '',
                        )
                    ],
                ),
                new => ArtistCredit->new(
                    names => [
                        ArtistCreditName->new(
                            name => 'The Jacksons',
                            artist => Artist->new(
                                id => 56345,
                                name => 'The Jacksons',
                                sort_name => 'Jacksons, The',
                            ),
                            join_phrase => '',
                        )
                    ],
                ),
            },
        ],
        # MBS-8709
        [
            q(
                PROCESS 'edit/details/macros.tt';
                display_word_diff('Name:', entity.old, entity.new);
            ),

            'React.createElement(WordDiff, {label: "Name:", oldText: entity.old, newText: entity.new})',

            '<tr>' .
                '<th>Name:</th>' .
                '<td class="old">' .
                    '<span class="diff-only-a">The Only Michael - </span>Someone Else&#x27;s Fur' .
                '</td>' .
                '<td class="new">' .
                    'Someone Else&#x27;s Fur' .
                '</td>' .
            '</tr>',

            {
                old => "The Only Michael - Someone Else's Fur",
                new => "Someone Else's Fur",
            },
        ],
        [
            q(
                PROCESS 'edit/details/macros.tt';
                display_word_diff('Name:', entity.old, entity.new);
            ),

            'React.createElement(WordDiff, {label: "Name:", oldText: entity.old, newText: entity.new})',

            '<tr>' .
                '<th>Name:</th>' .
                '<td class="old">' .
                    '<span class="diff-only-a">Some random</span> text' .
                '</td>' .
                '<td class="new">' .
                    '<span class="diff-only-b">Other arbitrary</span> text' .
                '</td>' .
            '</tr>',

            {
                old => 'Some random text',
                new => 'Other arbitrary text',
            },
        ],
        [
            q(
                PROCESS 'edit/details/macros.tt';
                display_word_diff('Name:', entity.old, entity.new);
            ),

            'React.createElement(WordDiff, {label: "Name:", oldText: entity.old, newText: entity.new})',

            '<tr>' .
                '<th>Name:</th>' .
                '<td class="old">' .
                    'Die <span class="diff-only-a">Diebische</span> ' .
                    'Elster (La <span class="diff-only-a">Gazza Ladra)</span> ' .
                    '(The Theiving Magpie · La <span class="diff-only-a">Pie Voleuse)</span>' .
                '</td>' .
                '<td class="new">' .
                    'Die <span class="diff-only-b">diebische</span> ' .
                    'Elster (La <span class="diff-only-b">gazza ladra)</span> ' .
                    '(The Theiving Magpie · La <span class="diff-only-b">pie voleuse)</span>' .
                '</td>' .
            '</tr>',

            {
                old => 'Die Diebische Elster (La Gazza Ladra) (The Theiving Magpie · La Pie Voleuse)',
                new => 'Die diebische Elster (La gazza ladra) (The Theiving Magpie · La pie voleuse)',
            },
        ],
        [
            q(
                PROCESS 'edit/details/macros.tt';
                display_full_change('Name:', entity.old, entity.new);
            ),

            'React.createElement(FullChangeDiff, {label: "Name:", oldContent: entity.old, newContent: entity.new})',

            '<tr>' .
                '<th>Name:</th>' .
                '<td class="old">Old</td>' .
                '<td class="new">New</td>' .
            '</tr>',

            {
                old => 'Old',
                new => 'New',
            },
        ],
        [
            q(
                PROCESS 'edit/details/macros.tt';
                display_diff('Codes:', entity.old, entity.new, ', ');
            ),

            'React.createElement(Diff, {label: "Codes:", oldText: entity.old, newText: entity.new, split: ", "})',

            '<tr>' .
                '<th>Codes:</th>' .
                '<td class="old">A A, <span class="diff-only-a">B B, </span>C C</td>' .
                '<td class="new">A A, C C<span class="diff-only-b">, D D</span></td>' .
            '</tr>',

            {
                old => 'A A, B B, C C',
                new => 'A A, C C, D D',
            },
        ],
    );

    my $json = JSON::XS->new->allow_blessed->convert_blessed->utf8;

    my $test_data = shell_quote($json->encode([
        map {
            my ($tt_macro, $react_element, $expected, $entity) = @{$_};

            $ctx->stash(c => $ctx, entity => $entity, template => \"[% $tt_macro %]");
            $ctx->view->process($ctx);

            {
                tt_markup => trim($ctx->response->body),
                react_element => $react_element,
                expected_markup => $expected,
                entity => blessed($entity) ? $entity->TO_JSON : $entity,
            };
        } @tests
    ]));

    my $test_results = $json->decode(
        `node ./root/static/build/react-macros-tests.js $test_data`
    );

    for (@$test_results) {
        is($_, 'ok');
    }
};

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2012 MetaBrainz Foundation
Copyright (C) 2016 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
