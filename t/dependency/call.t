
use Test::More;
use Test::Exception;
use Test::Lib;
use Test::Deep;
use Igor;

# XXX: $method in dependency needs to be called $call

subtest 'method with no arguments' => sub {
    my $wire = Igor->new(
        config => {
            foo => {
                class => 'My::RefTest',
                args  => {
                    got_ref => {
                        '$ref' => 'greeting',
                        '$method' => 'got_args_hash',
                    },
                },
            },
            greeting => {
                class => 'My::ArgsTest',
                args => {
                    hello => "Hello",
                    default => 'World',
                },
            },
        },
    );
    my $svc;
    lives_ok { $svc = $wire->get( 'foo' ) };
    isa_ok $svc, 'My::RefTest';
    cmp_deeply $svc->got_ref, { hello => 'Hello', default => 'World' }
        or diag explain $svc->got_ref;
};

subtest 'method with one argument' => sub {
    my $wire = Igor->new(
        config => {
            bar => {
                class => 'My::RefTest',
                args => {
                    got_ref => {
                        '$ref' => 'greeting',
                        '$method' => 'got_args_hash',
                        '$args' => 'hello',
                    },
                },
            },
            greeting => {
                class => 'My::ArgsTest',
                args => {
                    hello => "Hello",
                    default => 'World',
                },
            },
        },
    );
    my $svc;
    lives_ok { $svc = $wire->get( 'bar' ) };
    isa_ok $svc, 'My::RefTest';
    cmp_deeply $svc->got_ref, [ 'Hello' ] or diag explain $svc->got_ref;
};

subtest 'method with arrayref of arguments' => sub {
    my $wire = Igor->new(
        config => {
            foo_and_bar => {
                class => 'My::RefTest',
                args => {
                    got_ref => {
                        '$ref' => 'greeting',
                        '$method' => 'got_args_hash',
                        '$args' => [ 'default', 'hello' ],
                    },
                },
            },
            greeting => {
                class => 'My::ArgsTest',
                args => {
                    hello => "Hello",
                    default => 'World',
                },
            },
        },
    );
    my $svc;
    lives_ok { $svc = $wire->get( 'foo_and_bar' ) };
    isa_ok $svc, 'My::RefTest';
    cmp_deeply $svc->got_ref, [ 'World', 'Hello' ] or diag explain $svc->got_ref;
};

done_testing;
