#!/bin/bash

UNICORN="b5d6cbe8639a05f22ee3de9cddb48efa8bf8c528"
BLOBFISH="c6c672f8309008c0cbd446ef3ccdfe37b919b905"

function run () {
	DEVICE=$1
	SCRIPT=$2
	RESULTS=$3

	TEMPLATE="/Applications/Xcode45-DP3.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate"
	APP_PATH=`find ~/Library/Application\ Support/iPhone\ Simulator/ -name "FoxSports.app"`
	APP="com.foxsports.fs2go.dev"

	if ( [ $DEVICE = "SIMULATOR" ] && [[ ! -e $APP_PATH ]] ); then
		echo "The FoxSports app is not installed on the Simulator"
		exit 1
	fi

	#CMD="instruments -t $TEMPLATE -D ./RESULTS/FoxSportsBVTResults -w $UDID $APP -e UIASCRIPT FoxSportsRegression.js -e UIARESULTSPATH ./RESULTS"
	#CMD="instruments -t $TEMPLATE -D ./RESULTS/FoxSportsBVTResults \"$APP_PATH\" -e UIASCRIPT FoxSportsRegression.js -e UIARESULTSPATH ./RESULTS"
	
	if [ $DEVICE = "SIMULATOR" ]; then
		CMD="instruments -t $TEMPLATE -D RESULTS/FoxSportsBVTResults \"$APP_PATH\" -e UIASCRIPT $SCRIPT -e UIARESULTSPATH $RESULTS"
	else
		CMD="instruments -t $TEMPLATE -D RESULTS/FoxSportsBVTResults -w $DEVICE $APP -e UIASCRIPT $SCRIPT -e UIARESULTSPATH $RESULTS"
	fi

	echo $CMD
	eval $CMD
}

#run $UNICORN "test_runner.js" "Results"
#run $BLOBFISH "test_runner.js" "Results"
#run "SIMULATOR" "test_runner.js" "Results"
run "SIMULATOR" "bvt_runner.js" "Results"
