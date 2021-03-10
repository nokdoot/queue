#!/usr/bin/env perl

use strict;
use warnings;
use feature qw/ say /;

use local::lib './local';
use lib 'lib';

use Net::EmptyPort qw(listen_socket empty_port check_port);

 
# get a socket listening on a random free port
my $socket = listen_socket();
 
# get a random free port
my $port = empty_port();

say $port;
 
# check if a port is already used
if (check_port(5000)) {
    say "Port 5000 already in use";
}
