# DESCRIPTION

This script compares the files in the PostgreSQL database with the file assets in the directory.
Deletes files that are not in the database.

Requirements:
	DBI, 
	DBI::Pg, 
	List::Compare

## HOW TO USE

- $DIRECTORY\_PATH

    The directory containing the files to compare with the database.

- $DBNAME

    PostgreSQL database name.

- $HOST

    PostgreSQL database host address.

- $PORT

    PostgreSQL database port address.

- $USERNAME

    PostgreSQL database username.

- $PASSWORD

    PostgreSQL database password.

- QUERY\_STRING

    SQL is a standard language for storing, manipulating and retrieving data in databases.
    The database partition to compare.

## METHODS

- get\_directory\_files()

    Return directory files array.

- get\_database\_files()

    Return database files array.

## AUTHOR

Yalin Pala - [http://yplog.xyz/](http://yplog.xyz/)
Email: yalinpala@protonmail.com

## LICENSE

This is released under the Artistic License.
See [https://dev.perl.org/licenses/artistic.html](https://dev.perl.org/licenses/artistic.html)

Generated from Pod::Markdown - Convert POD to Markdown [Pod::Markdown](https://metacpan.org/pod/Pod::Markdown)
