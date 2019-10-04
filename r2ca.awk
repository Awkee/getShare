#!/bin/awk -f
BEGIN{
    FS=OFS=","
    nf = 0
}
!/^[\t ]+$|^$|^$/{
	gsub(/\t| /,"");
    nr++
    for(i = 1; i <= NF; i++)
    {
        idx = nr" "i;
        if( $i == "--" ) $i = 0
        arr[idx] = $i;
    }
    if(nf < NF)
        nf = NF
}
END{
    for( j = 1; j <= nf; j++)
    {
        for( i = 1; i < nr; i++)
        {
            idx = i" "j
            printf("%s%s", arr[idx], FS); 
        }
        printf("%s\n", arr[i" "j]); 
    }
}
