package MusicBrainz::Server::WebService::Format;

use HTTP::Status qw( HTTP_NOT_ACCEPTABLE );
use MooseX::Role::Parameterized;
use REST::Utils qw( best_match );
use Class::Load qw( load_class );

parameter serializers => (
    is => 'ro',
    isa => 'ArrayRef',
);

sub _instance
{
    my $cls = shift;
    load_class($cls);
    $cls->new;
}

role {
    my $role = shift;

    method 'get_serialization' => sub
    {
        my ($self, $c) = @_;

        my %formats = map { $_->fmt => $_ } @{ $role->serializers };
        my %accepted = map { $_->mime_type => $_ } @{ $role->serializers };

        my $fmt = $c->request->parameters->{fmt};

        if (defined $fmt)
        {
            return _instance($formats{$fmt}) if $formats{$fmt};
        }
        else
        {
            # Default to application/xml when no accept header is specified.
            # (Picard does this, http://tickets.metabrainz.org/browse/PICARD-273).
            my $accept = $c->req->header('Accept');

            if ((!$accept || $accept eq '*/*') && exists $accepted{'application/xml'}) {
                $accept = 'application/xml';
            }

            my $match = best_match([ keys %accepted ], $accept);

            return _instance($accepted{$match}) if $match;
        }

        $c->stash->{error} = 'Invalid format. Either set an Accept header'
            . ' (recognized mime types are '. join (' and ', sort keys %accepted)
            . '), or include a fmt= argument in the query string (valid values'
            . ' for fmt are '. join (' and ', sort keys %formats) . ').';

        my $ser = $role->serializers->[0];

        $c->res->status(HTTP_NOT_ACCEPTABLE);
        $c->res->content_type($ser->mime_type . '; charset=utf-8');
        $c->res->body($ser->output_error($c->stash->{error}));
        $c->detach();
    };

};

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
