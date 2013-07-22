
use Test::Most;
use Test::Lib;
use Igor;

subtest 'load module from refs' => sub {
    my $wire = Igor->new(
        config => {
            foo => {
                class => 'Foo',
                args  => {
                    foo => {
                        '$ref'  => 'config',
                        '$path' => '//en/greeting'
                    }
                },
            },
            config => {
                value => {
                    en => {
                        greeting => 'Hello, World'
                    }
                }
            }
        },
    );

    my $foo;
    lives_ok { $foo = $wire->get( 'foo' ) };
    isa_ok $foo, 'Foo';
    is $foo->foo, 'Hello, World' or diag explain $foo->foo;

    # NEED MORE TESTS !!!
};

done_testing;
