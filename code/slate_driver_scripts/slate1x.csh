###############################################################################
##                                                                           ## 
# SLATE: System for Local Area Traffic Estimation                             #
#                                                                             #
# by David Levinson                                                           # 
#                                                                             # 
# date of last update: 10/18/91                                               # 
#                                                                             # 
# usage: slate SSSS R MM > & fooSSSS &                                        # 
#                                                                             # 
# where: SSSS = 4 digit scenario number                                       # 
#           R = 1 letter run identifier                                       # 
#                                                                             # 
##                                                                           ## 
###############################################################################
###############################################################################
# set $emme2 release version
###############################################################################
set emme2=/users/emme2/rel4/etc/emme2
###############################################################################
# set model parameters
###############################################################################
set scen=$1
set run=$2
set iterate=1
set limit=15
set turnset="yes"
set netset="yes"
###############################################################################
# determine output plots (yes/no)
###############################################################################
set pltdff=no
set pltcap=no
set pltffs=no
set pltspd=no
set pltcfr=no
set pltclv=no
set pltvcr=no
set pltlan=no
###############################################################################
# set default directories
###############################################################################
set returnTo = $cwd
set macros="/mnt/macros/travel2"
set bin="/mnt/Mtools/Ttools/bin"
set source="/mnt/Mtools/Ttools/source"
set configure="$returnTo/configure"
set countsfile="nocounts"
set speedsfile="nospeeds"
set delay="$configure/delay3"
set autocal="$configure/d241.cal"
set nodename="$configure/nodename.in"
set turnlanes="$configure/turnlanes.in"
set rf="$returnTo/rf$scen$run"
###############################################################################
## Do some directory manipulations
###############################################################################
if ( -e $rf) then
  rm -fr $rf/*
  rmdir $rf
endif
mkdir $rf
rm errors
touch errors
###############################################################################
## Prepare module parameters
###############################################################################
$emme2 clear batch -m "$macros/t.scenario $scen"
$emme2 clear batch -m "$macros/t.switches"
$emme2 clear 212 batch -m "$macros/t.modpar212"
$emme2 clear 213 batch -m "$macros/t.modpar213"
$emme2 clear 313 batch -m "$macros/t.modpar313"
$emme2 clear 314 batch -m "$macros/t.modpar314"
$emme2 clear 316 batch -m "$macros/t.modpar316"
$emme2 clear 322 batch -m "$macros/t.modpar322"
$emme2 clear 413 batch -m "$macros/t.modpar413"
##$emme2 clear 534 batch -m "$macros/t.modpar534"
##$emme2 clear 535 batch -m "$macros/t.modpar535"
## execute only if auto assignment done on this scenario
#$emme2 clear 611 batch -m "$macros/t.modpar611"
#$emme2 clear 612 batch -m "$macros/t.modpar612"
#$emme2 clear 613 batch -m "$macros/t.modpar613"
#$emme2 clear 614 batch -m "$macros/t.modpar614"
#$emme2 clear 615 batch -m "$macros/t.modpar615"
## execute only if transit assignment done on this scenario
#$emme2 clear 621 batch -m "$macros/t.modpar621"
#$emme2 clear 622 batch -m "$macros/t.modpar622"
#$emme2 clear 623 batch -m "$macros/t.modpar623"
###############################################################################
## Define Volume Delay Functions
###############################################################################
if ($netset == "yes") then
    cp $autocal $returnTo/d241.in
    cp $autocal $rf
    $emme2 clear 241 batch -m "$macros/t.newervdf"
endif
###############################################################################
## Initialize Turn Penalties 
###############################################################################
if ($turnset == "yes" ) then
   awk -f $source/makedeftl.a $turnlanes > $returnTo/d231.in
   $bin/idelay $nodename $turnlanes $returnTo/d231.in
   if ($status != 0) then
       banner "FAILED"
       banner "IDELAY"
       exit
   endif
   sort -n +1 -2 +2 -3 +3 -4 $returnTo/d231.out -o $returnTo/d231.out
   echo "t turns init" > $returnTo/d231.in
   cat $returnTo/d231.out >> $returnTo/d231.in
   $emme2 clear 231 batch -m "$macros/t.clear231"
   mv reports $rf/rep.turnpen
###############################################################################
### Create Dummy Scenario
###############################################################################
   $emme2 clear 122 batch -m "$macros/t.createdummy $scen"
###############################################################################
### for Dummy Scenario Initialize Turn Penalties
###############################################################################
   $emme2 clear batch -m "$macros/t.scenario 1"
     $emme2 clear 231 batch -m "$macros/t.clear231"
   $emme2 clear batch -m "$macros/t.scenario $scen"
   mv d231.in $rf/d231.$1$2
endif
###############################################################################
## NORMALIZATION : Make sure Os match Ds
###############################################################################
    $emme2 clear 321 batch -m "$macros/t.normalize"
###############################################################################
## DESTINATION CHOICE: Distribute Trips using consistent TRAVEL 2 pattern
###############################################################################
   $emme2 clear 322 batch -m "$macros/t.distribute" 
###############################################################################
## ROUTE CHOICE: STATIC USER EQUILIBRIUM ASSIGNMENT
###############################################################################
while ( $iterate <= $limit )
  if ( $iterate == "1" ) then
     $emme2 clear 511 batch -m "$macros/t.assignment $iterate"
     $emme2 clear 521 batch
     if ( $status != 0 ) then
       banner "FAILED"
       banner "ASSIGNMENT"
       echo   "iteration $iterate"
       exit
     endif
     cat $returnTo/reports >> $rf/rep.521dd
  else if ( $iterate > "1" ) then
##########################
## Intersection Delay Model
##########################
    $emme2 clear 611 batch -m "$macros/t.611int"
    if ($status != 0) then
      banner "FAILED"
      banner "611REPORT"
      echo   "nodes: iteration $iterate"
      exit
    endif
   awk '{if ($1~/[0-9]/ && NF>6) {printf ("%4d %4d %4d %6d\n",$1,$2,$3,$(NF-2))}}' $returnTo/reports > $rf/turnvols.in
   $bin/idelay $nodename $turnlanes $rf/turnvols.in
   if ($status != 0) then
      banner "FAILED"
      banner "IDELAY"
      echo   "iteration $iterate"
      exit
   endif
##########################
## Intersection Equilibration Algorithm
##########################
   sort -n +1 -2 +2 -3 +3 -4 $returnTo/d231.out -o $returnTo/d231.out
   awk -f $source/stabilizer1.a iterate=$iterate $returnTo/critical.out $rf/rep.critical >> $rf/stablelist
   awk -f $source/stabilizer2.a $rf/stablelist  $returnTo/d231.out > $returnTo/d231.in
#   echo "t turns init" > $returnTo/d231.in
#   cat $returnTo/d231.out >> $returnTo/d231.in
   mv $returnTo/d231.out $rf
   $emme2 clear batch -m "$macros/t.scenario 1"
        $emme2 clear 231 batch -m "$macros/t.input231"
        mv d231.in $rf/d231.in
        $emme2 clear 511 batch -m "$macros/t.511dummy"
        $emme2 clear 111 batch -m "$macros/t.copyfile42 $scen"
   $emme2 clear batch -m "$macros/t.scenario $scen"
   mv $returnTo/turnvols.out $rf/rep.turnvols
   mv $returnTo/critical.out $rf/rep.critical
   mv $returnTo/interdesc.out $rf/rep.interdesc
   mv $returnTo/sigstat.out $rf/rep.sigstat
##########################
## Link Model
##########################
    $emme2 clear 511 batch -m "$macros/t.511DD $iterate"
    $emme2 clear 521 batch
    if ($status != 0) then
       banner "FAILED"
       banner "ASSIGNMENT"
       echo   "iteration $iterate"
       exit
    endif
    cat $returnTo/reports >> $rf/rep.521dd
  endif
   grep "Maximum difference:       .00" $rf/rep.521dd
   if ($status != 0) then
      set distribute = "Open"
   else 
      set distribute = "Closed"
      @ iterate = $limit + 1
   endif
@ iterate = $iterate + 1
end
###############################################################################
## FINAL PLOTS
###############################################################################
####################################
## Difference Simulated - Observed Volumes Plot
####################################
if ($pltdff == "yes") then
   cp $countsfile d241.in
   $emme2 clear 241 batch -m "$macros/t.difference"
   $emme2 clear 213 batch -m "$macros/t.plotdiff"
   mv $returnTo/plots  $rf/plt.dff$1
endif
#####################################
### Plot Freeflow Speeds
#####################################
if ($pltffs == "yes") then
   $emme2 clear 241 batch -m "$macros/t.colorffs"
   $emme2 clear 213 batch -m "$macros/t.plotffs"
   mv $returnTo/plots  $rf/plt.ffs$1
endif
#####################################
### Plot Capacities
#####################################
if ($pltcap == "yes") then
   $emme2 clear 241 batch -m "$macros/t.colorcap"
   $emme2 clear 213 batch -m "$macros/t.plotcap"
   mv $returnTo/plots  $rf/plt.cap$1
endif
#####################################
### Speed Plot
#####################################
if ($pltspd == "yes") then
   $emme2 clear 241 batch -m "$macros/t.calcspeed"
   $emme2 clear 612 batch -m "$macros/t.plotspeed"
   mv $returnTo/plots $rf/plt.spd$1
endif
#####################################
### Congested Freeflow Ratio Plot
#####################################
if ($pltcfr == "yes") then
   $emme2 clear 241 batch -m "$macros/t.calccfr"
   $emme2 clear 213 batch -m "$macros/t.plotcfr"
   mv $returnTo/plots $rf/plt.cfr$1
endif
#####################################
### CLV Plot on network
#####################################
if ($pltclv == "yes") then
   cp $rf/rep.critical $returnTo/d241.in
   $emme2 clear 241 batch -m "$macros/t.critical"
   $emme2 clear 213 batch -m "$macros/t.plotcrit"
   mv $returnTo/plots $rf/plt.clv$1
endif
#####################################
### Color Coded Lanes Plot
#####################################
if ($pltlan == "yes") then
   $emme2 clear 241 batch -m "$macros/t.colorlanes"
   $emme2 clear 213 batch -m "$macros/t.plotlanes"
   mv $returnTo/plots $rf/plt.lan$1
endif
####################################
## LOS Volume Capacity Ratio Plot with Policy Capacities
####################################
if ($pltvcr == "yes") then
   cp $configure/d241.polcap $returnTo/d241.in
   $emme2 clear 241 batch -m "$macros/t.polcap"
   $emme2 clear 612 batch -m "$macros/t.modpar612"
   $emme2 clear 612 batch -m "$macros/t.612vcrplot"
   mv $returnTo/plots $rf/plt.vcr$1
endif
####################################
# Reporter with Policy Capacities
####################################
$emme2 clear 611 batch -m "$macros/t.611punch"
awk -f $source/611fix.a reports > $rf/rep.611
$bin/mcreporter $delay $autocal $rf/rep.611 $countsfile $speedsfile  
cat $returnTo/rep.* > $rf/summary
rm $returnTo/rep.*
###############################################################################
## EXIT
###############################################################################
exit
