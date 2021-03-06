# DESCRIPTION

This script compares the files in the PostgreSQL database with the file assets in the directory.
Deletes files that are not in the database.

## HOW TO USE

- Runing With Config File `perl rd-dd.pl`

    First, a configuration file must be created. Requires the config.xml file.
    If you do not have a config.xml file, use the `perl rd-dd.pl -g` to create it.
    Example:
        ```
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
        ```
- Runing With One Line `perl rd-dd.pl -f -D -H -O -U -P -Q`

    All parameters are required.
    Example:
        ```
        perl rd-dd.pl -f "path\of\directory\" -D "database_name" -H "127.0.0.1" -O "5432" -U "postgres" -P "root" -Q "SELECT user_file FROM user"
        ```

- `-f` or &lt;path>

    The directory containing the files to compare with the database.

- `-D` or &lt;name>

    PostgreSQL database name.

- `-H` or &lt;host>

    PostgreSQL database host address.

- `-O` or &lt;port>

    PostgreSQL database port address.

- `-U` or &lt;username>

    PostgreSQL database username.

- `-P` or &lt;password>

    PostgreSQL database password.

- `-Q` or &lt;query>

    The database partition to compare.

## AUTHOR

Yalin Pala - [http://yplog.xyz/](http://yplog.xyz/)
Email: yalinpala@protonmail.com

## LICENSE

This is released under the Artistic License.
See [https://dev.perl.org/licenses/artistic.html](https://dev.perl.org/licenses/artistic.html)

Generated from Pod::Markdown - Convert POD to Markdown [Pod::Markdown](https://metacpan.org/pod/Pod::Markdown)