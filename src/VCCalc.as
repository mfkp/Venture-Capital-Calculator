// ActionScript file
// @author Kyle Powers, Jason Kruse
import mx.collections.ArrayCollection;
import mx.formatters.NumberBase;
import mx.formatters.NumberBaseRoundType;

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
	for(var x:int=0;x<series.length;x++) {
		rounds[x] = new Object();
		rounds[x].newInvestment = series[x].investmentAmount;
		rounds[x].yearsToExit = (int(toExit.text) /12) - (series[x].monToInvestment / 12);
		rounds[x].reqROI = Number(series[x].targetROI);
		rounds[x].reqTerminalVal = rounds[x].newInvestment * Math.pow(1 + rounds[x].reqROI,rounds[x].yearsToExit);
		rounds[x].terminalOwnership = rounds[x].reqTerminalVal / atExit.firmValuation;
		totalVCOwnership+= rounds[x].terminalOwnership;
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
	if(this.incManagementPool) {
		totalVCOwnership += Number(managementPercent.text) / 100;
	}
	founders.terminalOwnership = Number(1 - totalVCOwnership);
	for(var y:int=0;y<series.length-1;y++) {
		rounds[y].investmentValueAtExit = rounds[y].sharesIssued * rounds[rounds.length-1].sharePrice;
	}
	founders.investmentValueAtExit = founders.sharesIssued * rounds[rounds.length-1].sharePrice;
	currentState='Output';
	fillGrid();
}

private function fillGrid():void{
	
	var str:String; 
	var i:int;
	var base:NumberBase = new NumberBase();
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
		temp[String("col"+i)] = base.formatPrecision(String(100*(Number(String(rounds[i-1].reqROI)))),3) + "%";
	}
	addRow();
//new vc investment
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = base.formatThousands(String(Math.round(rounds[i-1].newInvestment)));
	}
	addRow();
//vc's required terminal value
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = base.formatThousands(String(Math.round(rounds[i-1].reqTerminalVal)));
	}
	addRow();
//terminal % ownership
//WRONG
	temp[String("col0")] = base.formatPrecision(String(100*(Number(founders.terminalOwnership))),3) + "%";
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = base.formatPrecision(String(100*(Number(rounds[i-1].terminalOwnership))),3) + "%";
	}
	temp[String("col"+ (output_table.columns.length))] = base.formatPrecision(String(100*(Number(managementPercent.text))),3) + "%";
	addRow();
//retention %
//WRONG
	temp[String("col0")] = "99";
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = "99";
	}
	temp[String("col"+ (output_table.columns.length))] = "99";
	addRow();
//initial % ownership
//WRONG
	temp[String("col0")] = String(founders.initialOwnership);
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].initialOwnership);
	}
	temp[String("col"+ (output_table.columns.length))] = "99";
	addRow();
//shares issued
//WRONG
	temp[String("col0")] = String(founders.sharesIssued);
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].sharesIssued);
	}
	temp[String("col"+ (output_table.columns.length))] = "99";
	addRow();
//shares outstanding
//WRONG
	temp[String("col0")] = String(founders.sharesOutstanding);
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].sharesOutstanding);
	}
	temp[String("col"+ (output_table.columns.length))] = "99";
	addRow();
//share price
//WRONG
	temp[String("col0")] = String(founders.sharePrice);
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].sharePrice);
	}
	temp[String("col"+ (output_table.columns.length))] = "99";
	addRow();
//firm valuation
//WRONG (round 3 is right)
	temp[String("col0")] = String(founders.firmValuation);
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].firmValuation);
	}
	temp[String("col"+ (output_table.columns.length))] = atExit.firmValuation;
	addRow();
//investment value at exit
//WRONG
	temp[String("col0")] = String(founders.investmentValueAtExit);
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = String(rounds[i-1].investmentValueAtExit);
	}
	temp[String("col"+ (output_table.columns.length))] = "99";
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