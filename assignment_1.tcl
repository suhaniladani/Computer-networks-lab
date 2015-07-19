#Lan simulation
set ns [new Simulator]

#define color for data flows
$ns color 1 Red
$ns color 2 Blue


 #open tracefiles
set tracefile1 [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile1
#open nam file
set namfile [open out.nam w]
$ns namtrace-all $namfile
#define the finish procedure
proc finish {} { 
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
} 

#create eleven nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]

$n2 color red
$n7 color red

$n1 color green
$n10 color green

$n8 color blue
$n0 color blue
#create links between the nodes
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 2Mb 10ms DropTail
set lan [$ns newLan "$n2 $n4 $n9" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]

$ns duplex-link $n4 $n5 2Mb 10ms DropTail
$ns duplex-link $n5 $n6 2Mb 10ms DropTail
$ns duplex-link $n4 $n6 2Mb 10ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
$ns duplex-link $n9 $n10 2Mb 10ms DropTail


#Give node position


$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n0 $n1 orient down
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient up

$ns duplex-link-op $n4 $n5 orient up-right	
$ns duplex-link-op $n5 $n6 orient down
$ns duplex-link-op $n4 $n6 orient right-down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n9 $n10 orient right




$ns queue-limit $n2 $n3 20

#setup a UDP connection

set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp $null
$udp set fid_ 2

set udp1 [new Agent/UDP]
$ns attach-agent $n8 $udp1
set null1 [new Agent/Null]
$ns attach-agent $n0 $null1
$ns connect $udp1 $null1

$udp1 set fid_ 3


 #setup TCP connection

set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 1000

#set ftp over tcp connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp


#setup a CBR over UDP connection

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 0.01Mb
$cbr set random_ false

set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 0.01Mb
$cbr1 set random_ false

#scheduling the events
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 1.0 "$cbr1 start"
$ns at 124.0 "$ftp stop"
$ns at 125.5 "$cbr stop"
$ns at 125.5 "$cbr1 stop"




proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
 $ns at [expr $now+$time] "plotWindow $tcpSource $file"
}


$ns at 0.1 "plotWindow $tcp $winfile"
$ns at 125.0 "finish"
$ns run
