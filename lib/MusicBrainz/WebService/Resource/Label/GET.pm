package MusicBrainz::WebService::Resource::Label::GET;
use Moose;

with 'Sloth::Method';

use Data::TreeValidator::Constraints qw( required );
use Data::TreeValidator::Sugar qw( branch leaf );
use HTTP::Throwable::Factory qw( http_throw );

has '+request_data_validator'  => (
    default => sub {
        branch {
            mbid => leaf(constraints => [ required ])
        }
    }
);

sub execute {
    my ($self, $params) = @_;
    return $self->c->model('Label')->get_by_gid($params->{mbid})
        or http_throw('NotFound');
}

1;
