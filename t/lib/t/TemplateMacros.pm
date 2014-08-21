package t::TemplateMacros;
use Test::More;
use Test::Routine;

use MusicBrainz::Server::Test;

use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::Label';
use aliased 'MusicBrainz::Server::Entity::Recording';
use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::ReleaseGroup';
use aliased 'MusicBrainz::Server::Entity::Work';

test all => sub {

    my $c = MusicBrainz::Server::Test->mock_context;

    my %entities = (
        artist => Artist->new(
            name => 'RJD2',
            gid => '60ffeab0-ecaf-11de-8a39-0800200c9a66',
        ),
        label => Label->new(
            name => 'Shogun Audio',
            gid => '60ffeab0-ecaf-11de-8a39-0800200c9a66',
        ),
        release => Release->new(
            name => 'J.A.C',
            gid => '60ffeab0-ecaf-11de-8a39-0800200c9a66',
        ),
        release_group => ReleaseGroup->new(
            name => 'Symmetry',
            gid => '60ffeab0-ecaf-11de-8a39-0800200c9a66',
        ),
        recording => Recording->new(
            name => 'Offkey',
            gid => '60ffeab0-ecaf-11de-8a39-0800200c9a66',
        ),
        work => Work->new(
            name => 'Moonlight Sonata',
            gid => '60ffeab0-ecaf-11de-8a39-0800200c9a66',
        ),
        );

    while (my ($type, $entity) = each %entities) {
        my $link = "link_$type";

        $c->mock_return(
            'uri_for_action' => sub {
                "/$type/" . $_[3]->[0]
            },
            args => [ "/$type/show", qr// ]
            );

        subtest "Testing $link" => sub {
            my $gid  = $entity->gid;
            my $name = $entity->name;

            my $template = "[% $link(entity) %]";
            my $out = MusicBrainz::Server::Test->evaluate_template($template, entity => $entity);

            like($out, qr{href="/$type/$gid"}, 'links to the entity');
            like($out, qr/$name/, 'has entity name');
            unlike($out, qr/class="mp"/, 'doesn\'t show edits pending');

            $entity->edits_pending(1);
            $out = MusicBrainz::Server::Test->evaluate_template($template, entity => $entity);

            like($out, qr{href="/$type/$gid"}, 'links to the entity');
            like($out, qr/$name/, 'has entity name');
            like($out, qr/class="mp"/, 'does show edits pending');

            done_testing;
        };
    }

};


=head1 LICENSE

Copyright (C) 2011-2012 MetaBrainz Foundation

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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

1;


