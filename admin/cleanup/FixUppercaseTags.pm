#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use MusicBrainz::Server::Constants qw( entities_with );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Data::Utils qw( type_to_model );

my $c = MusicBrainz::Server::Context->create_script_context(database => 'READWRITE');
my $rows = $c->sql->select_list_of_hashes('SELECT * FROM tag WHERE name ~ E\'[A-Z]\'');

for my $entity_type (entities_with('tags')) {
    my $tags_model = $c->model(type_to_model($entity_type))->tags;

    for my $row (@$rows) {
        my $bad_raw_tags = $c->sql->select_list_of_hashes(
            "SELECT * FROM ${entity_type}_tag_raw WHERE tag = ?", $row->{id}
        );

        for my $bad_raw_tag (@$bad_raw_tags) {
            my $vote_method = $bad_raw_tag->{is_upvote} ? 'upvote' : 'downvote';

            my $editor_id = $bad_raw_tag->{editor};
            my $entity_id = $bad_raw_tag->{$entity_type};

            print "$vote_method editor=$editor_id $entity_type=$entity_id tag=" . lc($row->{name}) . "\n";
            $tags_model->$vote_method($editor_id, $entity_id, lc($row->{name}));

            print "withdraw editor=$editor_id $entity_type=$entity_id tag=" . $row->{name} . "\n";
            $tags_model->withdraw($editor_id, $entity_id, $row->{name});
        }
    }
}
