use strict;
use warnings;
use feature 'say';

use IO::Socket qw(AF_INET AF_UNIX SOCK_STREAM SHUT_WR);
use JSON::PP;

my $i = 0;

sub to_message {
    my $data = shift;
    return $data."\n\n";
}

sub make_body {
    my $i = shift;
    return encode_json({
        text => "string$i"
    });
}

while (1) {
    my $client = IO::Socket->new(
        Domain => AF_INET,
        Type => SOCK_STREAM,
        proto => 'tcp',
        PeerPort => 13000,
        PeerHost => '127.0.0.1',
    ) || die "Can't open socket: $@";

    my $message = to_message(make_body($i++));

    my $size = $client->send($message);
    $client->shutdown(SHUT_WR);

    my $buffer;
    $client->recv($buffer, 1024);

    $client->close();

    sleep (1);
}
