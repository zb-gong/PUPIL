rm -Rf results
mkdir -p results

export HEARTBEAT_ENABLED_DIR=heartenabled/
export OMP_NUM_THREADS=32
rm -Rf ${HEARTBEAT_ENABLED_DIR}

mkdir -p ${HEARTBEAT_ENABLED_DIR}


SET_SPEED=/home/hankhoffmann/tools/powerQoS/pySetCPUSpeed.py
POWER_MON=/home/hankhoffmann/tools/powerQoS/pyWattsup-hank.py

#sudo ls > /dev/null

mkdir -p ${HEARTBEAT_ENABLED_DIR}

for i in 0

  do

 for j in {15..15} 
    do

    freq=`expr 15 - $j`

    $SET_SPEED -S $freq


    for k in {0..0}
      do
      
      #$LOGGER $NUMBER >log.txt &
      
      #sudo -E taskset -c 0-$i ${BINARY} ${ARGS} 
      #sudo -E taskset -c 0,1 ${BINARY} ${ARGS}  
     #sudo -E numactl --interleave=0-$k --physcpubind=0-$i ${BINARY} ${ARGS} >& /dev/null
    
      HR=''
      power=''
      joules=''
      c=1
      m=0
    while [[ $HR = '' ]]||[[ $power = '' ]]||[[ $joules = '' ]]||[[ $c -le 0 ]]

      do

      $POWER_MON start

      m=`expr $i - 16`
     if [ $i -lt 32 ];then
     sudo -E numactl --interleave=0-$k --physcpubind=0-$i /local/huazhe/seec-bench/bench_hank/dijkstra2/dijkstra-pt-hb2 32 100
     n=$i
     else
     sudo -E numactl --interleave=0-$k --physcpubind=0-7,16-$m /local/huazhe/seec-bench/bench_hank/dijkstra2/dijkstra-pt-hb2 32 100
     n=`expr $i - 24`
     fi
      $POWER_MON stop > power.txt
      
      HR=`tail -n 1 heartbeat.log | awk '// {print $4}'`
      power=`cat power.txt | awk '/Pavg/ {print $2}'`
      joules=`cat power.txt | awk '/Joules/ {print $2}'`
      power2=`tail -n 1 heartbeat.log | awk '// {print $10}'`
#     joules2=`echo "scale=4; $NUMBER / $HR * $power2" | bc`
      c=$(echo "$power2 > 0" | bc)

  #    echo $i $j $k $HR $power2 $joules2 $power $joules >> shmoo2.results

      done
      echo $n $j $k $HR $power2 $power $joules >> dijkstra32threads.results
      
      cp power.txt power-static-oracle.txt
      cp heartbeat.log heartbeat-static-oracle.log


      sleep 5

  done
    done
      MEMS=`ipcs | grep root | awk '{print $2}'`
      for k in $MEMS;
      do
          echo sudo Freeing $k;
          sudo ipcrm -m $k;
      done
done



