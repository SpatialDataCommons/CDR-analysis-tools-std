@echo off
:: 2019-10-19 ****** Export Trip for Mobmap ****** ::
::                                                        ::
::                                                        ::
:: [Preparation]                                          ::
::  1) Java 8                                             ::
::  2) input data from interpolation            ::
::       (/output/interpolation                             ::
::                                                        ::
:: ****************************************************** ::


echo Export Trip for Mobmap...

set threadNum=2
set logdir=log
set output_path=output
set idfile=id.csv
set int_output_path=%output_path%\mobmap-temp
set input_file=%1

mkdir %logdir% 2> NUL
mkdir %output_path% 2> NUL
mkdir %int_output_path% 2> NUL
mkdir %output_path%\mobmap 2> NUL

echo Export Trip for Mobmap on %input_file%
:: run trip reallocation (java)

for  %%f in (%input_file%\*) DO   (
  echo %%f

  java -Xmx2G -classpath .;lib/* jp.utokyo.shibalab.cdrworks.ToMob2 %%f %int_output_path% 1> %logdir%/stdout-mobmap.log 2> %logdir%/stderr-mobmap.log 
 
  :: post processing:: merging all files
  for /D %%f in (%int_output_path%\*) DO   (
	  echo %%f
	  type %%f\*csv > %%f.csv 
	  rmdir /S /Q %%f
  )
  type %int_output_path%\*.csv > %output_path%\mobmap\mobmap_%%~nxf
)

rmdir /S /Q %int_output_path%

