package MusicBrainz::Server::Form::Label::Create;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Label::Base';

sub mod_type { ModDefs::MOD_ADD_LABEL }

sub build_options
{
    my $self = shift;

    my $label = $self->item;

    my ($begin, $end) =
        (
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('begin_date') || '') ],
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('end_date')   || '') ],
        );

    return {
        name             => $self->value('name'),
        sortname         => $self->value('sort_name'),
        labeltype        => $self->value('type'),
        label_resolution => $self->value('resolution'),
        label_country    => $self->value('country'),
        labelcode        => $self->value('label_code'),

        label_begindate => $begin,
        label_enddate   => $end,
    };
}

1;
