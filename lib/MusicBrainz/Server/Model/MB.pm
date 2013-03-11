package MusicBrainz::Server::Model::MB;
use Moose;

extends 'Catalyst::Model';

use DBDefs;
use Module::Pluggable::Object;
use MusicBrainz::Server::Context;

has 'context' => (
    isa        => 'MusicBrainz::Server::Context',
    is         => 'rw',
    lazy_build => 1,
    handles    => [qw( cache dbh )] # XXX Hack - Model::Feeds should be in Data
);

sub with_transaction {
    my ($self, $code) = @_;
    Sql::run_in_transaction($code, $self->context->sql);
}

sub _build_context {
    my $self = shift;

    if (DBDefs->_RUNNING_TESTS()) {
        require MusicBrainz::Server::Test;
        return MusicBrainz::Server::Test->create_test_context;
    }
    else {
        my $cache_opts = DBDefs->CACHE_MANAGER_OPTIONS;
        my $c = MusicBrainz::Server::Context->new(
            cache_manager => MusicBrainz::Server::CacheManager->new($cache_opts)
        );
        return $c;
    }
}

sub models {
    my @models;

    my @exclude = qw( Alias AliasType EntityAnnotation Rating Utils );
    my $searcher = Module::Pluggable::Object->new(
        search_path => 'MusicBrainz::Server::Data',
        except      => [ map { "MusicBrainz::Server::Data::$_" } @exclude ]
    );

    for my $model (sort $searcher->plugins) {
        next if $model =~ /Data::Role/;
        my ($model_name) = ($model =~ m/.*::Data::(.*)/);
        $model =~ s/^MusicBrainz::Server::Data:://;

        push @models, [ $model => "MusicBrainz::Server::Model::$model_name" ];
    }

    push @models, [ 'Email' => 'MusicBrainz::Server::Model::Email' ];

    return @models;
}

sub BUILD {
    my ($self, $args) = @_;
    for my $model ($self->models) {
        my $dao = $self->context->model($model->[0]);
        Class::MOP::Class->create(
            $model->[1] =>
                methods => {
                    ACCEPT_CONTEXT => sub {
                        return $dao
                    }
                });
    }
}

sub expand_modules {
    my $self = shift;
    return map { $_->[1] } $self->models;
}

1;
