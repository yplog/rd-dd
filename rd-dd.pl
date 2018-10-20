use strict;
use warnings;
use DBI;
use List::Compare;

=pod

=encoding utf8

=head1 DESCRIPTION

This script compares the files in the PostgreSQL database with the file assets in the directory.
Deletes files that are not in the database.

Requirements:
	DBI, 
	DBI::Pg, 
	List::Compare

=head2 HOW TO USE

=over 4

=item $DIRECTORY_PATH

The directory containing the files to compare with the database.

=item $DBNAME

PostgreSQL database name.

=item $HOST

PostgreSQL database host address.

=item $PORT

PostgreSQL database port address.

=item $USERNAME

PostgreSQL database username.

=item $PASSWORD

PostgreSQL database password.

=item QUERY_STRING

SQL is a standard language for storing, manipulating and retrieving data in databases.
The database partition to compare.

=back

=head2 METHODS

=over 4

=item get_directory_files()

Return directory files array.

=item get_database_files()

Return database files array.

=back

=head2 AUTHOR

Yalin Pala - L<http://yplog.xyz/>
Email: yalinpala@protonmail.com

=head2 LICENSE

This is released under the Artistic License.
See L<https://dev.perl.org/licenses/artistic.html>

=cut

# Configration
my $DIRECTORY_PATH = '';
my $DBNAME = '';
my $HOST = '';
my $PORT = '';
my $USERNAME = '';
my $PASSWORD = '';
my $QUERY_STRING = "";

my @database_files = &get_database_files($DBNAME, $HOST, $PORT, $USERNAME, $PASSWORD, $QUERY_STRING);
my @directory_files = &get_directory_files($DIRECTORY_PATH);

my $lc = List::Compare->new(\@directory_files, \@database_files);
my @deleted_files = $lc->get_unique;

my $number;
foreach my $file (@deleted_files) {
	$number = unlink($DIRECTORY_PATH.$file);
}
print "$number file(s) deleted!";

sub get_directory_files {
	my ($dir_path) = shift @_;
	opendir my $dh, $dir_path or die "Cannot open $dir_path";
	my @dir_files;
	foreach my $file (readdir $dh) {
		push(@dir_files, $file);
	}
	return @dir_files;
}

sub get_database_files {
	# Connection Config
	my ($dbname, $host, $port, $username, $password, $quert_string) = @_;

	# Create DB handle object by connection
	my $dbh = DBI -> connect("dbi:Pg:dbname=$dbname;host=$host;port=$port",
	                            $username,
	                            $password,
	                            {AutoCommit => 0, RaiseError => 1}
	                        ) or die $DBI::errstr;

	my $query = $dbh->prepare(
	    $quert_string
	    );
	$query -> execute();

	my @db_files;

	while (my @row = $query->fetchrow_array()) {
	    push(@db_files, @row);
	}

	undef($query);
	$dbh -> disconnect;
	$dbh = undef;

	return @db_files;
}