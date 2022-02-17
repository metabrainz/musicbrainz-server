package MusicBrainz::Server::Log;
use strict;
use warnings;

use Data::Dumper::Concise;
use DBDefs;
use Devel::StackTrace;
use POSIX qw( strftime );
use Readonly;

use Log::Dispatch;
my $logger;
BEGIN {
    $| = 1; # autoflush stdout
    $logger = Log::Dispatch->new(
        DBDefs->LOGGER_ARGUMENTS,
        callbacks => [
            -t STDOUT ? \&_prefix_message_with_timestamp : \&_prefix_message,
            \&_truncate_message,
        ],
    );
}

use Sub::Exporter -setup => { ## no critic 'ProhibitUnusedImport'
    exports => [
        'logger',
        map { ("log_$_") } qw(
            assertion
            debug
            info
            notice
            warning
            error
            critical
            alert
            emergency
        )
    ]
};

Readonly our $MAX_MESSAGE_LENGTH => 1024 * 16;

sub logger { $logger }

sub _prefix_message {
    my %args = @_;
    if ($args{level} eq 'info') {
        return $args{message};
    } else {
        return sprintf '[%s] %s', $args{level}, $args{message};
    }
}

sub _prefix_message_with_timestamp {
    my %args = @_;
    if ($args{level} eq 'info') {
        return (strftime '%X %Z ', localtime) . $args{message};
    } else {
        return sprintf '%s [%s] %s', (strftime '%X %Z', localtime), $args{level}, $args{message};
    }
}

sub _truncate_message {
    my %args = @_;

    my $message = $args{message} // '';
    if (length $message > $MAX_MESSAGE_LENGTH) {
        $message = substr($message, 0, $MAX_MESSAGE_LENGTH)
            . "[message truncated]\n";
    }
    return $message;
}

sub _do_log {
    my ($level, $message_gen, @args) = @_;
    if ($logger->would_log($level)) {
        local $_ = Dumper(@args);
        $logger->log(
            level => $level,
            message => $message_gen->(@args)
        )
    }
    @args;
}

sub log_debug (&@)     { _do_log(debug => @_) }
sub log_info (&@)      { _do_log(info => @_) }
sub log_notice (&@)    { _do_log(notice => @_) }
sub log_warning (&@)   { _do_log(warning => @_) }
sub log_error (&@)     { _do_log(error => @_) }
sub log_critical (&@)  { _do_log(critical => @_) }
sub log_alert (&@)     { _do_log(alert => @_) }
sub log_emergency (&@) { _do_log(emergency => @_) }

sub log_assertion (&$) {
    my ($code, $message) = @_;
    unless ($code->()) {
        my (undef, $filename, $line) = caller(0);
        log_error { "Failed assertion: $message ($filename:$line)" };
        log_debug {
            'Stacktrace: ' .
                Devel::StackTrace->new( ignore_class => 'MusicBrainz::Server::Log' )->as_string
              }
    }
}

1;
