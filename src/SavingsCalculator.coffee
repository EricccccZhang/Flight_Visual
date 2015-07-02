class SavingsCalculator
	constructor: () ->
		@constants = {
			fuelDollarsSavedPerMinPerYearPerAC: 68454
			crewDollarsSavedPerMinPerYearPerAC: 17519
			departuresPerACPerDay: 4
			daysPerYear: 365
			hoursFlownPerDayPerAC: 10
		}
		@fleetSizes = {
			small: 60
			medium: 120
			large: 710
		}
		@inputs = {
			blockMinutesSaved: 2.5
			fleetSize: @fleetSizes['medium']
		}
		@intermediaries = {
			
		}
		@outputs = {
			
		}
		
		@calculate()
	calculate: () ->
		#intermediaries
		@calculateDeparturesPerYear()
		@calculateHoursFlownPerYear()
		
		#outputs
		@calculateFuelSavings()
		@calculateMinutesSavedPerYear()
		@calculateHoursSavedPerYear()
		@calculateCrewCostSavings()
		@calculateNumberACSaved()
		@calculateTotalSavings()
		
		#additional vars not in spreadsheet
		@calculateDeparturesPerDay()
		console.log @intermediaries
		console.log @outputs
	calculateDeparturesPerYear: () ->
		inter = @intermediaries
		inter['departuresPerYear'] = @inputs.fleetSize * @constants.departuresPerACPerDay * @constants.daysPerYear
	calculateHoursFlownPerYear: () ->
		inter = @intermediaries
		inter['hoursFlownPerYear'] = @inputs.fleetSize * @constants.hoursFlownPerDayPerAC * @constants.daysPerYear
	calculateFuelSavings: () ->
		out = @outputs
		out['fuelSavingsPerYear'] =  @constants.fuelDollarsSavedPerMinPerYearPerAC * @inputs.blockMinutesSaved * @inputs.fleetSize
	calculateMinutesSavedPerYear: () ->
		out = @outputs
		out['minutesSavedPerYear'] = @inputs.blockMinutesSaved * @intermediaries.departuresPerYear
	calculateHoursSavedPerYear: () ->
		out = @outputs
		out['hoursSavedPerYear'] = out['minutesSavedPerYear'] / 60
	calculateCrewCostSavings: () ->
		out = @outputs
		out['crewCostSavingsPerYear'] = @constants.crewDollarsSavedPerMinPerYearPerAC * @inputs.blockMinutesSaved * @inputs.fleetSize
	calculateNumberACSaved: () ->
		out = @outputs
		out['acSavedPerYear'] = @outputs['hoursSavedPerYear'] / (@intermediaries['hoursFlownPerYear'] / @inputs.fleetSize)
	calculateTotalSavings: () ->
		out = @outputs
		out['totalSavingsPerYear'] = out['fuelSavingsPerYear'] + out['crewCostSavingsPerYear']
	calculateDeparturesPerDay: () ->
		out = @outputs
		out['departuresPerDay'] =  @inputs.fleetSize * @constants.departuresPerACPerDay 
	
window.SavingsCalculator = SavingsCalculator