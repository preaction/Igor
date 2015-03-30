
use Test::More;
use Test::Deep;
use Test::Lib;
use Scalar::Util qw( refaddr );

use Igor;

subtest 'get() override factory (anonymous services)' => sub {
    my $wire = Igor->new(
        config => {
            bar => {
                class => 'My::ArgsTest',
            },
            foo => {
                class => 'My::RefTest',
                args => {
                    got_ref => { '$ref' => "bar" },
                },
            },
        },
    );
    my $foo = $wire->get( 'foo' );
    my $oof = $wire->get( 'foo', args => { got_ref => My::ArgsTest->new( text => 'New World' ) } );
    isnt refaddr $oof, refaddr $foo, 'get() with overrides creates a new object';
    isnt refaddr $oof, refaddr $wire->get('foo'), 'get() with overrides does not save the object';
    isnt refaddr $oof->got_ref, refaddr $foo->got_ref, 'our override gave our new object a new bar';
};

done_testing;
