class FlightPatternsApp extends EventEmitter
	flightFile = "data/flighthistory-2012-11-20.csv.minimized.csv"
	airportLocationFile = "data/Airport_Codes_mapped_to_Latitude_Longitude_in_the_United_States.csv"
	loopFile = "data/loops.json"
	minHeight = 600
	savingsCalculator = new SavingsCalculator()
	graph = new AirportGraph()
	maxCircleRadius = 50
	font = "Inspira"
	presentVarName = 'presentT'
	speedUp = 1
	fadeInHeader:() ->
		console.log window
		if window.innerHeight < 800
			$('#FlightPatterns').addClass('shrink')
		d3.select('.header').classed('animated',true).style('opacity',1)
		
		setTimeout @doIntro, 250
	doIntro: () =>
		@introGoing = true
		d3.select('#intro_hype_container').append('script').attr('src','intro.hyperesources/intro_hype_generated_script.js')
		#setTimeout(@introComplete, 10)
	introComplete: () =>
		if !@introGoing
			return
		@introGoing = false
		@fadeOutIntro()
	fadeOutIntro: () =>
		$('#intro').fadeOut(400, @fadeInViz)
	fadeInViz:() =>
		$('.viz').css('visibility','visible').css('opacity',1)
		$('.clock, .dailyStats-title, .dailyStat').addClass('opacityAnimation')
		$('.viz .dailyStats-title').css('opacity',1)
		that = this
		setTimeout () ->
			$('.viz .dailyStat').css('opacity',1)
			setTimeout(() ->
				$('.clock.eastern').css('opacity',1);
				setTimeout () -> 
					$('.clock.central').css('opacity',1)
				, 200 * speedUp
				setTimeout () -> 
					$('.clock.mountain').css('opacity',1)
				, 400 * speedUp
				setTimeout () -> 
					$('.clock.pacific').css('opacity',1)
				, 600 * speedUp
				setTimeout(that.initViz, 1000 * speedUp)
				
			, 400 * speedUp)
		,500 * speedUp
	initViz:() =>
		@presetMode = false;
		#console.log(document.location)
		if typeof urlParams[presentVarName] isnt 'undefined'
			duration = +urlParams[presentVarName] * 1000
			if isNaN duration
				duration = 60 * 3 * 1000 # 3 minutes
			@presentDuration = duration
			@presentMode = true
		@defaultFleetSizeSlider = 2
		if typeof urlParams['fleet'] isnt 'undefined'
			fleet = urlParams['fleet']
			fleetLbl = 'medium'
			if fleet is 's'
				fleetLbl = 'small'
				@defaultFleetSizeSlider = 1
			else if fleet is 'm'
				fleetLbl = 'medium'
				@defaultFleetSizeSlider = 2
			else if fleet is 'l'
				fleetLbl = 'large'
				@defaultFleetSizeSlider = 3
			ins = savingsCalculator.inputs
			ins.fleetSize = savingsCalculator.fleetSizes[fleetLbl]
			savingsCalculator.calculate()
			$('.dailyStat-airlineSize .dailyStatCaption').text(fleetLbl + ' sized fleet')
		if typeof urlParams['m'] isnt 'undefined'
			minutes = +urlParams['m']
			if !isNaN minutes and minutes >= 1 and minutes <= 5 and minutes % 0.5 is 0
				ins = savingsCalculator.inputs
				ins.blockMinutesSaved = minutes
				savingsCalculator.calculate()
				
		@mapDimensions = {
			width: $('#planesCanvas').width()
			height: $('#planesCanvas').height()
		}
		@initUI()
		@mapping = d3.geo.albers().scale(1300).translate([480 - 20,300]);
		_.each @airportsObject, (airport) ->
			airport.pos = @mapping([-airport.Longitude, +airport.Latitude]) 
		, this
		@ctxt = document.getElementById('planesCanvas').getContext('2d')
		setTimeout(@initSimulation, 250)
	initUI: () =>
		$('.createBtn').on('click', @clickCreateBtn)
		minuteOpts = {
			value: savingsCalculator.inputs.blockMinutesSaved
			min: 1
			max: 5
			step: 0.5
		}
		$('.create .minutesSlider').slider(minuteOpts)
		sizeOpts = {
			value: @defaultFleetSizeSlider
			min: 1
			max: 3
			step: 1
		}
		$('.create .airlineSizeSlider').slider(sizeOpts)
		$('.create .playBtn').on('click',@playNewScenario)
		$('.aboutText').addClass('animated');
		$('.aboutLink, .share').addClass('visible')
		$('.aboutLink, .aboutText .close').on('click',@clickAboutLink)
		$('.share li').on('click', @clickShareLink)
	initSimulation: () =>
		@simulatorTween = 0
		d3.shuffle @flightData
		numPlanes = savingsCalculator.inputs.fleetSize
		@numPlanes = numPlanes
		savingsCalculator.calculate()
		
		@setTickerNumber($('.dailyStat-timeSavedPer .dailyStatsValue'),savingsCalculator.inputs.blockMinutesSaved, 1, 28,'darkDigit', true)
		@setTickerNumber($('.dailyStat-airlineSize .dailyStatsValue'),savingsCalculator.inputs.fleetSize, 1, 28,'darkDigit', true)
		@simulatorPlanes = []
		hour = 60 * 60
		@minDuration = hour * 1.5
		@airports = []
		@airportMap = {}
		@timeRanges = [new Date().getTime(), 0]
		@numArrivalsEachAirport = {}
		d3.shuffle(@loopData.loops)
		_.each @loopData.loops[0], @addFlight, this
		_.each @loopData.loops[1], @addFlight, this
		_.each @flightData, @addFlight, this
		
		maxArrivals = 0
		maxArrivalsAirport = null
		_.each @numArrivalsEachAirport, (numArrivals, airportCode) ->
			if numArrivals > maxArrivals
				maxArrivalsAirport = airportCode
				maxArrivals = numArrivals
		@airportCircleSizeScale = d3.scale.sqrt().domain([1,maxArrivals]).range([10,maxCircleRadius])
		#add an hour to each end of the range
		@timeRanges[0] -= hour
		@timeRanges[1] += hour 
		@simulatorTimeRanges = @timeRanges
		@simulatorTimeDiff = @timeRanges[1] - @timeRanges[0]
		dateRanges = [new Date(@timeRanges[0] * 1000), new Date(@timeRanges[1] * 1000)];
		@simulatorAnimationDuration = 16000 * speedUp
		if @presentMode
			@simulatorAnimationDuration = @presentDuration
		@startTime = null
		@prevUTCHours = -1
		@planesDeparted = 0;
		@planesLanded = 0
		requestAnimationFrame(@simulate)
		@getPolygons()
	addFlight: (plane, planeIndex) =>
		if @simulatorPlanes.length is @numPlanes
			return
		plane.start = + plane.start
		plane.end = + plane.end
		fromLocation = @airportsObject[plane.from]
		toLocation = @airportsObject[plane.to]
		if typeof fromLocation is 'undefined'
			#console.error 'couldn\'t find from airport ' + plane.from 
			#console.log('plane index ' + planeIndex)
			#console.log(plane)
			return
		if typeof toLocation is 'undefined'
			#console.error 'couldn\'t find to airport ' + plane.to 
			#console.log('plane index ' + planeIndex)
			#console.log(plane)
			return
		plane.fromScreen = @mapping([-fromLocation.Longitude, fromLocation.Latitude])
		plane.toScreen = @mapping([-toLocation.Longitude, toLocation.Latitude])
		plane.screenDiff = [plane.toScreen[0] - plane.fromScreen[0], plane.toScreen[1] - plane.fromScreen[1]]
		plane.duration = plane.end - plane.start
		plane.angle = Math.atan2(plane.screenDiff[1], plane.screenDiff[0])
		if plane.duration < @minDuration
			return
		if typeof @numArrivalsEachAirport[plane.to] is 'undefined'
			@numArrivalsEachAirport[plane.to] = 0
		@numArrivalsEachAirport[plane.to] += 1	
		if plane.start < @timeRanges[0]
			@timeRanges[0] = plane.start
		if plane.end > @timeRanges[1]
			@timeRanges[1] = plane.end
		plane.departed = false
		plane.landed = false
		@simulatorPlanes.push plane
	boardNumberFormatter: (number) ->
		number = + number
		strNumber = ""
		if number < 10
			strNumber = number.toPrecision(2)
		else
			strNumber = Math.round(number)
		
		return strNumber	
		
	simulate: () =>
		time = new Date().getTime()
		if @startTime is null
			@startTime = time
		time = time - @startTime
		tweenAmount = time / @simulatorAnimationDuration 
		if tweenAmount > 1
			tweenAmount = 1
		@simulatedTime = (tweenAmount * @simulatorTimeDiff) + (+@simulatorTimeRanges[0])
		
		@ctxt.clearRect(0,0,960,600);
		@drawPolys()
		@drawPlanes(@simulatedTime)
		@drawAirports(@simulatedTime)
		@updateClocks(@simulatedTime)
		@updateStats(@simulatedTime,tweenAmount)
		if time <= @simulatorAnimationDuration
			requestAnimationFrame(@simulate)
		else
			setTimeout(@outro,1000);
	drawAirports: () =>
		airportLblAtPct = 0.5
		airportFontSize = 24
		airportLabels = []
		now = new Date().getTime()
		_.each @airports, (airport, aIndex) ->
			x = airport.x
			y = airport.y
			newTargetR = @airportCircleSizeScale(airport.count)
			if airport.targetR isnt newTargetR
				airport.targetR = newTargetR
				airport.tweenVal = 0
				airport.prevR = airport.tweenR
				airport.tweenStart = now
			tweenProgress = now - airport.tweenStart
			tweenEnd = airport.tweenMax / 60 * 1000
			if tweenProgress > tweenEnd
				tweenProgress = tweenEnd
			airport.tweenR = $.easing.easeOutQuad(tweenProgress/tweenEnd, tweenProgress, airport.prevR, airport.targetR - airport.prevR, tweenEnd )
			r = airport.tweenR
			if r < 0
				r = 0
			@ctxt.beginPath()
			@ctxt.fillStyle = "rgba(250,18,255,0.5)";
			@ctxt.arc(x, y, r, 0, Math.PI * 2, false)
			@ctxt.fill()
			@ctxt.beginPath()
			@ctxt.fillStyle = "rgba(255,255,255,0.5)"
			maxWhiteRadius = 4
			whiteRadius = if r > maxWhiteRadius then maxWhiteRadius else r 
			@ctxt.arc(x,y, whiteRadius, 0, Math.PI * 2, false)
			@ctxt.fill()
			
			if airport.targetR > airportLblAtPct * maxCircleRadius
				@ctxt.fillStyle = "white"
				@ctxt.font = airportFontSize + "px " + font
				angle = airport.angle
				textXOffset = Math.cos(angle) * r
				textYOffset = Math.sin(angle) * r
				textDimensions = @ctxt.measureText(airport.code)
				if textXOffset < 0
					textXOffset -= textDimensions.width
				if textYOffset > 0
					textYOffset += airportFontSize - 2
				finalX = x + textXOffset
				finalY = y + textYOffset
				finalXEnd = finalX + textDimensions.width
				if finalX < 0 or finalXEnd > @mapDimensions.width
					multiplier = 1
					if finalXEnd > @mapDimensions.width
						multiplier = -1
					if textYOffset > 0
						angle -= multiplier * Math.PI / 2
					else
						angle += multiplier * Math.PI / 2
					textXOffset = Math.cos(angle) * r
					textYOffset = Math.sin(angle) * r
					if textXOffset < 0
						textXOffset -= textDimensions.width
					if textYOffset > 0
						textYOffset += airportFontSize - 2
					finalX = x + textXOffset
					finalY = y + textYOffset
				width = @ctxt.measureText(airport.code)
				dimensions = [finalX, finalY - airportFontSize, finalX + width.width, finalY]
				airportLabels.push([airport.code, finalX, finalY,dimensions,true])
			
			if airport.tweenVal < airport.tweenMax
				airport.tweenVal += 1
		, this
		@ctxt.fillStyle = "white";
		_.each(airportLabels, (lbl,lblIndex ) ->
			overlaps = false
			rect1 = lbl[3]
			if lblIndex > 0
				for i in [0..lblIndex - 1]
					if airportLabels[i][4]
						rect2 = airportLabels[i][3]
						overlaps = rect1[0] < rect2[2] and rect1[2] > rect2[0] and rect1[1] < rect2[3] and rect1[3] > rect2[1]
						if overlaps
							lbl[4] = false
							return
			@ctxt.fillText(lbl[0], lbl[1], lbl[2])
		, this)
	updateClocks: (simulatorTime) =>
		date = new Date(simulatorTime * 1000)
		utcHours = date.getUTCHours()
		if @prevUTCHours is utcHours
			return
		@prevUTCHours = utcHours
		eastern = @displayHours(utcHours - 5)
		central = @displayHours(utcHours - 6)
		mountain = @displayHours(utcHours - 7)
		pacific = @displayHours(utcHours - 8)
		
		$('.clock.pacific .time').text(pacific[0]);
		$('.clock.mountain .time').text(mountain[0]);
		$('.clock.central .time').text(central[0]);
		$('.clock.eastern .time').text(eastern[0]);
		$('.clock.pacific .clockSprite').attr('class','clockSprite hour'+ pacific[1])
		$('.clock.mountain .clockSprite').attr('class','clockSprite hour'+ mountain[1])
		$('.clock.central .clockSprite').attr('class','clockSprite hour'+ central[1])
		$('.clock.eastern .clockSprite').attr('class','clockSprite hour'+ eastern[1])
	updateStats: (simulatorTime, tweenAmount) =>
		landedPct = @planesLanded / savingsCalculator.inputs.fleetSize
		minSavedPerYear = savingsCalculator.outputs.minutesSavedPerYear
		minSavedPerDay  = minSavedPerYear / 365
		minSavedSoFar = minSavedPerDay * landedPct
		moneySavedPerYear = savingsCalculator.outputs.totalSavingsPerYear
		moneySavedPerDay = moneySavedPerYear / 365
		moneySavedSoFar = moneySavedPerDay * landedPct
		timeLbl = 'minutes'
		if minSavedSoFar >= 600
			minSavedSoFar /= 60
			timeLbl = 'hours'
		$('.dailyStat-timeSavings .dailyStatCaption').text(timeLbl)
		@setTickerNumber($('.dailyStat-arrivals .dailyStatsValue'),@planesLanded, 1, 28,'darkDigit', false)
		
		@setTickerNumber($('.dailyStat-moneySavings .dailyStatsValue'), moneySavedSoFar,1000,42,'blueDigit',true)
		@setTickerNumber($('.dailyStat-timeSavings .dailyStatsValue'), minSavedSoFar,1,42,'blueDigit', true)
	setTickerNumber: ($parent, value, scale, digitSize, selector, formatDecimal) =>
		value /= scale
		digits = null
		if value is 0 and formatDecimal
			digits = [0,'.',0]
		else if value is 0
			digits = [0,0,0]
		else if value < 1
			round = Math.round(value * 10)
			digits = [0,'.', round]
		else if value < 10 and formatDecimal
			iPart = Math.floor(value)
			digits = [iPart,'.', Math.round((value-iPart)* 10)]
		else if value < 10
			digits = [0, 0, value]
		else if value < 100
			roundValue = ""+Math.round(value)
			digits = [0, +roundValue.charAt(0), +roundValue.charAt(1)]
		else if value < 1000
			strVal = "" + value
			digits = [+strVal.charAt(0), +strVal.charAt(1), +strVal.charAt(2)]
		else
			console.error('trying to display value to large in tickers ' + value)
			strVal = "" + value
			digits = [+strVal.charAt(strVal.length-3),+strVal.charAt(strVal.length-2),+strVal.charAt(strVal.length-1)]
		
		blueDigits = d3.select($parent[0]).selectAll('.' + selector).data(digits)
		blueDigits.style('background-position', (d,i) ->
			r = 0
			if typeof d is 'number'
				r = d * -digitSize + 'px';
			else
				r = -digitSize * 10  + 'px'
			
			return "0px " + r
		)
	displayHours: (hours) ->
		if hours < 0
			hours += 24
		dispHours = hours
		if hours > 12
			dispHours -= 12
		if dispHours is 0
			dispHours = 12
		text = "" + dispHours + " "
		if hours < 12
			text += "am"
		else
			text += "pm"
		return [text, dispHours]	
			
	drawPlanes: (simulatorTime) =>
		@ctxt.strokeStyle = "rgba(255,255,255,0.5)"
		@ctxt.beginPath()
		planeIcons = []
		scalingDuration = 0.2
		_.each @simulatorPlanes, (simPlane, planeIndex) ->
			if simulatorTime < simPlane.start
				#if simulator time is before this plane departs, don't draw it
				return
			else if simulatorTime > simPlane.end
				#if simulator time is after this plane lands, draw trail
				if !simPlane.departed
					@departPlane(simPlane)
				if !simPlane.landed
					@landPlane(simPlane)
				@ctxt.moveTo(simPlane.fromScreen[0], simPlane.fromScreen[1])
				@ctxt.lineTo(simPlane.toScreen[0], simPlane.toScreen[1])
			else
				if !simPlane.departed
					@departPlane(simPlane)
				flightDurationPct = (simulatorTime - simPlane.start) / simPlane.duration
				@ctxt.moveTo(simPlane.fromScreen[0], simPlane.fromScreen[1])
				finalX = simPlane.fromScreen[0] * (1 - flightDurationPct) + simPlane.toScreen[0] * flightDurationPct
				finalY = simPlane.fromScreen[1] * (1 - flightDurationPct) + simPlane.toScreen[1] * flightDurationPct
				@ctxt.lineTo(finalX, finalY);
				scale = 1
				if flightDurationPct < scalingDuration
					scale = @map(flightDurationPct, 0, scalingDuration, 0.2,1)
				if flightDurationPct > 1 - scalingDuration
					scale = @map(flightDurationPct, 1-scalingDuration, 1, 1, 0.2)
				planeIcons.push([finalX, finalY, simPlane.angle,scale])
				
							
		, this
		@ctxt.stroke()
		planeW = 30
		planeH = 29
		_.each planeIcons, (planePosition) ->
			scale = planePosition[3]
			@ctxt.save()
			@ctxt.translate(planePosition[0], planePosition[1]);
			@ctxt.rotate(planePosition[2])
			
			@ctxt.drawImage(@planeCached, -planeW / 2 * scale, -planeH / 2 * scale, planeW * scale, planeH * scale);
			
			@ctxt.restore()
		, this
	landPlane: (plane) =>
		
		plane.landed = true
		@planesLanded += 1
		@incrementAirport(plane.to, plane.toScreen)
		
	drawPolys:() =>
		now = new Date().getTime()
		polyPercentage = 1
		opacityAdditionAmount = 0.025
		opacityOffsetMultiplier = 2
		if savingsCalculator.inputs.fleetSize is savingsCalculator.fleetSizes.large
			polyPercentage = 0.5
			opacityAdditionAmount = 0.005;
		if savingsCalculator.inputs.fleetSize is savingsCalculator.fleetSizes.small
			opacityAdditionAmount = 0.0375;
			opacityOffsetMultiplier = 1
		
		polysToDraw = @airportPolygons.length * polyPercentage
		if polysToDraw is 0
			return
		
		for i in [0..polysToDraw-1]
			polygonPoints = @airportPolygons[i]
			@ctxt.beginPath()
			targetOpacity = -opacityAdditionAmount * opacityOffsetMultiplier
			_.each(polygonPoints, (airportCode, pointIndex) =>
				if typeof @airportMap[airportCode] isnt 'undefined'
					targetOpacity += @airports[@airportMap[airportCode]].count * opacityAdditionAmount
			, this)
		
			opacityTween = @polygonOpacity[i]
		
			if opacityTween.targetOpacity isnt targetOpacity
				opacityTween.tweenVal = 0
				opacityTween.prevOpacity = opacityTween.tweenOpacity
				opacityTween.targetOpacity = targetOpacity
				opacityTween.tweenStart = now
			tweenProgress = now - opacityTween.tweenStart
			tweenEnd = opacityTween.tweenMax / 60 * 1000
			if tweenProgress > tweenEnd
				tweenProgress = tweenEnd
			opacityTween.tweenOpacity = $.easing.easeInQuad(tweenProgress / tweenEnd, tweenProgress, opacityTween.prevOpacity, opacityTween.targetOpacity - opacityTween.prevOpacity, tweenEnd)
			
			if opacityTween.tweenVal < opacityTween.tweenMax
				opacityTween.tweenVal += 1
			drawOpacity = opacityTween.tweenOpacity
			if drawOpacity < 0
				drawOpacity = 0
			@ctxt.fillStyle = "rgba(69,201,214," + drawOpacity + ")";
			_.each polygonPoints, (airportCode,pointIndex) =>
				ap = @airportsObject[airportCode]
				if pointIndex == 0
					@ctxt.moveTo(ap.pos[0], ap.pos[1])
				else 
					@ctxt.lineTo(ap.pos[0], ap.pos[1])
			,this
			@ctxt.closePath()
			@ctxt.fill()
		
	getPolygons: () =>
		#console.log graph
		graph.init(@simulatorPlanes)
		@tarjanPolys = []
		@airportPolygons = graph.polys
		polyOpacity = []
		_.each(@airportPolygons, (poly) ->
			polyOpacity.push({
				targetOpacity: 0
				tweenOpacity: 0
				tweenVal: 0
				tweenMax: 60
				prevOpacity: 0
			})
		)
		@polygonOpacity = polyOpacity
	departPlane: (plane) =>
		plane.departed = true
		@planesDeparted += 1
	incrementAirport: (airportCode, airportScreenPos) =>
		map = @airportMap
		if typeof @airportMap[airportCode] is 'undefined'
			map[airportCode] = @airports.length
			a = {
				code: airportCode
				x: airportScreenPos[0]
				y: airportScreenPos[1]
				angle: Math.atan2(@mapDimensions.height / 2 - airportScreenPos[1], @mapDimensions.width / 2 - airportScreenPos[0]) + Math.PI
				count: 0
				prevR: 0
				targetR: 0
				tweenR: 0
				tweenVal: 0
				tweenMax: 60
			}
			@airports.push(a)
		airport = @airports[@airportMap[airportCode]]
		airport.count += 1
	resizeVisual: () ->
		windowHeight = $(window).height()
		if windowHeight < minHeight
			windowHeight = minHeight
		$('.bg').height(windowHeight)
	constructor: () ->
		$(window).on('resize',@resizeVisual)
		@resizeVisual()
		
		d3.csv(airportLocationFile, @loadAirportLocationData)
		
	loadAirportLocationData: (err, data) =>
		if err isnt null
			console.error 'error loading airpot location data'
			console.log err
			return
		@airportLocationData = data
		airportsObject = {}
		_.each @airportLocationData, (airport) ->
			
			airportsObject[airport.locationID] = airport
		@airportsObject = airportsObject
		d3.json(loopFile, @loadLoops)
	loadLoops: (err, data) =>
		if err isnt null
			console.error 'error loading loop data';
			console.log err
			return
		@loopData = data
		#console.log @loopData
		d3.csv(flightFile, @loadFlightData)
	loadFlightData: (err, data) =>
		if err isnt null
			console.error 'error loading flight history data';
			console.log err
			return
		@flightData = data
		@cachePlaneImage()
		
	cachePlaneImage: () =>
		
		cacheCanvas = document.createElement('canvas')
		cacheCanvas.width = 30
		cacheCanvas.height = 29
		ctxt = cacheCanvas.getContext '2d'
		ctxt.drawImage(document.getElementById('planeIcon'),0,0,30,29)
		@planeCached = cacheCanvas
		@fadeInHeader()
	map: (value, istart, istop, ostart, ostop) ->
      return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))
	outro: () =>
		outroFadeDuration = 400
		$('.mapClocks').fadeOut(outroFadeDuration) 
		statsYPos = '600px';
		if !@presentMode
			d3.select('#planesCanvas').transition().duration(outroFadeDuration).style('opacity',0.5).style('-webkit-filter','blur(2px)')
		else
			statsYPos = '750px'
			$('.header .title').css('cursor','pointer').on('click', @clickReplayBtn)
		
		d3.select('.stats').style('top', statsYPos)
		d3.select('.yearStats').style('display','block')
		setTimeout () ->
			d3.select('.yearStats').classed('show',true)
		,50
		setTimeout(@outroDigits, 1000)
	outroDigits: () =>
		@setTickerNumber($('.yearlyStat-aircraftFreed .dailyStatsValue'), savingsCalculator.outputs.acSavedPerYear, 1, 42,'blueDigit', true)
		
		@setTickerNumber($('.yearlyStat-timeSavings .dailyStatsValue'), savingsCalculator.outputs.hoursSavedPerYear,1000,42,'blueDigit',true)
		@setTickerNumber($('.yearlyStat-moneySavings .dailyStatsValue'), savingsCalculator.outputs.totalSavingsPerYear,1000000,42,'blueDigit', true)
		buttonFadeInDelay = 1000;
		btnToFadeIn = '.createBtn'
		if @presentMode
			btnToFadeIn = '.replayBtn'
		setTimeout(() ->
			d3.select(btnToFadeIn).style('visibility','visible').style('opacity','1')
		, buttonFadeInDelay)
	clickReplayBtn: () =>
		document.location.reload()
	clickCreateBtn: () =>
		d3.selectAll('.stats, .createBtn').style('opacity',0)
		d3.selectAll('.yearStats').classed('show',false);
		setTimeout(@showCreateScreen, 1000)
	showCreateScreen: () =>
		d3.select('.create').style('visibility','visible').style('opacity',1)
	playNewScenario: () =>
		minuteValue = $('.minutesSlider').slider('value');
		sizeChoice = $('.airlineSizeSlider').slider('value');
		newSize = 0
		lbl = ''
		if sizeChoice is 1
			lbl = 'small'
		else if sizeChoice is 2
			lbl = 'medium'
		else if sizeChoice is 3
			lbl = 'large'
		fleetURLVariable = lbl.charAt(0)

		newSize = savingsCalculator.fleetSizes[lbl]
		$('.dailyStat-airlineSize .dailyStatCaption').text(lbl + ' sized fleet')
		inputs = savingsCalculator.inputs
		inputs.blockMinutesSaved = minuteValue
		inputs.fleetSize = newSize
		savingsCalculator.calculate()
		ctxt = @ctxt
		d3.select('#planesCanvas').transition().duration(1000).style('opacity',0).style('-webkit-filter','blur(0px)').each('end',(d,i) ->
			ctxt.clearRect(0,0,960,600)
			d3.select(this).style('opacity',1)
		)
		d3.select('.create').style('opacity',0)
		d3.select('.stats').style('opacity',1).style('top','20px');
		updateLink = @getCurrentShareLink()
		if typeof history isnt 'undefined' and typeof history.replaceState isnt 'undefined'
			history.replaceState(null,"", updateLink)
		setTimeout () =>
			d3.select('.create').style('visibility','hidden');
			$('.mapClocks').fadeIn(400) 
			@initSimulation()
		, 1000
	clickAboutLink: () =>
		$('.aboutText').toggleClass('show')
	getCurrentShareLink: () =>
		#link = document.location.origin + document.location.pathname
		link = document.location.protocol + "//" + document.location.host + document.location.pathname
		fleetVar = ''
		if savingsCalculator.inputs.fleetSize is savingsCalculator.fleetSizes.small
			fleetVar = 's'
		else if savingsCalculator.inputs.fleetSize is savingsCalculator.fleetSizes.medium
			fleetVar = 'm'
		else if savingsCalculator.inputs.fleetSize is savingsCalculator.fleetSizes.large
			fleetVar = 'l'
		link += '?fleet=' + fleetVar
		link += '&m=' + savingsCalculator.inputs.blockMinutesSaved
		return link
	clickShareLink: (e) =>
		shareType = $(e.currentTarget).attr('class')
		link = encodeURIComponent(@getCurrentShareLink())
		twitterText = encodeURIComponent('Think you can change the future of flight? See how GE Flight Quest challengers are')
		emailSubject = twitterText	
		emailBody = emailSubject
		if shareType is "facebook"
			shareURL = 'http://www.facebook.com/sharer.php?u=' + link 
		else if shareType is "twitter"
			shareURL = 'http://twitter.com/intent/tweet?text=' + twitterText + '&url=' + link;
		else if shareType is "gplus"
			shareURL = 'https://plus.google.com/share?url=' + link;
		else if shareType is "email"
			shareURL = 'mailto:?subject=' + emailSubject + '&body=' + emailSubject+encodeURIComponent("\n") + link
			location.href = shareURL;
			return;
		window.open(shareURL,"share", "scrollbars=yes,resizable=yes,toolbar=no,location=yes,width=520,height=300")
		
				
window.FlightPatternsApp = FlightPatternsApp