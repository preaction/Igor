
use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::Exception;

use Igor;

subtest 'config file does not exist' => sub {
    throws_ok { Igor->new( file => 'DOES_NOT_EXIST.yml' ) } 'Igor::Exception::Constructor';
    like $@, qr{\QContainer file 'DOES_NOT_EXIST.yml' does not exist}, 'stringifies';
};

subtest "get a service that doesn't exist" => sub {
    my $wire = Igor->new;
    throws_ok { $wire->get( 'foo' ) } 'Igor::Exception::NotFound';
    is $@->name, 'foo';
};

subtest "extend a service that doesn't exist" => sub {
    my $wire = Igor->new(
        config => {
            foo => {
                extends => 'bar',
            },
        },
    );
    throws_ok { $wire->get( 'foo' ) } 'Igor::Exception::NotFound';
    is $@->name, 'bar';
};

subtest "service with both value and class/extends" => sub {
    subtest "class + value" => sub {
        my $wire;
        lives_ok {
            $wire = Igor->new(
                config => {
                    foo => {
                        class => 'Foo',
                        value => 'foo',
                    }
                }
            );
        };
        throws_ok { $wire->get( 'foo' ) } 'Igor::Exception::InvalidConfig';
        is $@->name, 'foo';
    };
    subtest "extends + value" => sub {
        my $wire;
        lives_ok {
            $wire = Igor->new(
                config => {
                    bar => {
                        value => 'bar',
                    },
                    foo => {
                        extends => 'bar',
                        value => 'foo',
                    }
                }
            );
        };
        throws_ok { $wire->get( 'foo' ) } 'Igor::Exception::InvalidConfig';
        is $@->name, 'foo';
    };
    subtest "value in extended service" => sub {
        my $wire;
        lives_ok {
            $wire = Igor->new(
                config => {
                    bar => {
                        value => 'bar',
                    },
                    foo => {
                        extends => 'bar',
                        class => 'foo',
                    }
                }
            );
        };
        throws_ok { $wire->get( 'foo' ) } 'Igor::Exception::InvalidConfig';
        is $@->name, 'foo';
    };
};

done_testing;
