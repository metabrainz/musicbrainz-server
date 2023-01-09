package MusicBrainz::Server::Form::Utils;

use strict;
use warnings;

use MusicBrainz::Server::Data::Utils qw( sanitize );
use MusicBrainz::Server::Translation qw( l lp );
use List::AllUtils qw( sort_by );

use Sub::Exporter -setup => {
    exports => [qw(
                      language_options
                      script_options
                      select_options
                      select_options_tree
                      build_grouped_options
                      build_json
                      build_type_info
                      build_options_tree
                      indentation
                      validate_username
              )]
};

sub language_options {
    my $c = shift;
    my $context = shift // '';

    # group list of languages in <optgroups>.
    # most frequently used languages have hardcoded value 2.
    # languages which shouldn't be shown have hardcoded value 0.

    my $frequent = 2;
    my $skip = 0;

    my @languages = $c->model('Language')->get_all;
    if ($context eq 'editor') {
        for my $language (@languages) {
            if ($language->iso_code_3 && $language->iso_code_3 eq 'mul') {
                $language->frequency($skip);
            }
        }
    } elsif ($context eq 'work') {
        for my $language (@languages) {
            if ($language->iso_code_3 && $language->iso_code_3 eq 'zxx') {
                $language->name(l('[No lyrics]'));
                $language->frequency($frequent);
            }
        }
    }

    my $coll = $c->get_collator();
    my @sorted = sort_by { $coll->getSortKey($_->{label}) } map {
        {
            'value' => $_->id,
            'label' => $_->l_name,
            'class' => 'language',
            'optgroup' => $_->{frequency} eq $frequent ? lp('Frequently used', 'language optgroup') : lp('Other', 'language optgroup'),
            'optgroup_order' => $_->{frequency} eq $frequent ? 1 : 2,
        }
    } grep { $_->{frequency} ne $skip } @languages;

    return \@sorted;
}

sub script_options {
    my $c = shift;

    # group list of scripts in <optgroups>.
    # most frequently used scripts have hardcoded value 4.
    # scripts which shouldn't be shown have hardcoded value 1.

    my $frequent = 4;
    my $skip = 1;

    my $coll = $c->get_collator();
    my @sorted = sort_by { $coll->getSortKey($_->{label}) } map {
        {
            'value' => $_->id,
            'label' => $_->l_name,
            'class' => 'script',
            'optgroup' => $_->{frequency} eq $frequent ? lp('Frequently used', 'script optgroup') : lp('Other', 'script optgroup'),
            'optgroup_order' => $_->{frequency} eq $frequent ? 1 : 2,
        }
    } grep { $_->{frequency} ne $skip } $c->model('Script')->get_all;
    return \@sorted;
}

sub select_options
{
    my ($c, $model, %opts) = @_;

    my $model_ref = ref($model) ? $model : $c->model($model);
    my $sort_by_accessor = $opts{sort_by_accessor} // $model_ref->sort_in_forms;
    my $accessor = $opts{accessor} // 'l_name';
    my $coll = $c->get_collator();

    return [ map {
        value => $_->id,
        label => l($_->$accessor)
    }, sort_by {
        $sort_by_accessor ? $coll->getSortKey(l($_->$accessor)) : ''
    } $model_ref->get_all ];
}

sub select_options_tree
{
    my ($c, $root_or_model, %opts) = @_;
    # $root_or_model may be the root node, a model, or the name of a model.

    my $accessor = $opts{accessor} // 'l_name';
    my $coll = $c->get_collator();
    $root_or_model = ref($root_or_model) ? $root_or_model : $c->model($root_or_model);
    my $root_option = $root_or_model->can('get_tree') ? $root_or_model->get_tree : $root_or_model;

    return [
        build_options_tree($root_option, $accessor, $coll)
    ];
}

sub build_options_tree
{
    my ($root, $attr, $coll, $indent) = @_;
    $indent //= -1;

    my @options;

    push @options, {
        value => $root->id,
        label => indentation($indent) . $root->$attr,
    } if $root->id;

    foreach my $child ($root->sorted_children($coll)) {
        push @options, build_options_tree($child, $attr, $coll, $indent + 1);
    }
    return @options;
}


# Used by the relationship and release editors, instead of FormHandler.
sub build_grouped_options
{
    my ($c, $options) = @_;

    my $result = [];
    for my $opt (@$options) {
        my $i = $opt->{optgroup_order} - 1;
        $result->[$i] //= { optgroup => $opt->{optgroup}, options => [] };

        push @{ $result->[$i]->{options} },
              { label => $opt->{label}, value => $opt->{value} };
    }
    return $result;
}

sub build_json {
    my ($c, $root, $out, $coll) = @_;

    $out //= {};
    $coll //= $c->get_collator();

    my @children = map { build_json->($c, $_, $_->TO_JSON, $coll) }
                   $root->sorted_children($coll);
    $out->{children} = [ @children ] if scalar(@children);

    return $out;
};

sub build_type_info {
    my ($c, $types, @link_type_tree) = @_;

    sub build_type {
        my $root = shift;

        my $result = $root->TO_JSON;

        return $result;
    };

    my %type_info;
    for my $root (@link_type_tree) {
        my $type_key = join('-', $root->entity0_type, $root->entity1_type);
        next if $type_key !~ $types;
        $type_info{ $type_key } = build_child_info($root, \&build_type);
    }
    return \%type_info;
}

sub build_child_info {
    my ($root, $builder) = @_;

    return [ map { $builder->($_) } $root->all_children ];
}

sub indentation {
    my $level = shift;
    return "\N{NO-BREAK SPACE}" x (3 * $level);
}

sub validate_username {
    my ($self) = @_;

    my $username = $self->value;
    my $previous_username = $self->init_value;
    my $editor_model = $self->form->ctx->model('Editor');

    if (defined $username) {
        unless (defined $previous_username && $editor_model->are_names_equivalent($previous_username, $username)) {
            my $sanitized_name = sanitize($username);
            if (
                $username ne $sanitized_name ||
                $sanitized_name =~ qr{://}
            ) {
                $self->add_error(l('This username contains invalid characters. (Check for consecutive spaces.)'));
            }
            if ($username =~ qr{^deleted editor \#\d+$}i) {
                $self->add_error(l('This username is reserved for internal use.'));
            }
            if ($editor_model->is_name_used($username)) {
                $self->add_error(l('Please choose another username, this one is already taken.'));
            }
        }
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
