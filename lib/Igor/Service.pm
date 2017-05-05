package Igor::Service;
our $VERSION = '0.001';
# ABSTRACT: Role for services to access Igor features

=head1 SYNOPSIS

    package My::Object;
    use Role::Tiny::With; # or Moo, or Moose
    with 'Igor::Service';

    package main;
    use Igor;
    my $wire = Igor->new(
        config => {
            my_object => {
                '$class' => 'My::Object',
            },
        },
    );

    print $wire->get( 'my_object' )->name; # my_object

=head1 DESCRIPTION

This role adds extra functionality to an object that is going to be used
as a service in a L<Igor> container. While any object can be
configured with Igor, consuming the Igor::Service role allows an
object to know its own name and to access the container it was
configured in to fetch other objects that it needs.

=head1 SEE ALSO

L<Igor>

=cut

use strict;
use warnings;
use Moo::Role;
use Types::Standard qw( Str InstanceOf );

=attr name

The name of the service. This is the name used in the L<Igor>
configuration file for this service.

=cut

has name => (
    is => 'ro',
    isa => Str,
);

=attr container

The L<Igor> container object that contained this service. Using
this container we can get other services as-needed.

=cut

has container => (
    is => 'ro',
    isa => InstanceOf['Igor'],
);

1;

