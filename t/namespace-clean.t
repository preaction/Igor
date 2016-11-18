
=head1 DESCRIPTION

This test ensures that the API of the Igor::Emitter role is kept to
a minimum, and any imported subs are cleaned up before the role is
composed into a class. Any new methods must be added here, but only
after it's certain there's no way to add the functionality without
a new method.

=cut

use strict;
use warnings;
use Test::More;
use Test::API;

{
    package My::Emitter;
    use Moo;
    with 'Igor::Emitter';
    no Moo; # Remove Moo so it doesn't look like Igor::Emitter's API
}

class_api_ok(
    'My::Emitter',
    qw[
      DOES
      emit
      emit_args
      listeners
      new
      on
      subscribe
      un
      unsubscribe
      ]
);

done_testing;
