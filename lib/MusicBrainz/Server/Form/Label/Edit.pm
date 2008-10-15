package MusicBrainz::Server::Form::Label::Edit;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Label::Base';

sub mod_type { ModDefs::MOD_EDIT_LABEL }

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
        type => ModDefs::MOD_EDIT_LABEL,

        label      => $label,
        name       => $self->value('name')        || $label->name,
        sortname   => $self->value('sort_name')   || $label->sort_name,
        labeltype  => $self->value('type')        || $label->type,
        resolution => $self->value('resolution')  || $label->resolution,
        country    => $self->value('country')     || $label->country,
        labelcode  => $self->value('label_code')  || $label->label_code || '',

        begindate => $begin,
        enddate   => $end,
    };
}

1;
