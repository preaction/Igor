package
    My::Service;

use Moo;
with 'Igor::Service';

has foo => ( is => 'ro' );

1;
