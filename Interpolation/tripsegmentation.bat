@echo off
:: 2019-10-19 ******  Trip Segmentation ****** ::
::                                                        ::
::                                                        ::
:: [Preparation]                                          ::
::  1) Java 8                                             ::
::  2) input data for trip segment                        ::

:: ****************************************************** ::


echo Trip segmentation...

set threadNum=2
set logdir=log
set output_path=output
set idfile=id.csv
set int_output_path=%output_path%\trip-segment-temp
set input_file=%1

mkdir %logdir% 2> NUL
mkdir %output_path% 2> NUL
mkdir %int_output_path% 2> NUL
mkdir %output_path%\tripsegment 2> NUL

echo start segmetation on %input_file%
:: run trip segmentation (java)

for  %%f in (%input_file%\*) DO   (
  echo %%f
  java -Xmx2G -classpath .;lib/* jp.utokyo.shibalab.cdrworks.TripSegmentationMain %threadNum% %idfile% %%f %int_output_path% 1> %logdir%/stdout-tripsegment.log 2> %logdir%/stderr-tripsegment.log 
  
  :: post processing:: merging all files
  for /D %%f in (%int_output_path%\*) DO   (
	  echo %%f
	  type %%f\*csv > %%f.csv 
	  rmdir /S /Q %%f
  )
  type %int_output_path%\*.csv > %output_path%\tripsegment\tripsegment_result_%%~nxf
)

rmdir /S /Q %int_output_path%




