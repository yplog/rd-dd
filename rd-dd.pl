use strict;
use warnings;
use DBI;
use List::Compare;
use Getopt::Std;
use XML::Simple;

=pod

=encoding utf8

=head1 DESCRIPTION

This script compares the files in the PostgreSQL database with the file assets in the directory.
Deletes files that are not in the database.

=head2 HOW TO USE

=over 2

=item Runing With Config File C<perl rd-dd.pl>

First, a configuration file must be created. Requires the config.xml file.
If you do not have a config.xml file, use the C<perl rd-dd.pl -g> to create it.
Example:

=begin text

<?xml version="1.0" encoding="UTF-8"?>
<config>
	<path>path\of\directory\</path>
	<name>database_name</name>
	<host>127.0.0.1</host>
	<port>5432</port>
	<username>postgres</username>
	<password>root</password>
	<query>SELECT user_file FROM user</query>
</config>

=end text

=item Runing With One Line C<perl rd-dd.pl -f -D -H -O -U -P -Q>

All parameters are required.
Example:

=begin text

C<perl rd-dd.pl -f "path\of\directory\" -D "database_name" -H "127.0.0.1" -O "5432" -U "postgres" -P "root" -Q "SELECT user_file FROM user">

=end text

=back

=over 4

=item C<-f> or <path>

The directory containing the files to compare with the database.

=item C<-D> or <name>

PostgreSQL database name.

=item C<-H> or <host>

PostgreSQL database host address.

=item C<-O> or <port>

PostgreSQL database port address.

=item C<-U> or <username>

PostgreSQL database username.

=item C<-P> or <password>

PostgreSQL database password.

=item C<-Q> or <query>

The database partition to compare.

=back

=head2 AUTHOR

Yalin Pala - L<http://yplog.xyz/>
Email: yalinpala@protonmail.com

=head2 LICENSE

This is released under the Artistic License.
See L<https://dev.perl.org/licenses/artistic.html>

=cut


sub main {
	my %opts;
	getopts('fDHOUPQ:g', \%opts);

	if(check_usage(\%opts)){
		my $directory_path = $opts{'f'};
		my $dbname = $opts{'D'};
		my $host = $opts{'H'};
		my $port = $opts{'O'};
		my $username = $opts{'U'};
		my $password = $opts{'P'};
		my $query_string = $opts{'Q'};

		my @database_files = &get_database_files;
		my @directory_files = &get_directory_files;

		my $lc = List::Compare->new(\@directory_files, \@database_files);
		my @deleted_files = $lc->get_unique;

		my $number;
		foreach my $file (@deleted_files) {
			$number = unlink(join $directory_path, $file);
		}
		print "$number file(s) deleted!\n";
	}
	elsif($opts{'g'}){
		&generate_config_file;
	}
	else{
		if(&check_config_file) {
			my $c_parser = XML::Simple->new();
			my $dom = $c_parser->XMLin('./config.xml');
			my $directory_path = $dom->{path};
			my $dbname = $dom->{name};
			my $host = $dom->{host};
			my $port = $dom->{port};
			my $username = $dom->{username};
			my $password = $dom->{password};
			my $quert_string = $dom->{query};

			my @database_files = &get_database_files;
			my @directory_files = &get_directory_files;

			my $lc = List::Compare->new(\@directory_files, \@database_files);
			my @deleted_files = $lc->get_unique;

			my $number;
			foreach my $file (@deleted_files) {
				$number = unlink(join $directory_path, $file);
			}
			print "$number file(s) deleted!\n";
		}
		else {
			print "Please check config file.\n";
		}
	}
}

&main;

sub check_config_file {
	my $c_parser = XML::Simple->new();
	my $dom = $c_parser->XMLin('./config.xml');
	my $f = $dom->{path};
	my $D = $dom->{name};
	my $H = $dom->{host};
	my $O = $dom->{port};
	my $U = $dom->{username};
	my $P = $dom->{password};
	my $Q = $dom->{query};

	if("" eq $f || "" eq $D || "" eq $H || "" eq $O || "" eq $U || "" eq $P || "" eq $Q){
		return 0;
	}

	return 1;
}

sub generate_config_file {
	open(my $cf, '>', 'config.xml') or die "Could not opened file!";
	print $cf qq(<?xml version="1.0" encoding="UTF-8"?>
<config>
  <path></path>
  <name></name>
  <host></host>
  <port></port>
  <username></username>
  <password></password>
  <query></query>
</config>);
	close $cf;

	print 'Generated config.xml file.';
}

sub check_usage {
	my $opts = shift;

	my $f = $opts->{'f'};
	my $D = $opts->{'D'};
	my $H = $opts->{'H'};
	my $O = $opts->{'O'};
	my $U = $opts->{'U'};
	my $P = $opts->{'P'};
	my $Q = $opts->{'Q'};

	if(defined($f) && defined($D) && defined($H) && defined($O) && defined($U) && defined($P) && defined($Q)){
		return 0;
	}

	return 1;
}

sub get_directory_files {
	my $c_parser = XML::Simple->new();
	my $dom = $c_parser->XMLin('./config.xml');
	my $dir_path = $dom->{path};

	opendir my $dh, $dir_path or die "Cannot open $dir_path";
	my @dir_files;
	foreach my $file (readdir $dh) {
		push(@dir_files, $file);
	}
	return @dir_files;
}

sub get_database_files {
	my $c_parser = XML::Simple->new();
	my $dom = $c_parser->XMLin('./config.xml');
	my $directory_path = $dom->{path};
	my $dbname = $dom->{name};
	my $host = $dom->{host};
	my $port = $dom->{port};
	my $username = $dom->{username};
	my $password = $dom->{password};
	my $quert_string = $dom->{query};

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