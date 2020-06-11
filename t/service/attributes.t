
use Test::More;
use Test::Exception;
use Test::Lib;
use Igor;

my $wire = Igor->new(
    config => {
        my_object => { '$class' => 'My::Service' },
    },
);

my $obj = $wire->get( 'my_object' );
is $obj->name, 'my_object', 'name is set on Igor::Service';
is $obj->container, $wire, 'container is set on Igor::Service';

done_testing;
