trap 'echo "Be patient"' INT

for ((n=2000; n; n--))
do
    now="$(date)"
    echo "$now"
    sleep 1000
done