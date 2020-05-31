while ((1))
do
    for i in '\' '|' '/' '~' ;do echo $i;sleep 1;tput cuu1;tput el;done
done