package Igor::Runner;
our $VERSION = '0.002';
# ABSTRACT: Execute runnable objects from Igor containers

=head1 SYNOPSIS

    igor run <container> <service> [<args...>]
    igor list
    igor list <container>
    igor help <container> <service>
    igor help

=head1 DESCRIPTION

This distribution is an execution and organization system for
L<Igor> containers. This allows you to prepare executable objects
in configuration files and then execute them. This also allows easy
discovery of container files and objects, and allows you to document
your objects for your users.

=head1 SEE ALSO

L<igor>, L<Igor::Runnable>, L<Igor>

=cut

use strict;
use warnings;



1;

