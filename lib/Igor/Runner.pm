package Igor::Runner;
our $VERSION = '0.017';
# ABSTRACT: Configure, list, document, and execute runnable task objects

=head1 SYNOPSIS

    igor run <container> <task> [<args...>]
    igor list
    igor list <container>
    igor help <container> <task>
    igor help

=head1 DESCRIPTION

This distribution is an execution and organization system for runnable
objects (tasks). This allows you to prepare a list of runnable tasks in
configuration files and then execute them. This also allows easy
discovery of configuration files and objects, and allows you to document
your objects for your users.

=head2 Tasks

A task is an object that consumes the L<Igor::Runnable> role. This role
requires only a C<run()> method be implemented in the class. This
C<run()> method should accept all the arguments given on the command
line. It can parse GNU-style options out of this array using
L<Getopt::Long/GetOptionsFromArray>.

Task modules can compose additional roles to easily add more features,
like adding a timeout with L<Igor::Runnable::Timeout::Alarm>.

Task modules are expected to have documentation that will be displayed
by the C<igor list> and C<igor help> commands. The C<igor list> command
will display the C<NAME> section of the documentation, and the C<igor
help> command will display the C<NAME>, C<SYNOPSIS>, C<DESCRIPTION>,
C<ARGUMENTS>, C<OPTIONS>, C<ENVIRONMENT>, and C<SEE ALSO> sections of
the documentation.

=head2 Configuration Files

The configuration file is a L<Igor> container file that describes
objects. Some of these objects are marked as executable tasks by
consuming the L<Igor::Runnable> role.

The container file can have a special entry called C<$summary> which
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

=head1 QUICKSTART

Here's a short tutorial for getting started with C<Igor::Runner>. If you
want to try it yourself, start with an empty directory.

=head2 Create a Task

To create a task, make a Perl module that uses the L<Igor::Runnable> role
and implements a C<run> method. For an example, let's create a task that
prints C<Hello, World!> to the screen.

    package My::Runnable::Greeting;
    use Moo;
    with 'Igor::Runnable';
    sub run {
        my ( $self, @args ) = @_;
        print "Hello, World!\n";
    }
    1;

If you're following along, save this in the
C<lib/My/Runnable/Greeting.pm> file.

=head2 Create a Configuration File

Now that we have a task to run, we need to create a configuration file
(or a "container"). The configuration file is a YAML file that describes
all the tasks we can run. Let's create an C<etc> directory and name our
container file C<etc/greet.yml>.

Inside this file, we define our task. We have to give our task a simple
name, like C<hello>. Then we have to say what task class to run (in our case,
C<My::Runnable::Greeting>).

    hello:
        $class: My::Runnable::Greeting

=head2 Run the Task

Now we can run our task. Before we do, we need to tell C<Igor::Runner> where
to find our code and our configuration by setting some environment variables:

    $ export PERL5LIB=lib:$PERL5LIB
    $ export IGOR_PATH=etc

The C<PERL5LIB> environment variable adds directories for C<perl> to search
for modules (like our task module). The C<IGOR_PATH> environment variable
adds directories to search for configuration files (like ours).

To validate that our environment variables are set correctly, we can list the
tasks:

    $ igor list
    greet
    - hello -- My::Runnable::Greeting

The C<igor list> command looks through our C<IGOR_PATH> directory, opens
all the configuration files it finds, and lists all the
L<Igor::Runnable> objects inside (helpfully giving us the module name for us
to find documentation).

Then, to run the command, we use C<igor run> and give it the configuration file
(C<greet>) and the task (C<hello>):

    $ igor run greet hello
    Hello, World!

=head2 Adding Documentation

Part of the additional benefits of defining tasks in L<Igor::Runnable> modules
is that the C<igor help> command will show the documentation for the task. To
do this, we must add documentation to our module.

This documentation is done as L<POD|perlpod>, Perl's system of documentation.
Certain sections of the documentation will be shown: C<NAME>, C<SYNOPSIS>,
C<DESCRIPTION>, C<ARGUMENTS>, C<OPTIONS>, and C<SEE ALSO>.

    =head1 NAME

    My::Runnable::Greeting - Greet the user

    =head1 SYNOPSIS

        igor run greet hello

    =head1 DESCRIPTION

    This task greets the user warmly and then exits.

    =head1 ARGUMENTS

    No arguments are allowed during a greeting.

    =head1 OPTIONS

    Greeting warmly is the only option.

    =head1 SEE ALSO

    L<Igor::Runnable>

If we add this documentation to our C<lib/My/Runnable/Greeting.pm> file,
we can then run C<igor help> to see the documentation:

    $ igor help greet hello
    NAME
        My::Runnable::Greeting - Greet the user

    SYNOPSIS
            igor run greet hello

    DESCRIPTION
        This task greets the user warmly and then exits.

    ARGUMENTS
        No arguments are allowed during a greeting.

    OPTIONS
        Greeting warmly is the only option.

    SEE ALSO
        Igor::Runnable

The C<igor list> command will also use our new documentation to show the C<NAME>
section:

    $ igor list
    greet
    - hello -- My::Runnable::Greeting - Greet the user

=head2 Going Further

For more information on how to use the configuration file to create more
complex objects like database connections, see
L<Igor::Help::Config>.

To learn how to run your tasks using a distributed job queue to
parallelize and improve performance, see L<Igor::Minion>.

=head1 SEE ALSO

L<igor>, L<Igor::Runnable>, L<Igor>

=cut

use strict;
use warnings;



1;

