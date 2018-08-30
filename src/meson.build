d_inc = include_directories('source')

d_src = [
	'source/dedicatedslave/loader.d'
]

install_subdir('source/dedicatedslave/', install_dir: 'include/d/dedicatedslave/')

archive_dep = dependency('archive', version:'>=0.6.0', method: 'dub')

d_lib = library('dedicatedslave',
	[d_src],
	include_directories: [d_inc],
	install: true,
	version: project_version,
	dependencies: [
		archive_dep
	]
)

pkgc.generate(name: 'dedicatedslave',
	libraries: [d_lib],
	subdirs: 'd/dedicatedslave',
	version: project_version,
	description: ''
)

d_dep = declare_dependency(
	link_with: [d_lib],
	include_directories: [d_inc],
	dependencies: [
		archive_dep
	]
)

d_exe = executable('dedicatedslave-test',
	[d_src],
	include_directories: [d_inc],
	d_unittest: true,
	link_args: '-main',
	dependencies: [
		archive_dep
	]
)

test('dedicatedslave-test', d_exe)

#subdir('cli')
subdir('gui')
