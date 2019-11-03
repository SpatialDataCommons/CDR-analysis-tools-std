@echo off
:: 2019-10-19 ****** Trip Interpolation ****** ::
::                                                        ::
::                                                        ::
:: [Preparation]                                          ::
::  1) Java 8                                             ::
::  2) input data from stay point reallocaiton            ::
::       (/output/trippadding                             ::
::                                                        ::
:: ****************************************************** ::


echo trip interpolation...

set threadNum=2
set logdir=log
set output_path=output
set idfile=id.csv
set int_output_path=%output_path%\interpolation-temp
set input_file=%1
set roadfile=parameters/osm_road.tsv

mkdir %logdir% 2> NUL
mkdir %output_path% 2> NUL
mkdir %int_output_path% 2> NUL
mkdir %output_path%\interpolation 2> NUL

echo trip interpolation on %input_file%
:: run trip reallocation (java)

for  %%f in (%input_file%\*) DO   (
  echo %%f

  java -Xmx2G -classpath .;lib/* jp.utokyo.shibalab.cdrworks.TripInterpolationMain %threadNum% %roadfile% %%f %int_output_path% 1> %logdir%/stdout-interpolation.log 2> %logdir%/stderr-interpolation.log 
  
 
  :: post processing:: merging all files
  for /D %%f in (%int_output_path%\*) DO   (
	  echo %%f
	  type %%f\*csv > %%f.csv 
	  rmdir /S /Q %%f
  )
  type %int_output_path%\*.csv > %output_path%\interpolation\interpo_%%~nxf
)

rmdir /S /Q %int_output_path%

