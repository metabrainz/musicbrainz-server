package MusicBrainz::Server::View::JSON;

use strict;
use warnings;
use JSON qw();
use MRO::Compat;

use base qw( Catalyst::View );

__PACKAGE__->mk_accessors(qw( encoder ));

sub new
{
    my ($class, $c, $arguments) = @_;

    my $self = $class->next::method($c);
    # we are not using properly encoded unicode strings and the JSON
    # module expects them, so we need to cheat here a little
    $self->encoder(JSON->new->latin1);

    return $self;
}

sub process
{
    my ($self, $c) = @_;

    my $data = $c->stash->{json};
    my $json = $self->encoder->encode($data);

    # opera doesn't like application/json
    if (($c->req->user_agent || '') =~ /Opera/) {
        $c->res->content_type("application/x-javascript; charset=UTF-8");
    } else {
        $c->res->content_type("application/json; charset=UTF-8");
    }

    # add UTF-8 BOM if the client is Safari
    if (($c->req->user_agent || '') =~ m/Safari/) {
        $json = "\xEF\xBB\xBF" . $json;
    }

    $c->res->output($json);
}

1;
