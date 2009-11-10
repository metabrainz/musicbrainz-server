package MusicBrainz::Server::WebService::Validator;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::WebService::WebServiceInc;

parameter defs => (
   isa => 'ArrayRef',
);

our (%types, %statuses);
sub load_type_and_status
{
    my ($c) = @_;

    my @types = $c->model('ReleaseGroupType')->get_all();
    %types = map { my $n = $_->name; lc("sa-$n") => $_->id; } @types;
    my @statuses = $c->model('ReleaseStatus')->get_all();
    %statuses = map { my $n = $_->name; lc("sa-$n") => $_->id; } @statuses;
}

sub validate_inc
{
    my ($c,$inc, $def) = @_;

    my @inc = split(/[+ ]/, $inc);
    my %acc = map { $_ => 1 } @{ $def };
    my $allow_type = exists $acc{"rg_type"};
    my $allow_status = exists $acc{"rel_status"};
    my $type_used = 0;
    my $status_used = 0;
    my @filtered;
    for my $i (@inc) 
    {
        if ($allow_type && exists $types{$i})
        {
            if ($type_used)
            {
                $c->stash->{error} = "Only one type filter (e.g. $i) may be used per request.";
                return;
            }
            $type_used = $types{$i};
            next;
        }
        if ($allow_status && exists $statuses{$i})
        {
            if ($status_used)
            {
                $c->stash->{error} = "Only one status filter (e.g. $i) may be used per request.";
                return;
            }
            $status_used = $statuses{$i};
            next;
        }
        if (!exists $acc{$i})
        {
            $c->stash->{error} = "$i is not a valid option for the inc parameter for this resource.";
            return;
        }
        push @filtered, $i;
    }
    return MusicBrainz::Server::WebService::WebServiceInc->new(inc => \@filtered,
                                                               rg_type => $type_used, 
                                                               rel_status => $status_used);
}

role {
    my $r = shift;
    
    method 'validate' => sub 
    {
        my ($self, $c, $serializers) = @_;

        load_type_and_status($c) if (!%types);

        # Set up the serializers so we can report errors in the correct format
        $c->stash->{serializer} = $serializers->{$c->req->params->{type}}->new();

        my $resource = $c->req->path;
        $resource =~ s/ws\/2\/(\w+?)\/.*$/$1/;

        foreach my $def (@{ $r->defs })
        {
            # Match the call type
            next if ($resource ne $def->[0]);
            next if ($c->req->method ne $def->[1]->{method});

            # Check to make sure that required arguments are present
            my $params_ok = 1;
            foreach my $arg (@{ $def->[1]->{required} })
            {
                if ($c->req->params->{$arg} eq '')
                {
                    $params_ok = 0;
                    last;
                }
                $c->stash->{args}->{$arg} = $c->req->params->{$arg};
            }
            next unless $params_ok;

            # Check to make sure that only appropriate inc values have been requested
            my $inc;
            if ($def->[1]->{inc})
            {
                $inc = validate_inc($c, $c->req->params->{inc}, $def->[1]->{inc});
                return 0 unless ($inc);
            }

            # Check the type and prepare a serializer
            my $type = $c->req->params->{type};
            unless (defined($type) && exists $serializers->{$type}) {
                my @types = keys %{$serializers};
                $c->stash->{error} = 'Invalid content type. Must be set to ' . join(' or ', @types) . '.';
                $c->detach('bad_req');
            }

            # All is well! Set up the stash!
            $c->stash->{inc} = $inc;
            return 1;
        }
        $c->stash->{error} = "The given parameters do not match any available query type for the $resource resource.";
        return 0;

    }
};

1;
