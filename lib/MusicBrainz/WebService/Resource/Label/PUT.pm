package MusicBrainz::WebService::Resource::Label::PUT;
use Moose;

with 'Sloth::Method';

use Data::TreeValidator::Constraints qw( required );
use Data::TreeValidator::Sugar qw( branch leaf );
use HTTP::Throwable::Factory qw( http_throw );
use HTTP::Status qw( HTTP_CREATED HTTP_OK );
use MusicBrainz::Server::Constants qw( $EDIT_LABEL_EDIT );
use MusicBrainz::Data::TreeValidator::Constraints qw( integer partial_date );
use MusicBrainz::Data::TreeValidator::Transformations qw( collapse_whitespace );
use MusicBrainz::WebService::RequestParser::JSON;

has '+request_parsers' => (
    default => sub {
        { 'application/json' => MusicBrainz::WebService::RequestParser::JSON->new }
    }
);

has '+request_data_validator'  => (
    default => sub {
        branch {
            mbid => leaf(constraints => [ required ]),
           'name' => leaf( constraints => [ required ], transformations => [ collapse_whitespace ] ),
           'sort-name' => leaf( constraints => [ required ], transformations => [ collapse_whitespace ] ),
           'life-span' => branch {
               'begin' => leaf( constraints => [ partial_date ] ),
               'end' => leaf( constraints => [ partial_date ] ),
           }
       }
    }
);

sub execute {
    my ($self, $params, $request) = @_;
    my $label = $self->c->model('Label')->get_by_gid($params->{mbid}) or http_throw('NotFound');

    if ($params->{'life-span'}) {
        my $lifespan = delete $params->{'life-span'};

        $params->{begin_date} = partial_date_to_hash (
            partial_date_from_string ($lifespan->{begin})) if $lifespan->{begin};
        $params->{end_date}  = partial_date_to_hash (
            partial_date_from_string ($lifespan->{end})) if $lifespan->{end};
    }

    $params->{sort_name} = delete $params->{'sort-name'};

    my ($res, $edit);
    try {
        $edit = $self->c->model('Edit')->create(
            edit_type => $EDIT_LABEL_EDIT,
            #editor_id => $c->user->id,
            #privileges => $self->c->user->privileges,
            to_edit => $label,
            %$params
        );

        $res = Sloth::Response(
            HTTP_CREATED,
            [
                Location => 'http://musicbrainz.org/edit/' . $edit->id
            ],
        );
    }
    catch {
        if (ref($_) eq 'MusicBrainz::Server::Edit::Exceptions::NoChanges') {
            http_throw(
                HTTP_OK,
                [
                    Location => $request->uri_for(
                        resource => 'label',
                        mbid => $label->mbid
                    )
                ]
            );
        }
        else {
            die $_;
        }
    };
}

1;
