package MusicBrainz::Server::Controller::WS::js::SetCollectionComment;
use Moose;
use namespace::autoclean;
use utf8;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_database_row_id );

my $ws_defs = Data::OptList::mkopt([
    'set-collection-comment' => {
        method   => 'POST',
        required => [ qw( collection entity entity-type ) ],
    },
]);

with 'MusicBrainz::Server::WebService::Validator' => {
    defs => $ws_defs,
    version => 'js',
    default_serialization_type => 'json',
};

sub set_collection_comment : Chained('root') PathPart('set-collection-comment') {
    my ($self, $c) = @_;

    my $collection_id = $c->req->query_params->{collection};
    my $entity_id = $c->req->query_params->{entity};
    my $entity_type = $c->req->query_params->{'entity-type'};
    my $body = $c->req->body;
    my $comment = <$body>;

    $c->detach('bad_req') unless
        is_database_row_id($collection_id) &&
        is_database_row_id($entity_id) &&
        (
            exists $ENTITIES{$entity_type} &&
            $ENTITIES{$entity_type}{collections}
        );

    if ($c->stash->{server_details}->{is_mirror_db} || DBDefs->DB_READ_ONLY) {
        $c->forward('/ws/js/detach_with_error', ['this server is in read-only mode']);
    }

    $c->forward(
        '/ws/js/check_login',
        l('You must be logged in to edit collection comments. {url|Log in} ' .
         'first, and then try again.',
         { url => { href => $c->uri_for_action('/user/login'), target => '_blank' } },
        ),
    );

    $c->detach('/error_401')
        unless $c->user_exists &&
               $c->model('Collection')->is_collection_collaborator(
                   $c->user->id,
                   $collection_id);

    $c->model('MB')->with_transaction(sub {
        $c->model('Collection')->set_comment(
            $collection_id,
            $entity_id,
            $entity_type,
            $comment,
        );
    });
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
