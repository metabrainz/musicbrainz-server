package t::MusicBrainz::Server::Controller::WS::2::Validator;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use utf8;

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks different request validation options for API.

=cut

test 'Release group type validation' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?type=live');
    $mech->content_contains(
        'type is not a valid parameter',
        'Type is not allowed for bare artist request',
    );
    is($mech->status, 400, 'A Bad Request error is returned');

    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=release-groups&type=live');
    $mech->content_lacks(
        'type is not a valid parameter',
        'Type is allowed for artist request including release groups',
    );
    is($mech->status, 200, 'No error is returned');

    $mech->get('/ws/2/release-group/b84625af-6229-305f-9f1b-59c0185df016?type=live');
    $mech->content_lacks(
        'type is not a valid parameter',
        'Type is allowed for release group request',
    );
    is($mech->status, 200, 'No error is returned');

    $mech->get('/ws/2/release-group/b84625af-6229-305f-9f1b-59c0185df016?type=hahaha');
    $mech->content_contains(
        'hahaha is not a recognized release-group type',
        'Non-existing type is not allowed',
    );
    is($mech->status, 400, 'A Bad Request error is returned');
};

test 'Release status and type validation' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get('/ws/2/label/b4edce40-090f-4956-b82a-5d9d285da40b?status=official');
    $mech->content_contains(
        'status is not a valid parameter',
        'Status is not allowed for bare label request',
    );
    is($mech->status, 400, 'A Bad Request error is returned');

    $mech->get('/ws/2/label/b4edce40-090f-4956-b82a-5d9d285da40b?type=live');
    $mech->content_contains(
        'type is not a valid parameter',
        'Type is not allowed for bare label request',
    );
    is($mech->status, 400, 'A Bad Request error is returned');

    $mech->get('/ws/2/label/b4edce40-090f-4956-b82a-5d9d285da40b?inc=releases&status=official&type=live');
    $mech->content_lacks(
        'status is not a valid parameter',
        'Status is allowed for label request including releases',
    );
    $mech->content_lacks(
        'type is not a valid parameter',
        'Type is allowed for label request including releases',
    );
    is($mech->status, 200, 'No error is returned');

    $mech->get('/ws/2/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?status=official&type=live');
    $mech->content_lacks(
        'status is not a valid parameter',
        'Status is allowed for release request',
    );
    $mech->content_lacks(
        'type is not a valid parameter',
        'Type is allowed for release request',
    );
    is($mech->status, 200, 'No error is returned');

    $mech->get('/ws/2/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?status=hehehe');
    $mech->content_contains(
        'hehehe is not a recognized release status',
        'Non-existing status is not allowed',
    );
    is($mech->status, 400, 'A Bad Request error is returned');

    $mech->get('/ws/2/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?type=hahaha');
    $mech->content_contains(
        'hahaha is not a recognized release-group type',
        'Non-existing type is not allowed',
    );
    is($mech->status, 400, 'A Bad Request error is returned');
};

test 'Tag auth validation' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get('/ws/2/tag/?query=electronica');
    $mech->content_lacks(
        'You are not authorized to access this resource',
        'Querying for a tag does not require log in',
    );
    # We can't test for 200 because circleci will 503 due to no search server
    isnt($mech->status, 401, 'An Unauthorized error is not returned');

    $mech->get('/ws/2/tag?id=1946a82a-f927-40c2-8235-38d64f50d043&entity=artist');
    $mech->content_contains(
        'You are not authorized to access this resource',
        'Querying for user tags for an entity requires log in',
    );
    is($mech->status, 401, 'An Unauthorized error is returned');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'whoever', 'whatever');

    $mech->get('/ws/2/tag?id=1946a82a-f927-40c2-8235-38d64f50d043&entity=artist');
    $mech->content_contains(
        'Your credentials could not be verified',
        'Wrong log in information returns the expected message',
    );
    is($mech->status, 401, 'An Unauthorized error is returned');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'the-anti-kuno', 'notreally');

    $mech->get('/ws/2/tag?id=1946a82a-f927-40c2-8235-38d64f50d043&entity=artist');
    $mech->content_lacks(
        'You are not authorized to access this resource',
        'Querying for user tags for an entity works when logged in',
    );
    $mech->content_lacks(
        'Your credentials could not be verified',
        'Correct log in information is accepted',
    );
    is($mech->status, 200, 'No error is returned');
};

test 'inc validation' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get('/ws/2/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c?inc=aliases&inc=annotation');
    $mech->content_contains(
        'Inc arguments must be combined with a space',
        'Multiple inc= parameters are not allowed',
    );
    is($mech->status, 400, 'A Bad Request error is returned');

    $mech->get('/ws/2/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c?inc=aliases%20annotation');
    $mech->content_lacks(
        'Inc arguments must be combined with a space',
        'Multiple inc arguments can be passed with a %20 space separator',
    );
    is($mech->status, 200, 'No error is returned');

    $mech->get('/ws/2/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c?inc=aliases+annotation');
    $mech->content_lacks(
        'Inc arguments must be combined with a space',
        'Multiple inc arguments can be passed with a + space separator',
    );
    is($mech->status, 200, 'No error is returned');

    $mech->get('/ws/2/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c?inc=hahaha');
    $mech->content_contains(
        'hahaha is not a valid inc parameter for the work resource',
        'Invalid inc= parameters are not allowed',
    );
    is($mech->status, 400, 'A Bad Request error is returned');

    $mech->get('/ws/2/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?inc=mediums');
    $mech->content_lacks(
        'mediums is not a valid inc parameter for the release resource',
        '"mediums" is allowed as an inc alias for "media" on release request',
    );
    is($mech->status, 200, 'No error is returned');

    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=media');
    $mech->content_contains(
        'media is not a valid option for the inc parameter ' .
        'for the artist resource unless you specify ' .
        'one of the following other inc parameters: releases',
        '"media" is not allowed on its own for artist request',
    );
    is($mech->status, 400, 'A Bad Request error is returned');

    $mech->get('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=media+releases');
    $mech->content_lacks(
        'media is not a valid option for the inc parameter',
        '"media" is allowed for artist request when combined with "releases"',
    );
    is($mech->status, 200, 'No error is returned');
};

test 'Required/linked validation' => sub {
    my $test = shift;
    my $mech = $test->mech;

    prepare_test($test);

    $mech->get('/ws/2/tag?id=1946a82a-f927-40c2-8235-38d64f50d043');
    $mech->content_contains(
        'The given parameters do not match any available query type',
        'A tag lookup call without "entity" fails since that is required',
    );
    is($mech->status, 400, 'A Bad Request error is returned');

    $mech->get('/ws/2/recording?artists=3088b672-fba9-4b4b-8ae0-dce13babfbb4');
    $mech->content_contains(
        'The given parameters do not match any available query type',
        'A recording browse call with a non-supported linked type fails',
    );
    is($mech->status, 400, 'A Bad Request error is returned');
};

sub prepare_test {
    my $test = shift;

    $test->mech->default_header('Accept' => 'application/xml');

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');
}

1;
