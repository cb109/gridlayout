tool gridlayout (
	/***A mouse tool to layout scene objects in an organized way.

	Select all objects you want to position. Execute this script, then
	click the left mouse button and drag until you have the desired
	result. Dragging away from the initial point will increase the
	distance between objects.

	(c) Christoph Buelter, 11/2012

	***/
	local start_pos = false
	local start_pos_screen

	fn draw_circle origin radius start_angle end_angle step = (
		/***Draws a circle into the viewport.***/
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
		/***Draws two circles and a line that visualize the current
		grid distance defined by the mouse drag distance.***/
		local mousepoint = [mouse.pos.x, mouse.pos.y, 0]
		local dist = distance start_pos_screen mousepoint
		local inner_circle_radius = dist / 3
		local outter_circle_radius = 6

		gw.setColor #line yellow
		gw.wPolyline #(start_pos_screen, mousepoint) false

		gw.setColor #line red
		draw_circle start_pos_screen inner_circle_radius 0 360 3
		draw_circle mousepoint outter_circle_radius 0 360 3

		gw.enlargeUpdateRect #whole
		gw.updateScreen()
		redrawViews()
	)

	fn simple_grid_layout obj_array origin dist rows = (
		/***Arranges the given objects in a flat rectangular grid.***/
		local the_grid = #()
		local columns = ceil (obj_array.count / (rows as float))

		local offset_x = rows * dist / 2
		local offset_y = columns * dist / 2

		for r = 0 to (rows - 1) do (
			for c = 0 to (columns - 1) do (
				local x = origin.x + r * dist - offset_y
				local y = origin.y + c * dist - offset_y
				local z = origin.z + 0
				append the_grid [x, y, z]
			)
		)

		for o = 1 to obj_array.count do (
			obj_array[o].pos = the_grid[o]
		)
	)

	on mousePoint clickno do (
		/***Triggered when clicking the mouse.***/
		local first_click = clickno == 1
		if first_click then (
			-- Set initial values and register drawing callback.
			start_pos = [worldpoint.x, worldpoint.y, worldpoint.z]
			start_pos_screen = [mouse.pos.x, mouse.pos.y, 0]
			registerRedrawViewsCallback draw_rubber_band_for_scaling
		)
		else (
			-- Stop the mouse tool.
			unregisterRedrawViewsCallback draw_rubber_band_for_scaling
			#stop
		)
	)

	on mouseMove clickno do (
		/***Triggered when moving the mouse.***/
		local start_pos_not_empty = start_pos != false
		local something_selected = selection.count > 0
		if start_pos_not_empty and something_selected do (
			local world_dist = distance start_pos worldpoint
			local numrows = ceil(sqrt (selection as array).count)
			simple_grid_layout selection start_pos world_dist numrows
		)
	)

	on stop do (
		-- Make sure the callback is removed.
		unregisterRedrawViewsCallback draw_rubber_band_for_scaling
	)
)

startTool gridlayout
