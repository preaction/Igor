package Igor::Runner;
our $VERSION = '0.008';
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

=head2 Container Files

The container file is a configuration file that describes services. Some
of these services are marked as executable by using the L<Igor::Runnable>
role.

The container file can have a special service called C<$summary> which
has a short summary that will be displayed when using the C<igor list>
command.

Here's an example container file that has a summary, configures
a L<DBIx::Class> schema (using the schema class for CPAN Testers:
L<CPAN::Testers::Schema>), and configures a runnable task called
C<to_metabase> located in the class
C<CPAN::Testers::Backend::Migrate::ToMetabase>:

    # migrate.yml
    $summary: Migrate data between databases

    _schema:
        $class: CPAN::Testers::Schema
        $method: connect_from_config

    to_metabase:
        $class: CPAN::Testers::Backend::Migrate::ToMetabase
        schema:
            $ref: _schema

For more information about container files, see L<the Igor
documentation|Igor>.

=head2 Services

A service is an object configured in the container file. C<Igor::Runner>
works with executable objects that consume the L<Igor::Runnable> role.
This role requires only a C<run()> method be implemented in the class.

Services are expected to have documentation that will be displayed by
the C<igor list> and C<igor help> commands. The C<igor list> command
will display the C<NAME> section of the documentation, and the C<igor
help> command will display the C<NAME>, C<SYNOPSIS>, C<DESCRIPTION>,
C<ARGUMENTS>, C<OPTIONS>, C<ENVIRONMENT>, and C<SEE ALSO> sections of
the documentation.

=head1 SEE ALSO

L<igor>, L<Igor::Runnable>, L<Igor>

=cut

use strict;
use warnings;



1;

