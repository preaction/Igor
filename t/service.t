
use strict;
use warnings;
use Test::More;
use Test::Fatal;

{ package
    My::Object;
    use Moo;
    with 'Igor::Service';
}
{ package
    Igor; # Fake Igor object
    use Moo;
}

my $obj;
ok !(exception { $obj = My::Object->new( name => 'foo', container => Igor->new ) }),
    'Igor::Service accepts name and container attributes';
is $obj->name, 'foo', 'name is correct';
is ref $obj->container, 'Igor', 'container is correct';

ok !(exception { $obj = My::Object->new }),
    'Igor::Service object can be created without name or container';

ok exception { My::Object->new( container => 'foo' ) },
    'Igor::Service container attribute must be Igor object';

ok exception { My::Object->new( name => Igor->new ) },
    'Igor::Service name attribute must be string';

done_testing;

