@echo off
:: 2019-10-19 ****** Stay Point Reallocation ****** ::
::                                                        ::
::                                                        ::
:: [Preparation]                                          ::
::  1) Java 8                                             ::
::  2) input data from trip segment with padding          ::

:: ****************************************************** ::


echo Stay Point Reallocation...

set threadNum=2
set logdir=log
set output_path=output
set idfile=id.csv
set int_output_path=%output_path%\reallocation-temp
set input_file=%1
set poifile=parameters/relocation_pois.csv 

mkdir %logdir% 2> NUL
mkdir %output_path% 2> NUL
mkdir %int_output_path% 2> NUL
mkdir %output_path%\reallocation 2> NUL

echo start reallocation on %input_file%
:: run trip reallocation (java)

for  %%f in (%input_file%\*) DO   (
  echo %%f

  java -Xmx2G -classpath .;lib/* jp.utokyo.shibalab.cdrworks.RelocationMain %threadNum% %poifile% %%f %int_output_path% 1> %logdir%/stdout-reallocation.log 2> %logdir%/stderr-reallocation.log 
  
  :: post processing:: merging all files
  for /D %%f in (%int_output_path%\*) DO   (
	  echo %%f
	  type %%f\*csv > %%f.csv 
	  rmdir /S /Q %%f
  )
  type %int_output_path%\*.csv > %output_path%\reallocation\reallo_%%~nxf
)

rmdir /S /Q %int_output_path%

