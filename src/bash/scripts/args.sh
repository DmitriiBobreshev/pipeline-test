if [ $@ != 'hello' ]
then
    echo "Error!" 1>&2
    echo $@ 1>&2
    exit 64
fi