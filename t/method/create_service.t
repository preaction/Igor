
use strict;
use warnings;
use Test::More;
use Test::Lib;
use Test::Deep;
use Test::Exception;
use Igor;

my $wire = Igor->new(
    config => {
        base_class => {
            class => 'My::ArgsTest',
        },
        base_no_class => { },
    },
);

my $svc;

lives_ok { $svc = $wire->create_service( 'testing', class => 'My::ArgsTest' ) }
    'create service with class only';
cmp_deeply $svc->got_args, [], 'no args given';

throws_ok { $svc = $wire->create_service( 'testing', path => '/foo/bar' ) }
    'Igor::Exception::InvalidConfig',
    'must have one of "class", "value", "config" in the merged config';

throws_ok { $svc = $wire->create_service( 'testing', extends => 'base_no_class' ) }
    'Igor::Exception::InvalidConfig',
    'merged config from extends must have one of "class", "value", "config" in the merged config';

throws_ok { $svc = $wire->create_service( 'testing', class => 'My::ArgsTest', value => '' ) }
    'Igor::Exception::InvalidConfig',
    'cannot use "value" with "class"';
throws_ok { $svc = $wire->create_service( 'testing', extends => 'base_class', value => '' ) }
    'Igor::Exception::InvalidConfig',
    'cannot use "value" with "extends"';

done_testing;
