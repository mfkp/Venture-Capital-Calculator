// ActionScript file
// @author Jason Kruse, Kyle Powers
import mx.controls.Alert;

var seriesLetters:Array = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
var curSeries:int = 0; 

private function test():void {
	/*this.seriesInputParent.height = 140;*/
	/*this.managementSharesParent.height = 30;*/	
}
private function openRounds():void {
	this.seriesInputParent.height = 140;
}
private function toggleManPool(open:Boolean):void {
	if(open) {
		this.managementSharesParent.height = 30;
	} else {
		this.managementSharesParent.height = 0;
	}
}
private function switchRound(dir:int):void {
	/*
	make object here
	monToInvestment.text
	investmentAmount.text
	targetROI.text
	*/
	if(dir > 0) {
		curSeries++;
		monToInvestment.text = "";
		investmentAmount.text = "";
		targetROI.text = "";	
	} else {
		curSeries--;
	}
	if(curSeries == 0) {
		prevbtn.enabled = false;
	} else {
		prevbtn.enabled = true;
	}
	if(curSeries < (int(numRounds.text)-1) ) {
		nextbtn.enabled = true;
	} else {
		nextbtn.enabled = false;
	}
	serieslbl.text = "Series " + seriesLetters[curSeries];
	
	
}