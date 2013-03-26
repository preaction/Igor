
use Test::Most;
use FindBin qw( $Bin );
use File::Spec::Functions qw( catdir );
use lib catdir( $Bin , 'lib' );
use Igor;

subtest 'load module from config' => sub {
    my $wire = Igor->new(
        config => {
            foo => {
                class => 'Foo',
                args  => {
                    foo => 'Hello, World',
                },
            },
        },
    );

    my $foo;
    lives_ok { $foo = $wire->get( 'foo' ) };
    isa_ok $foo, 'Foo';
    is $foo->foo, 'Hello, World';
};

done_testing;
