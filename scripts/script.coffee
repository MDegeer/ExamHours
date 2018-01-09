new Vue
	el: 'body'
	data: ->
		return {
			clock: '00:00'
			leaveTime: '15:30'
			endTime: '16:00'
			title: "Examen"
			consignes: "Éteignez vos téléphones."
			configOpen: true
			hiddenMessage: true
			deltaTime: 0
			manualScale: 1
		}
	created: ->
		config = localStorage.getItem('examHours-config')
		if config?
			config = JSON.parse(config)
			for k,v of config
				@[k] = v
		setInterval =>
			@updateClock()
		, 200

	attached: ->
		@updateClock()
	ready: ->
		window.onresize = =>
			ww = window.innerWidth
			wh = window.innerHeight
			table = @.$els.table
			table.style = ''
			tw = table.offsetWidth + 30 
			th = table.offsetHeight + 30

			scale = wh / th
			ntw = Math.min(100 / scale, 100) 
			table.style.transform = 'scale(' + (scale * @manualScale) + ")"
			table.style.width = ntw+'%'
			# table.style.marginTop = (Math.max(0, wh - table.offsetHeight) ) / 2 + "px"

		Vue.nextTick =>
			window.onresize()
	methods:
		getDiff: (time1, time2) ->
			endHour = parseInt(time2.substr(0,2))
			endMinutes = parseInt(time2.substr(3,2))
			hour = parseInt(time1.substr(0,2))
			minutes = parseInt(time1.substr(3,2))

			remainMinutes = endHour * 60 + endMinutes - (hour * 60 + minutes)
			if remainMinutes <= 0
				return {hours:0, minutes: 0}
			remainHour = Math.floor(remainMinutes / 60)
			remainMinutes = remainMinutes - remainHour * 60

			return {hours:remainHour, minutes: remainMinutes}

		getRemainTime: ->
			return @getDiff(@clock, @endTime)

		updateClock: ->
			@deltaTime = parseInt(@deltaTime) || 0
			@clock = new Date(new Date().getTime() + @deltaTime * 1000 * 60).toTimeString().replace("/.*(\d{2}:\d{2}:\d{2}.*/", "$1").substr(0,5)


		toggleConfig: ->
			@configOpen = !@configOpen
		mousemove: ->
			@hiddenMessage = false
			if @lastTimeout
				clearTimeout(@lastTimeout)
			@lastTimeout = setTimeout =>
				@hiddenMessage = true
			, 500
		saveState: ->
			localStorage.setItem('examHours-config', JSON.stringify(@$data))
	computed: 
		isFinished: ->
			remainTime = @getRemainTime()
			remainTime.hours == 0 && remainTime.minutes == 0
		
		canLeave: ->
			diffTime = @getDiff(@clock, @leaveTime)
			diffTime.hours == 0 && diffTime.minutes == 0

		remainTime: ->
			remainTime = @getRemainTime()
			if remainTime.minutes < 10
				remainTime.minutes = "0" + remainTime.minutes

			return remainTime.hours + ":"+remainTime.minutes
		consigneLines: ->
			@consignes.split("\n")
	watch:
		leaveTime: -> 
			Vue.nextTick -> window.onresize()
			@saveState()
		endTime: -> 
			Vue.nextTick -> window.onresize()
			@saveState()
		title: ->
			Vue.nextTick -> window.onresize()
			@saveState()
		consignes: ->
			Vue.nextTick -> window.onresize()
			@saveState()
		deltaTime: ->
			Vue.nextTick -> window.onresize()
			@updateClock()
			@saveState()
		manualScale: ->
			Vue.nextTick -> window.onresize()
			@saveState()


