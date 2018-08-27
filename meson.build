project('dedicatedslave', 'd',
	meson_version: '>=0.40',
	subproject_dir: 'lib/subprojects',
	version: '0.0.1',
	license: 'MIT')

pkgc = import('pkgconfig')

project_soversion = '0'
project_version_suffix = '~alpha1'
project_version = meson.project_version()
project_version_full = project_version + project_version_suffix

subdir('src')
