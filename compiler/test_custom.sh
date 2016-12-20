#!/bin/bash
if [ "$1" == "-c" ]
then 
	darn.native $1 $2 stdlib.darn | /usr/local/opt/llvm/bin/lli
else
	darn.native $1 $2 stdlib.darn
fi
