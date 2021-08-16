!!! success "[SALAT_READ](idl/salat_read.md)"
	Reads in a SALSA level4 FITS cubes and provides information about the cube's dimension and other parameters stored as extensions, such as arrays of observing time, beam's size and angle.
	```webidl
	IDL> alma = salat_read(cube, header=header, time=time, beam_major=beam_major, beam_minor=beam_minor, beam_angle=beam_angle)
	```

!!! success "[SALAT_READ_HEADER](idl/salat_read_header.md)"
	Reads in a SALSA level4 FITS cubes and outputs selected important header's parameters with meaningful names as a structure.
	```webidl
	IDL> alma_header = salat_read_header(cube)
	```

!!! success "[SALAT_STATS](idl/salat_stats.md)"
	Reads in a SALSA level4 FITS cubes and outputs basic statistics of the data cube (or a frame) as a structure and print them in terminal (optional). A histogram is also plotted (optional)
	```webidl
	IDL> result = salat_stats(cube, /histogram)
	```

!!! success "[SALAT_TIMELINE](idl/salat_timeline.md)"
	Displays a timeline with missing frames and calibration gaps and outputs corresponding info (time indices)
	```webidl
	IDL> result = salat_timeline(cube)
	```

!!! success "[SALAT_INFO](idl/salat_info.md)"
	Prints some relevant information about the data cube in terminal
	```webidl
	IDL> salat_info, cube
	```

!!! success "[SALAT_PLOT_MAP](idl/salat_plot_map.md)"
	Plot a map with optional features: color legend, synthesised beam etc. and save images as JPG or PNG files (optional).
	```webidl
	IDL> salat_plot_map, cube
	```

!!! success "[SALAT_BEAM_STATS](idl/salat_beam_stats.md)"
	Print statistics aboout synthesised beam and plot variation of the beam parameters with time.
	```webidl
	IDL> salat_beam_stats, cube
	```

!!! success "[SALAT_CONTRAST](idl/salat_contrast.md)"
	Compute and plot "mean intensity" and "rms intensity contrast" of a cube and indicate bad/good frames based on a given threshold. Gaps (due to ALMA calibration routines) are marked with Red dashed lines.
	```webidl
	IDL> bestframe = salat_contrast(cube, limit=limit, badframes=badframes, goodframes=goodframes)
	```

!!! success "[SALAT_CONVOLVE_BEAM](idl/salat_convolve_beam.md)"
	Convolve a specified synthetic beam (from an ALMA observations) to a user-provided map (e.g. from a simulation or observations with other instruments)
	```webidl
	IDL> convolved_cube = salat_convolve_beam(data, beam)
	```

!!! success "[SALAT_SALSA_TO_CRISPEX](idl/salat_salsa_to_crispex.md)"
	Create a CRISPEX cube from the ALMA fits cube (3D, 4D, or 5D) for quick inspections using the CRISPEX tool
	```webidl
	IDL> salat_salsa_to_crispex, cube, savedir=savedir
	```

!!! success "[SALAT_PREP_DATA](idl/salat_prep_data.md)"
	Take a standard SALSA level 4 cube and convert it such that it is accepted by external viewers, such as CARTA.
	```webidl
	IDL> salat_prep_data, cube, savedir=savedir
	```