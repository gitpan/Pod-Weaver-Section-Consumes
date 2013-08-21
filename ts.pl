use SQL::Abstract;

my $from = 1;
my $till = 2;
my $phone_number = 3;

    my ( $sql, @values ) = SQL::Abstract->new->select( 
        'calls',
        '*',
        { time => { '<=' => $till, '>' => $from },
          $phone_number ? ( phone_number => $phone_number ) : ( ),
        },
        'time'
    );

print "$sql\n";
print for @values;
