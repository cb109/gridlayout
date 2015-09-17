/***A mouse tool to organize scene objects.

Select all objects you want to lay out. Execute this script, then click
the left mouse button and drag until you have the desired result.
Dragging away from the initial point will increase the distance between
objects.

(c) Christoph Buelter, 11/2012

***/
(
	fn simple_grid_layout obj_array origin dist rows =
	(
		local the_grid = #()
		local columns = ceil (obj_array.count / (rows as Float))

		local offset_x = rows * dist / 2
		local offset_y = columns * dist / 2

		for r = 0 to (rows - 1) do (
			for c = 0 to (columns - 1) do (
				append the_grid [origin.x + r * dist - offset_y, origin.y + c * dist - offset_y, origin.z + 0]
			)
		)

		for o = 1 to obj_array.count do (
			obj_array[o].pos = the_grid[o]
		)
	)

	tool foo (

		local start_pos = false
		local start_pos_screen

		fn draw_circle origin radius start_angle end_angle step = (
			local points = #()
			for i in start_angle to end_angle by step do (
				local x = origin.x + radius * sin i
				local y = origin.y + radius * cos i
				local p = [x, y, 0]
				append points p
			)

			for j = 1 to (points.count - 1) do
				gw.wPolyline #(points[j], points[j + 1]) false
		)

		fn draw_rubber_band_for_scaling = (
			gw.setColor #line yellow
			gw.wPolyline #(start_pos_screen, [mouse.pos.x, mouse.pos.y, 0]) false

			gw.setColor #line red
			draw_circle start_pos_screen ((distance start_pos_screen [mouse.pos.x, mouse.pos.y, 0]) / 3) 0 360 3
			draw_circle [mouse.pos.x, mouse.pos.y, 0] 10 0 360 3

			gw.enlargeUpdateRect #whole
			gw.updateScreen()
			redrawViews()
		)

		on mousePoint clickno do (
			if clickno == 1 then (
				start_pos = [worldpoint.x, worldpoint.y, worldpoint.z]
				start_pos_screen = [mouse.pos.x, mouse.pos.y, 0]
				registerRedrawViewsCallback draw_rubber_band_for_scaling
			)
			else (
				unregisterRedrawViewsCallback draw_rubber_band_for_scaling
				#stop
			)
		)

		on mouseMove clickno do (
			if start_pos != false AND selection.count > 0 do (
				simple_grid_layout (selection as Array) start_pos (distance start_pos worldpoint) (ceil(sqrt (selection as Array).count))
			)
		)

		on stop do (
			unregisterRedrawViewsCallback draw_rubber_band_for_scaling
		)
	)

	startTool foo
)