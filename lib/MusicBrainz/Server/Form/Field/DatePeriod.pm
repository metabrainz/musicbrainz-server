package MusicBrainz::Server::Form::Field::DatePeriod;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use List::AllUtils qw ( any );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_date_range_valid );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
extends 'HTML::FormHandler::Field::Compound';

has_field 'begin_date' => (
    type => '+MusicBrainz::Server::Form::Field::PartialDate',
    not_nullable => 1
);

has_field 'end_date' => (
    type => '+MusicBrainz::Server::Form::Field::PartialDate',
    not_nullable => 1
);

has_field 'ended' => (
    type => 'Checkbox',
    input_without_param => undef,
);

after 'validate' => sub {
    my $self = shift;
    my $begin = $self->field('begin_date')->value;
    my $end   = $self->field('end_date')->value;

    return if any { $_->has_errors } map { $_, $_->fields }
        $self->field('begin_date'), $self->field('end_date');

    if ($end->{year} || $end->{month} || $end->{day}) {
        $self->field('ended')->value(1);
    }

    return 1 unless $begin->{year} && $end->{year};

    unless (is_date_range_valid($begin, $end)) {
        return $self->add_error(l('The end date cannot precede the begin date.'));
    }

    return 1;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
