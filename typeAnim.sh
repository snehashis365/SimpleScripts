function load ()
{
    while ((1))
    do
        for i in '\' '|' '/' '~' ;do echo $i;sleep 1;tput cuu1;tput el;done
    done
}
function type ()
{
    string=$1
    index=0
    len=${#string}
    while ((index<len))
    do
        char="${string:index:1}"
        if [[ "$char" == "\\" ]]
        then
            char="${string:index:2}"
            let "index=index+1"
        fi
        echo -ne "$char"
        sleep 0.075
        let "index=index+1"
    done
    echo
}
if [ $# -gt 0 ]
then
	while(($#))
	do
        type $1
        shift
    done
else
    type "Hello World\nThis is a test string"
fi
