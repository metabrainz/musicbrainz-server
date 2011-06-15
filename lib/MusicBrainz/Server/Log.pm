package MusicBrainz::Server::Log;
use strict;
use warnings;

use Data::Dumper::Concise;
use DBDefs;

use Log::Dispatch;
my $logger;
BEGIN {
    $logger = Log::Dispatch->new(
        DBDefs::LOGGER_ARGUMENTS,
        callbacks => \&_prefix_message
    );
}

use Sub::Exporter -setup => {
    exports => [
        'logger',
        map { ("log_$_", "Dlog_$_") } qw(
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

sub logger { $logger }

sub _prefix_message {
    my %args = @_;
    return sprintf "[%s] %s", $args{level}, $args{message};
}

sub _do_log {
    my ($level, $message_gen, @args) = @_;
    if ($logger->would_log($level)) {
        my ($message_gen, @args) = @_;
        local $_ = Dumper(@args);
        $logger->log(
            level => $level,
            message => $message_gen->(@args)
        )
    }
}

sub log_debug (&@)     { _do_log(debug => @_) }
sub log_info (&@)      { _do_log(info => @_) }
sub log_notice (&@)    { _do_log(notice => @_) }
sub log_warning (&@)   { _do_log(warning => @_) }
sub log_error (&@)     { _do_log(error => @_) }
sub log_critical (&@)  { _do_log(critical => @_) }
sub log_alert (&@)     { _do_log(alert => @_) }
sub log_emergency (&@) { _do_log(emergency => @_) }

1;
