package MusicBrainz::Server::Entity::Role::DatePeriod;
use Moose::Role;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Translation qw( l );

has 'begin_date' => (
    is => 'rw',
    isa => 'PartialDate',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::PartialDate->new() },
);

has 'end_date' => (
    is => 'rw',
    isa => 'PartialDate',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::PartialDate->new() },
);

has 'ended' => (
    is => 'rw',
    isa => 'Bool',
);

sub period {
    my $self = shift;
    return {
        begin_date => $self->begin_date,
        end_date => $self->end_date,
        ended => $self->ended,
    };
}

has 'formatted_date' => (
    is => 'ro',
    builder => '_build_formatted_date',
    lazy => 1,
);

sub _build_formatted_date {
    my ($self) = @_;

    my $begin_date = $self->begin_date;
    my $end_date = $self->end_date;
    my $ended = $self->ended;

    if ($begin_date->is_empty && $end_date->is_empty) {
        return $ended ? l(' &#x2013; ????') : '';
    }
    if ($begin_date->format eq $end_date->format) {
        return $begin_date->format;
    }
    if (!$begin_date->is_empty && !$end_date->is_empty) {
        return l('{begindate} &#x2013; {enddate}',
            { begindate => $begin_date->format, enddate => $end_date->format });
    }
    if ($begin_date->is_empty) {
        return l('&#x2013; {enddate}', { enddate => $end_date->format });
    }
    if ($end_date->is_empty) {
        return $ended ?
            l('{begindate} &#x2013; ????',
              { begindate => $begin_date->format }) :
            l('{begindate} &#x2013;',
              { begindate => $begin_date->format });
    }
    return '';
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        begin_date  => $self->begin_date->is_empty ? undef : $self->begin_date->TO_JSON,
        end_date    => $self->end_date->is_empty ? undef : $self->end_date->TO_JSON,
        ended       => boolean_to_json($self->ended),
    };
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Kuno Woudt, 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
