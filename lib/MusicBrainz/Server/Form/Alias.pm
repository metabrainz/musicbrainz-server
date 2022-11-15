package MusicBrainz::Server::Form::Alias;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use DateTime::Locale;
use List::AllUtils qw( sort_by );
use MusicBrainz::Server::Constants qw( %ALIAS_LOCALES );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Form::Utils qw( select_options_tree indentation );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-alias' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1
);

has_field 'sort_name' => (
    type => '+MusicBrainz::Server::Form::Field::Text'
);

has_field 'locale' => (
    type     => 'Select',
    required => 0
);

has_field 'type_id' => (
    type => 'Select',
    required => 0
);

has_field 'primary_for_locale' => (
    type => 'Checkbox'
);

has_field 'period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod',
    not_nullable => 1
);

has 'id' => (
    isa => 'Int',
    is  => 'rw',
);

has 'parent_id' => (
    isa => 'Int',
    is  => 'ro',
    required => 1,
);

has 'alias_model' => (
    isa => 'MusicBrainz::Server::Data::Alias',
    is  => 'ro',
    required => 1
);

has search_hint_type_id => (
    isa => 'Int',
    is => 'ro',
    required => 1
);

sub edit_field_names {
    qw( name locale sort_name period.begin_date period.end_date
        period.ended type_id primary_for_locale )
}

sub _locale_name_special_cases {
    # Special-case some locales that have a non-descriptive name
    my $locale = shift;
    my $code = ($locale->code =~ s/-/_/gr);
    if ($code eq 'el_POLYTON') {
        return 'Greek Polytonic';
    } elsif ($code eq 'sr_Cyrl_YU') {
        return 'Serbian Cyrillic Yugoslavia';
    } elsif ($code eq 'sr_Latn_YU') {
        return 'Serbian Latin Yugoslavia';
    } else {
        return $locale->name;
    }
}

sub options_locale {
    my ($self, $field) = @_;
    return [
        map {
            my $code = $_;
            my $locale = $ALIAS_LOCALES{$code};
            {
                value => $code,
                label => indentation($code =~ /_/ ? 1 : 0) . _locale_name_special_cases($locale),
            };
        }
        sort_by { $ALIAS_LOCALES{$_}->name }
        keys %ALIAS_LOCALES
    ];
}

sub options_type_id {
    my $self = shift;
    select_options_tree($self->ctx, $self->alias_model->parent->alias_type);
}

sub validate_primary_for_locale {
    my $self = shift;
    if ($self->field('primary_for_locale')->value && !$self->field('locale')->value) {
        return $self->field('primary_for_locale')->add_error(
            l('This alias can only be a primary alias if a locale is selected'));
    }
}

after validate => sub {
    my $self = shift;

    if ($self->alias_model->exists({ name => $self->field('name')->value,
                                     locale => $self->field('locale')->value,
                                     type_id => $self->field('type_id')->value,
                                     not_id => $self->init_object ? $self->init_object->{id} : undef,
                                 })) {
        $self->field('name')->add_error(l('This alias already exists.'));
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
