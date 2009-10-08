// ActionScript file
// @author Jason Kruse, Kyle Powers
import mx.collections.ArrayCollection;

private var seriesLetters:Array = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
private var curSeries:int = 0; 

private var series:Array = new Array();
//outputs
private var founders:Object = new Object();
private var rounds:Array = new Array();
private var atExit:Object = new Array();
private var objColl:ArrayCollection = new ArrayCollection();

private function openRounds():void {
	if(int(numRounds.text) > 0) {
		if(int(numRounds.text) > 1) {
			nextbtn.enabled = true;
		}
		this.seriesInputParent.height = 140;
	}
	
}
private function toggleManPool(open:Boolean):void {
	if(open) {
		this.managementSharesParent.height = 30;
	} else {
		this.managementSharesParent.height = 0;
	}
}
private function saveRound():void {
	series[curSeries] = {monToInvestment: int(monToInvestment.text), investmentAmount: int(investmentAmount.text), targetROI:Number(targetROI.text) };
}
private function test():void {
	//trace(series.length, series[curSeries-1].monToInvestment);
	
}
private function calculate():void {
	saveRound();
	trace(series[x].investmentAmount);
	founders.sharesIssued = int(numFounderShares.text);
	founders.sharesOutstanding = int(numFounderShares.text);
	founders.initialOwnership = 100;
	var sharesOutstanding:int;
	for(var x:int=0;x<series.length;x++) {
		rounds[x] = new Object();
		rounds[x].newInvestment = series[x].investmentAmount;
		rounds[x].yearsToExit = (int(toExit.text) /12) - (series[x].monToInvestment / 12);
		rounds[x].reqROI = series[x].targetROI;
		rounds[x].reqTerminalVal = rounds[x].newInvestment * Math.pow(1 + rounds[x].reqROI,rounds[x].yearsToExit);
		rounds[x].initialOwnership = rounds[x].newInvestment / ( int(earnings.text) * int(PERatio.text));
		if(x==0) {
			sharesOutstanding = founders.sharesOutstanding; 	
		} else {
			sharesOutstanding = rounds[x-1].sharesOutstanding;
		}
		rounds[x].sharesIssued = (rounds[x].initialOwnership * sharesOutstanding) / ( 1 - rounds[x].initialOwnership);
		rounds[x].sharesOutstanding = sharesOutstanding + rounds[x].sharesIssued;
		rounds[x].sharePrice = rounds[x].newInvestment / rounds[x].sharesIssued;
		rounds[x].firmValuation = rounds[x].sharesOutstanding * rounds[x].sharePrice;
		 
		 
		
		if(x==0) {
			// first run through, figure out some more founders info now that we have an initial investment
			founders.sharePrice = rounds[0].sharePrice;
			founders.firmValuation = founders.sharesOutstanding * founders.sharePrice; 	
		}
	}
	for(var y:int=0;y<series.length-1;y++) {
		rounds[y].investmentValueAtExit = rounds[y].sharesIssued * rounds[rounds.length-1].sharePrice;
	}
	founders.investmentValueAtExit = founders.sharesIssued * rounds[rounds.length-1].sharePrice;

	currentState='Output';
}
private function switchRound(dir:int):void {
	saveRound();
	
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


private function addDataGridColumn(dataField:String):void {
    var dgc:AdvancedDataGridColumn = new AdvancedDataGridColumn(dataField);
    dgc.visible = true;
    dgc.headerText = "Round " + (output_table.columns.length + 1);
    var cols:Array = output_table.columns;
    cols.push(dgc);
    output_table.columns = cols;
}

private function init():void {
    addDataGridColumn("col" + (output_table.columns.length + 1));
}