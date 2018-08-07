        #!/bin/bash
        for i in $( ls ); do
            cd $i
	    mkdir image label
	    cd ..
        done
