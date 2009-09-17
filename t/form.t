#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

{
    package TestForm;
    use HTML::FormHandler::Moose;

    extends 'MusicBrainz::Server::Form';

    has '+name' => ( default => 'form' );

    has_field 'foo' => ( type => 'Compound' );
    has_field 'foo.bar' => ( type => 'Repeatable' );
    has_field 'foo.bar.contains';
}

my $form = TestForm->new( init_object => { foo => { } } );
my $field = $form->field('foo')->field('bar');
my $subfields = $field->fields;
is(scalar(@$subfields), 1);
# Workaround for HTML::FormHandler, which will let the field be named
# 'contains' if there is no value in init_object for it.
is($subfields->[0]->name, '0');
is($subfields->[0]->html_name, 'form.foo.bar.0');

done_testing;
