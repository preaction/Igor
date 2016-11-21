package t::CustomListener;

use Moo;
extends 'Igor::Listener';

has attr => ( is => 'ro', required => 1 );

1;

