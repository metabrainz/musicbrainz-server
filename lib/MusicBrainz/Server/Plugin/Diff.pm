package MusicBrainz::Server::Plugin::Diff;

use strict;
use warnings;

use base 'Template::Plugin';

use Algorithm::Diff qw( sdiff traverse_sequences );
use Digest::MD5 qw( md5_hex );
use HTML::Tiny;
use MusicBrainz::Server::Validation;

sub new {
    my ($class, $context) = @_;
    return bless { }, $class;
}

my $TOKEN_NEW_PARA = chr(10);

my %class_map = (
    '+' => 'diff-only-b',
    '-' => 'diff-only-a'
);

sub diff_side {
    my ($self, $old, $new, $filter, $split) = @_;
    $split ||= '';

    my ($old_hex, $new_hex) = (md5_hex($old), md5_hex($new));
    $old =~ s/($split)/$old_hex$1/g;
    $new =~ s/($split)/$new_hex$1/g;

    my @diffs = sdiff([ split($old_hex, $old) ], [ split($new_hex, $new) ]);

    my @stack;
    my $output;
    for my $diff (@diffs) {
        my ($change_type, $old, $new) = @$diff;

        next unless
            $change_type eq 'c' ||
            $change_type eq 'u' ||
            $change_type eq $filter;

        unless ($stack[-1] && $stack[-1]->{type} eq $change_type) {
            push @stack, { str => '', type => $change_type };
        }

        if ($change_type eq 'c') {
            $stack[-1]->{str} .=
                $filter eq '+'
                    ? "$new" : "$old";
        }
        else {
            $stack[-1]->{str} .= $old;
        }
    }

    return join(
        '',
        map {
            my $class =
                $_->{type} eq 'u' ? '' :
                $_->{type} eq 'c' ? $class_map{$filter} :
                                    $class_map{$_->{type}};

            my $text = $_->{str};

            qq{<span class="$class">$text</span>};
        } @stack
    )
}

sub diff {
    my ($self, $old, $new) = @_;
    my $h = HTML::Tiny->new;

    my @spans;

    my @a = parse_paragraphs($old);
    my @b = parse_paragraphs($new);

    my %buffers = (
        MATCH     => '',
        DISCARD_A => '',
        DISCARD_B => ''
    );

    my %classes = (
        MATCH     => 'diff-match',
        DISCARD_A => 'diff-only-a',
        DISCARD_B => 'diff-only-b',
    );

    my $flush = sub {
        my $exclude = shift;

        while (my ($key, $class) = each %classes) {
            next if $exclude eq $key || !$buffers{$key};
            push @spans, $h->span({ class => $class }, $buffers{$key});
            $buffers{$key} = '';
        }
    };

    my @compact = traverse_sequences(
        \@a, \@b, {
            MATCH     => sub {
                $flush->('MATCH');
                $buffers{MATCH} .= $a[shift];
            },
            DISCARD_A => sub {
                $flush->('DISCARD_A');
                $buffers{DISCARD_A} .= $a[shift];
            },
            DISCARD_B => sub {
                $flush->('DISCARD_B');
                shift;
                $buffers{DISCARD_B} .= $b[shift];
            },
        }
    );

    $flush->('');

    return $h->div({ class => 'diff' }, \@spans);
}

sub parse_text
{
    my ($text) = @_;
    $text =~ s/\s+/ /g;
    $text =~ s/\A //g;
    $text =~ s/ \z//g;
    # The spaces between words are included as part of the word tokens to make
    # the "diff" output more intuitive; for example if you diff "a big red
    # ball" to "a small green ball", the obvious diff is s/big red/small
    # green/.  If spaces were their own tokens, the diff would be s/big/small/
    # and s/red/green/.
    return split /(?= )/, $text;
}

sub parse_paragraphs
{
    my $text = shift;

    $text =~ s/(\015\012|\012\015|\012|\015)\1+/\n\n/g;
    MusicBrainz::Server::Validation::TrimInPlace($text);

    my @paras = split /\n\n+/, $text;

    my @out;
    for my $p (@paras) {
#       push @out, $TOKEN_NEW_PARA if @out;
        push @out, parse_text($p);
    }

    return @out;
}

1;
