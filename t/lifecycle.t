
use Test::Most;
use FindBin qw( $Bin );
use File::Spec::Functions qw( catdir );
use Scalar::Util qw( refaddr );
use lib catdir( $Bin , 'lib' );
use Igor;

subtest 'singleton lifecycle' => sub {
    my $wire = Igor->new(
        config => {
            foo => {
                class => 'Foo',
                lifecycle => 'singleton',
            },
            bar => {
                class => 'Foo',
                args => {
                    foo => { ref => 'foo' },
                },
            },
        },
    );

    my $foo = $wire->get('foo');
    isa_ok $foo, 'Foo';
    my $oof = $wire->get('foo');
    is refaddr $oof, refaddr $foo, 'same foo object is returned';
    my $bar = $wire->get('bar');
    is refaddr $bar->foo, refaddr $foo, 'same foo object is given to bar';
};

subtest 'factory lifecycle' => sub {
    my $wire = Igor->new(
        config => {
            foo => {
                class => 'Foo',
                lifecycle => 'factory',
            },
            bar => {
                class => 'Foo',
                args => {
                    foo => { ref => 'foo' },
                },
            },
        },
    );

    my $foo = $wire->get('foo');
    isa_ok $foo, 'Foo';
    my $oof = $wire->get('foo');
    isnt refaddr $oof, refaddr $foo, 'different foo object is returned';
    my $bar = $wire->get('bar');
    isnt refaddr $bar->foo, refaddr $foo, 'different foo object is given to bar';
    isnt refaddr $bar->foo, refaddr $oof, 'different foo object is given to bar';
};

subtest 'default lifecycle is singleton' => sub {
    my $wire = Igor->new(
        config => {
            foo => {
                class => 'Foo',
            },
            bar => {
                class => 'Foo',
                args => {
                    foo => { ref => 'foo' },
                },
            },
        },
    );

    my $foo = $wire->get('foo');
    isa_ok $foo, 'Foo';
    my $oof = $wire->get('foo');
    is refaddr $oof, refaddr $foo, 'same foo object is returned';
    my $bar = $wire->get('bar');
    is refaddr $bar->foo, refaddr $foo, 'same foo object is given to bar';
};

done_testing;
