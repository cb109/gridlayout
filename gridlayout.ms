/***A mouse tool to organize scene objects.

Select all objects you want to lay out. Execute this script, then click
the left mouse button and drag until you have the desired result.
Dragging away from the initial point will increase the distance between
objects.

Written by Christoph Buelter

***/
(
	fn simpleGridLayout objArray origin dist rows=
	(
		theGrid = #()
		columns = ceil (objArray.count / (rows as Float))

		offsetX = rows * dist / 2
		offsetY = columns * dist / 2

		for r = 0 to (rows-1) do
		(
			for c = 0 to (columns-1) do
			(
				append theGrid [origin.x + r * dist - offsetY, origin.y + c * dist - offsetY, origin.z + 0]
			)--end for
		)--end for

		for o = 1 to objArray.count do
		(
			objArray[o].pos = theGrid[o]
		)--end for
	)--end fn

	tool foo
	(

		local startPos = false
		local startPosScreen

		fn drawCircle origin radius startAngle endAngle step clr=
		(
			points = #()
			for i in startAngle to endAngle by step do
			(
				x = origin.x + radius * sin i
				y = origin.y + radius * cos i
				p = [x,y,0]
				append points p
			)--end

			for j=1 to (points.count-1) do
			(
				gw.wPolyline #(points[j], points[j+1]) false rgb:#(clr,clr)
			)--end for
		)--end fn

		fn drawRubberBandForScaling=
		(
			gw.wPolyline #(startPosScreen, [mouse.pos.x, mouse.pos.y, 0]) false color:#(yellow, yellow)
			drawCircle startPosScreen ((distance startPosScreen [mouse.pos.x, mouse.pos.y, 0]) / 3) 0 360 3 red
			drawCircle [mouse.pos.x, mouse.pos.y, 0] 10 0 360 3 red

			gw.enlargeUpdateRect #whole
			gw.updateScreen()
			redrawViews()
		)--end fn

		on mousePoint clickno do
		(
			if clickno == 1 then
			(
				startPos = [worldpoint.x, worldPoint.y, worldPoint.z]
				startPosScreen = [mouse.pos.x, mouse.pos.y, 0]
				registerRedrawViewsCallback drawRubberBandForScaling
			)
			else
			(
				unregisterRedrawViewsCallback drawRubberBandForScaling
				#stop
			)--end else
		)--end on
		on mouseMove clickno do
		(
			if startPos != false AND selection.count > 0 do
			(
				simpleGridLayout (selection as Array) startPos (distance startPos worldpoint) (ceil(sqrt (selection as Array).count))
			)--end if
		)--end on
		on stop do unregisterRedrawViewsCallback drawRubberBandForScaling
	)--end tool
	startTool foo

)-- end LOCAL