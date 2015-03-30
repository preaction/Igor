
use Test::More;
use Test::Exception;
use Test::Lib;
use Scalar::Util qw( refaddr );
use Igor;

subtest 'value service: simple scalar' => sub {
    my $wire = Igor->new(
        config => {
            greeting => {
                value => 'Hello, World'
            }
        },
    );

    my $greeting;
    lives_ok { $greeting = $wire->get( 'greeting' ) };
    ok !ref $greeting, 'got a simple scalar';
    is $greeting, 'Hello, World';
};

done_testing;
