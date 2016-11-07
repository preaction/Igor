use strict;
use warnings;

use Test::Exception tests => 1;

use Igor::Emitter;

{
    package MyEmitter;

    use Moo; with 'Igor::Emitter';
}

my $emitter = MyEmitter->new;

my $unsubscribe = $emitter->on( ping => sub { } );

# simulate Global Destruction with $emitter destroyed first

undef $emitter;

lives_ok { $unsubscribe->() } 'unsubscribe survived destroyed emitter';






