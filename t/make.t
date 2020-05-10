
use v5.20;
use warnings;
use File::Temp ();
use Cwd ();
use Test::More;
use Igor::Make;

my $cwd = Cwd::getcwd;
my $home = File::Temp->newdir();
chdir $home;

my $make = Igor::Make->new(
    conf => {
        'now.txt' => {
            commands => [
                'date > now.txt',
            ],
        },
        'yesterday.txt' => {
            requires => [qw( now.txt )],
            commands => [
                'date -j -v -1d -f "%a %b %d %T %Z %Y" "$(cat now.txt)" | tee yesterday.txt',
            ],
        },
        'then.txt' => {
            requires => [qw( now.txt )],
            commands => [
                'date -j -v $THEN -f "%a %b %d %T %Z %Y" "$(cat now.txt)" | tee then.txt',
            ],
        },
    },
);

$make->run( 'now.txt' );
ok -e 'now.txt', 'now.txt exists';
unlink 'now.txt';

$make->run( 'yesterday.txt' );
ok -e 'now.txt', 'now.txt exists';
ok -e 'yesterday.txt', 'yesterday.txt exists';
ok !-e 'then.txt', 'then.txt does not exist';
unlink 'now.txt';

$make->run( 'then.txt', 'THEN=-7d', 'yesterday.txt' );
ok -e 'now.txt', 'now.txt exists';
ok -e 'yesterday.txt', 'yesterday.txt exists';
ok -e 'then.txt', 'then.txt exists';

chdir $cwd;
done_testing;
