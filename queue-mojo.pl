#!/usr/bin/env perl

use strict;
use warnings;
use feature qw/ say /;

use Data::Dumper;
use Socket qw(getnameinfo);
use JSON::PP;
use Carp;

use local::lib 'local';
use lib 'lib';
use Mojo::IOLoop::Server;
use Mojo::Log;
use Mojo::Exception qw/ check /;

my $log = Mojo::Log->new(level => 'warn');

my $queue = [];

# my $port = empty_port();
my $port = 13000;
my $data_size_limit = 1024;

say "queue port: $port";
say "data limit: $data_size_limit";

my $server = Mojo::IOLoop::Server->new;
$server->on(accept => sub ($$) { 
    my ($server, $socket) = @_;

    say Dumper $socket;

    my ($err, $hostname, $servicename) = getnameinfo($socket->peername);
    if ($err) {
        $log->warn("Cannot getnameinfo - $err");
    }
    $log->info("The peer is connected from $hostname");

    my $data = _recv($socket);
    check(
        default => sub {
            $log->warn("Not validate, $buf - $_");
        },
    );

    my $message = _get_message($data);
    my $payload;
    eval { $payload = decode_json($message) };

    _enqueue($payload);

    $socket->send('OK');
    $socket->close();
});

$server->listen(port => $port);

# Start and stop accepting connections
$server->start;
# $server->stop;

# Start reactor if necessary
$server->reactor->start unless $server->reactor->is_running;

sub _recv {
    my $socket = shift;
    my $buf;
    while ($buf !~ /\n\n$/) {
        my $tmp;
        $socket->recv($tmp, 1024);
        $buf .= $tmp;
        if ($buf > $data_size_limit) {

        }
    }
    return $buf;
}

sub _validate_data {
    my $data = shift;
    confess 'too long data' if length $data > $data_size_limit;
    confess 'invalid format data' if $data !~ /\n\n$/;
}

sub _accept {
    my $server = shift;
    return $server->accept;
}

sub _get_message {
    my $data = shift;
    $data =~ s/\n\n$//;
    return $data;
}

sub _enqueue {
    my $payload = shift;
    push @$queue, $payload;
}

sub _dequeue {
    return shift @$queue;
}
