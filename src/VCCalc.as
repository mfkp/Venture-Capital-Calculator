// ActionScript file
// @author Kyle Powers, Jason Kruse
import mx.collections.ArrayCollection;
import mx.controls.Alert;

private var seriesLetters:Array = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
private var curSeries:int = 0; 

private var series:Array = new Array();
//outputs
private var founders:Object = new Object();
private var rounds:Array = new Array();
private var atExit:Object = new Object();
private var objColl:ArrayCollection = new ArrayCollection();
private var temp:Object = new Object(); 
private var incManagementPool:Boolean =false;

private function debug():void {
	// fill out all text boxes
	toExit.text = "60";
	numRounds.text = "3";
	numFounderShares.text = "1000000";
	PERatio.text = "15";
	earnings.text = "2500000";
	// fill out series text boxes
	series[0] = {monToInvestment: 0, investmentAmount: 1500000, targetROI: .5 };
	series[1] = {monToInvestment: 24, investmentAmount: 1000000, targetROI: .4 };
	series[2] = {monToInvestment: 48, investmentAmount: 1000000, targetROI: .25 };
	calculate(false);
}
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
		incManagementPool = true;
		this.managementSharesParent.height = 30;
	} else {
		incManagementPool = false;
		this.managementSharesParent.height = 0;
	}
}
private function saveRound():void {
	series[curSeries] = {monToInvestment: int(monToInvestment.text), investmentAmount: int(investmentAmount.text), targetROI:Number(targetROI.text) };
}
private function test():void {
	//trace(series.length, series[curSeries-1].monToInvestment);
	
}
private function calculate(saveNewRound:Boolean=true):void {
	if(saveNewRound)
		saveRound();
	atExit.firmValuation = int(PERatio.text) * int(earnings.text);
	
	trace(series[x].investmentAmount);
	founders.sharesIssued = int(numFounderShares.text);
	founders.sharesOutstanding = int(numFounderShares.text);
	founders.initialOwnership = 100;
	var sharesOutstanding:int;
	var totalVCOwnership:Number = 0;
	var laterInvestment:Number;
	for(var x:int=0;x<series.length;x++) {
		rounds[x] = new Object();
		rounds[x].newInvestment = series[x].investmentAmount;
		rounds[x].yearsToExit = (int(toExit.text) /12) - (series[x].monToInvestment / 12);
		rounds[x].reqROI = Number(series[x].targetROI);
		rounds[x].reqTerminalVal = rounds[x].newInvestment * Math.pow(1 + rounds[x].reqROI,rounds[x].yearsToExit);
		rounds[x].terminalOwnership = rounds[x].reqTerminalVal / atExit.firmValuation;
		totalVCOwnership += rounds[x].terminalOwnership;
		
		//rounds[x].initialOwnership = rounds[x].newInvestment / ( int(earnings.text) * int(PERatio.text));
		
		 
		//rounds[x].sharesIssued = int((rounds[x].initialOwnership * int(numFounderShares.text)) / (1 - rounds[x].initialOwnership));
		
		
	}
	
	// run through again for ownership percentages
	for(var x:int=0;x<series.length;x++) {
		laterInvestment =0;
		for(var y:int=x+1;y<series.length;y++) {
			laterInvestment += rounds[y].terminalOwnership;
		}
		if(this.incManagementPool) {
			laterInvestment += Number(managementPercent.text) / 100;
		}
		rounds[x].retention = 1 - laterInvestment;
		rounds[x].initialOwnership = rounds[x].terminalOwnership / rounds[x].retention;
		
		if(x==0) {
			sharesOutstanding = founders.sharesOutstanding;
			//mx.controls.Alert.show(rounds[x].initialOwnership + " | " + sharesOutstanding); 	
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
	sharesOutstanding += rounds[series.length-1].sharesIssued
	if(this.incManagementPool) {
		totalVCOwnership += Number(managementPercent.text) / 100;
		atExit.retention = Number(managementPercent.text) / 100;
		atExit.initialOwnership = Number(managementPercent.text) / 100;
		atExit.sharesIssued = (atExit.initialOwnership * sharesOutstanding) / ( 1 - atExit.initialOwnership);;
		atExit.sharesOutstanding = rounds[rounds.length-1].shareOutstanding + atExit.sharesIssued;
	} else {
		atExit.retention = "";
		atExit.initialOwnership = "";
		atExit.sharesIssued = "";
		atExit.sharesOutstanding = sharesOutstanding;
	}
	
	
	atExit.sharePrice = atExit.firmValuation / atExit.sharesOutstanding;
	if(this.incManagementPool) {
		atExit.valueAtExit = atExit.sharesIssued * atExit.sharePrice;
	} else {
		atExit.valueAtExit = "";
	}
	founders.terminalOwnership = Number(1 - totalVCOwnership);
		
	for(var y:int=0;y<series.length;y++) {
		rounds[y].valueAtExit = rounds[y].sharesIssued * atExit.sharePrice;
	}
	founders.valueAtExit = founders.sharesIssued * atExit.sharePrice;
	
	currentState='Output';
	fillGrid();
}

private function fillGrid():void{
	
	var str:String; 
	var i:int;
//begin: add headings
	addDataGridColumn("col0", "Founders");
	this.validateNow();
	for(var x:int=1;x<= int(numRounds.text); x++){
		addDataGridColumn("col" + x, "Round " + x);
		this.validateNow();
	}
	addDataGridColumn("col" + (output_table.columns.length + 1), "Exit");
	this.validateNow();
//end: add headings

//years from initiation
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = (int(toExit.text)/12) - rounds[i-1].yearsToExit;
	}
	temp[String("col"+ (output_table.columns.length))] = rounds[0].yearsToExit;
	addRow();
//years to exit
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = rounds[i-1].yearsToExit;
	}
	temp[String("col"+ (output_table.columns.length))] = (int(toExit.text)/12) - rounds[0].yearsToExit;
	addRow();
//vc's required ROI
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].reqROI);
	}
	addRow();
//new vc investment
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].newInvestment);
	}
	addRow();
//vc's required terminal value
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].reqTerminalVal);
	}
	addRow();
//terminal % ownership
	temp[String("col0")] = founders.terminalOwnership;
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = rounds[i-1].terminalOwnership;
	}
	temp[String("col"+ (output_table.columns.length))] = managementPercent.text;
	addRow();
//retention %
	temp[String("col0")] = founders.terminalOwnership;
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = rounds[i-1].retention;
	}
	temp[String("col"+ (output_table.columns.length))] = atExit.retention;
	addRow();
//initial % ownership
	temp[String("col0")] = 1;
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = rounds[i-1].initialOwnership;
	}
	temp[String("col"+ (output_table.columns.length))] = atExit.initialOwnership;
	addRow();
//shares issued
	temp[String("col0")] = int(numFounderShares.text);
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = rounds[i-1].sharesIssued;
	}
	temp[String("col"+ (output_table.columns.length))] = atExit.sharesIssued;
	addRow();
//shares outstanding
	temp[String("col0")] = String(founders.sharesOutstanding);
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].sharesOutstanding);
	}
	temp[String("col"+ (output_table.columns.length))] = atExit.sharesOutstanding;
	addRow();
//share price
	temp[String("col0")] = String(founders.sharePrice);
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].sharePrice);
	}
	temp[String("col"+ (output_table.columns.length))] = atExit.sharePrice;
	addRow();
//firm valuation
	temp[String("col0")] = String(founders.firmValuation);
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].firmValuation);
	}
	temp[String("col"+ (output_table.columns.length))] = atExit.firmValuation;
	addRow();
//investment value at exit
	temp[String("col0")] = founders.valueAtExit;
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = rounds[i-1].valueAtExit;
	}
	temp[String("col"+ (output_table.columns.length))] = atExit.valueAtExit;
	addRow();
}

private function addRow():void {
	arrCol.addItem(temp);
	temp=[];
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


private function addDataGridColumn(dataField:String, header:String):void {
    var dgc:AdvancedDataGridColumn = new AdvancedDataGridColumn(dataField);
    dgc.visible = true;
    dgc.headerText = header;
    var cols:Array = output_table.columns;
    cols.push(dgc);
    output_table.columns = cols;
}