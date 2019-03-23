
use Test::More;
use Test::Deep;
use Test::Lib;
use FindBin qw( $Bin );
use Path::Tiny qw( path );
use Scalar::Util qw( refaddr );

my $SINGLE_FILE = path( $Bin, '..', 'share', 'file.yml' );
my $DEEP_FILE   = path( $Bin, '..', 'share', 'inner_inline.yml' );
my $INNER_FILE  = path( $Bin, '..', 'share', 'inner_file.yml' );

use Igor;

subtest 'container in services' => sub {
    my $wire = Igor->new(
        services => {
            container => Igor->new( file => $SINGLE_FILE ),
        },
    );

    my $foo = $wire->get( 'container/foo' );
    isa_ok $foo, 'My::RefTest';
    my $obj = $wire->get('container/foo');
    is refaddr $foo, refaddr $obj, 'container caches the object';
    isa_ok $foo->got_ref, 'My::ArgsTest', 'container injects Bar object';
    is refaddr $wire->get('container/bar'), refaddr $foo->got_ref, 'container caches Bar object';
    cmp_deeply $wire->get('container/bar')->got_args, [ text => "Hello, World" ], 'container gives bar text value';
};

subtest 'container in file' => sub {
    my $wire = Igor->new(
        file => $DEEP_FILE,
    );

    my $foo = $wire->get( 'inline_container/foo' );
    isa_ok $foo, 'My::RefTest';
    is refaddr $foo, refaddr $wire->get('inline_container/foo'), 'container caches the object';
    isa_ok $foo->got_ref, 'My::ArgsTest', 'container injects Bar object';
    is refaddr $wire->get('inline_container/bar'), refaddr $foo->got_ref, 'container caches Bar object';
    cmp_deeply $wire->get('inline_container/bar')->got_args, [ text => "Hello, World" ], 'container gives bar text value';

    my $fizz = $wire->get( 'service_container/fizz' );
    isa_ok $fizz, 'My::RefTest';
    is refaddr $fizz, refaddr $wire->get('service_container/fizz'), 'container caches the object';
    isa_ok $fizz->got_ref, 'My::ArgsTest', 'container injects Bar object';
    is refaddr $fizz->got_ref, refaddr $foo->got_ref, 'fizz takes the same bar as foo';
    is refaddr $wire->get('inline_container/bar'), refaddr $fizz->got_ref, 'container caches Bar object';
    cmp_deeply $wire->get('service_container/buzz')->got_args, [ text => "Hello, Buzz" ], 'container gives bar text value';
};

subtest 'set inside subcontainer' => sub {
    my $wire = Igor->new(
        services => {
            container => Igor->new( file => $SINGLE_FILE ),
        },
    );

    my $fizz = My::RefTest->new( got_ref => $wire->get( 'container/bar' ) );
    $wire->set( 'container/fizz' => $fizz );

    my $foo = $wire->get( 'container/fizz' );
    isa_ok $foo, 'My::RefTest';
    my $obj = $wire->get('container/fizz');
    is refaddr $foo, refaddr $obj, 'container caches the object';
    isa_ok $foo->got_ref, 'My::ArgsTest', 'container injects Bar object';
    is refaddr $wire->get('container/bar'), refaddr $foo->got_ref, 'container caches Bar object';
    cmp_deeply $wire->get('container/bar')->got_args, [ text => "Hello, World" ], 'container gives bar text value';
};

subtest 'inner container file' => sub {
    my $wire = Igor->new(
        file => $INNER_FILE,
    );

    my $foo = $wire->get( 'container/foo' );
    isa_ok $foo, 'My::RefTest';
    my $obj = $wire->get('container/foo');
    is refaddr $foo, refaddr $obj, 'container caches the object';
    isa_ok $foo->got_ref, 'My::ArgsTest', 'container injects Bar object';
    is refaddr $wire->get('container/bar'), refaddr $foo->got_ref, 'container caches Bar object';
    cmp_deeply $wire->get('container/bar')->got_args, [ text => "Hello, World" ], 'container gives bar text value';
};

subtest 'inner container get() overrides' => sub {
    my $wire = Igor->new(
        file => $INNER_FILE,
    );

    my $foo = $wire->get( 'container/foo' );
    my $oof = $wire->get( 'container/foo', args => { got_ref => My::ArgsTest->new( text => 'New World' ) } );
    isnt refaddr $oof, refaddr $foo, 'get() with overrides creates a new object';
    isnt refaddr $oof, refaddr $wire->get('container/foo'), 'get() with overrides does not save the object';
    isnt refaddr $oof->got_ref, refaddr $foo->got_ref, 'our override gave our new object a new bar';
};

subtest 'inner extends' => sub {
    my $wire = Igor->new(
        config => {
            inner => {
                class => 'Igor',
                args => { file => $SINGLE_FILE },
            },
            foo => {
                extends => 'inner/foo',
            },
        },
    );
    my $foo = $wire->get( 'foo' );
    isa_ok $foo, 'My::RefTest';
    is refaddr $foo, refaddr $wire->get('foo'), 'container caches the object';
    isa_ok $foo->got_ref, 'My::ArgsTest', 'container injects Bar object';
    is refaddr $wire->get('inner/bar'), refaddr $foo->got_ref, 'container caches Bar object';
    cmp_deeply $wire->get('inner/bar')->got_args, [ text => "Hello, World" ], 'container gives bar text value';
};

subtest 'inner get_config' => sub {
    my $wire = Igor->new(
        config => {
            inner => {
                class => 'Igor',
                args => { file => $SINGLE_FILE },
            },
            foo => {
                extends => 'inner/foo',
            },
        },
    );
    my $config = $wire->get_config( 'inner/foo' );
    cmp_deeply $config, { class => 'My::RefTest', args => { got_ref => { '$ref' => 'inner/bar' } } } or diag explain $config;
};

subtest 'inner container resolve extends of extends' => sub {
    my $wire = Igor->new(
        config => {
            inner => {
                class => 'Igor',
                args => { file => $SINGLE_FILE },
            },
            foo => {
                # inner/fizz extends inner/buzz
                extends => 'inner/fizz',
            },
        },
    );
    my $obj = eval { $wire->get( 'foo' ) };
    ok !$@, 'service created successfully' or diag "$@";
    isa_ok $obj, 'My::ArgsTest', 'service gets class from inner/buzz';
    is_deeply $obj->got_args, [{ one => 'two' }], 'service gets args from inner/fizz';
};

done_testing;
