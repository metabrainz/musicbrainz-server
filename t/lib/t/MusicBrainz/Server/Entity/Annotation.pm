package t::MusicBrainz::Server::Entity::Annotation;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Entity::Annotation;
use MusicBrainz::Server::Entity::Artist;

=head1 DESCRIPTION

This test checks whether the annotation summaries are generated correctly.

=cut

test 'Annotation summary generation' => sub {
    my $text = <<~'TEXT';
        This is a ''test'' annotation

        This is more of the test annotation!

        And '''even''' ''more''.
        TEXT

    my $annotation = MusicBrainz::Server::Entity::Annotation->new(
        text => $text,
    );

    like(
        $annotation->summary,
        qr/This is a ''test'' annotation/,
        'The first paragraph of the annotation is shown in the summary',
    );
    unlike(
        $annotation->summary,
        qr/This is more of the test annotation!/,
        'The second paragraph of the annotation is not shown in the summary',
    );
    unlike(
        $annotation->summary,
        qr/And '''even''' ''more''\./,
        'The third paragraph of the annotation is not shown in the summary in markup form',
    );
    unlike(
        $annotation->summary,
        qr{And <strong>even</strong> <em>more</em>.},
        'The third paragraph of the annotation is not shown in the summary in HTML form either',
    );
    unlike(
        $annotation->summary,
        qr/\n/,
        'The summary does not contain line breaks',
    );

    my $artist = MusicBrainz::Server::Entity::Artist->new();
    $annotation->parent($artist);
    ok(defined $annotation->parent, 'Annotation parent entity can be set');

    $annotation = MusicBrainz::Server::Entity::Annotation->new(
        text => "This is...\nthe preview!\n\nMore text here",
    );

    like(
        $annotation->summary,
        qr/This is\.\.\./,
        'The first line of a multi-line first paragraph is shown in the summary',
    );
    like(
        $annotation->summary,
        qr/the preview!/,
        'The second line of a multi-line first paragraph is shown in the summary',
    );
    unlike(
        $annotation->summary,
        qr/More text here/,
        'The second paragraph of the annotation is not shown in the summary',
    );
    ok(
        $annotation->summary_is_short,
        'The annotation is correctly marked as having more content than displayed on the summary',
    );

    $annotation = MusicBrainz::Server::Entity::Annotation->new(
        text => 'This is a short annotation.',
    );

    like(
        $annotation->summary,
        qr/This is a short annotation\./,
        'The entirety of a one-line annotation is shown in the summary',
    );
    ok(
        !$annotation->summary_is_short,
        'The annotation is correctly marked as having all its content already displayed on the summary',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
