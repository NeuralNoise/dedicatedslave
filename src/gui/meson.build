d_gui_inc = include_directories('source')

d_gui_src = [
	'source/dedicatedslave/gui/app.d',
	'source/dedicatedslave/gui/mainwindow.d',
	'source/dedicatedslave/gui/splash.d'
]

gtkd_dep = dependency('gtk-d:gtkd', version:'>=3.8.3', method: 'dub')

d_gui_exe = executable('dedicatedslave-gui',
	[d_gui_src],
	include_directories: [d_gui_inc],
	dependencies: [
		d_dep,
		gtkd_dep
	],
	install: true
)