#!/usr/bin/env perl

use strict;
use warnings;
use feature qw/ say /;

use Data::Dumper;
use IO::Socket::IP;
use Socket qw(getnameinfo);
use JSON::PP;
use Carp;

my $queue = [];

my $data_length = 1024;
my $server = IO::Socket::IP->new(LocalPort => 12345, Listen => 1) or
    die "Cannot listen - $@";

while (my $socket = _accept($server)) {
    my $catch = sub {
        my $e = shift;
        say $e;
        $socket->send($e);
        $socket->close();
        next;
    };

    my ($err, $hostname, $servicename) = getnameinfo($socket->peername);
    if ($err) {
        say "Cannot getnameinfo - $err";
        next;
    }

    say "The peer is connected from $hostname";

    my $data;
    $socket->recv($data, $data_length + 1);
    eval { _validate_data($data) }; $catch->($@) if $@;

    my $message = _get_message($data);
    eval { decode_json($message) }; $catch->($@) if $@;

    push @$queue, $message;

    $socket->send('OK');
    $socket->close();
}

$server->close();

sub _validate_data {
    my $data = shift;
    confess 'too long data' if length $data > $data_length;
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
