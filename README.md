# CDR Data Analysis Package (Standalone Edition)
This is a set of software/tools for analysis of CDR (Call Detail Record) Data including anonymization, pre-processing, interpolation and visualization. It run in a standalone mode with multi-threads support for large data size. For faster processing and scalabiltiy support, please refer to Hadoop Edition (release soon!)

**This repositoty is being update, some modules might not be available yet, keep checking!**

## Getting Started

These instructions will get you a copy of the software package and running on your local machine. It can be run on both Windows and Mac as the software was developed by Java.

## Structure this package
```
├─Common:
│       A set of necessary libraries.
│
├─Anonymization:
│       A tool for Anonymizing identifiable value in Data such as IMEI,IMSI, Mobile No.
│
├─Interpolation:
|       A set of software for route interpolation including 
|         - Extracting stay points
|         - Extract tripsegment
|         - Relocation PoI
|         - Route Interpolation with transpotation network
│
├─Visualization:
|       A set of tools for drawing trajectory data on map and generating movie data 
|         - Render Trajectory with Mobmap Web (no need installation)
|         - Render Trajectory with Mobmap App (Large Dataset, standalone application)
|         - Polygon-based aggregation with time-series (under development)
│
├─InfrastructureUpdates:
|       A set of tools for creating infrastructure data files/database 
|       such as PoI data, Road Network Data, Voronoi of Cell Tower
|

```

## Prerequisites
Java JDK 8 or higher

## Software List

#### Anonymization 
* A tool for Anonymizing identifiable value in Data such as IMEI,IMSI, Mobile No. It is Java application which can be run in any operating system and also support running anonymization  with multi-thread to speed up the process. Using a machine with a GPU will make encoding faster. 
* See the link: [Anonymization Tool](/Anonymization)
___
#### Interpolation 
* A set of software for route interpolation including extracting stay points, extract tripsegment, relocation POI and route Interpolation with transpotation network. CDR data are generated according to the usage of mobile phone such making a call, sending SMS, use internet. Hence, there is no data when no activity with mobile phone and resulting in missing movement information during those period. The route interpolation help to recover those missing part by accommodate road network with interpolation technique.
* See the link: [Interpolation Package](/Interpolation)
___
#### Visualization - Mobmap Online 
* An online tool for visualization and analysis of movement/trajectory data such as GPS/CDR. with its functionally, it supports color labeling, various maker style and data filter.
* See the link: [Mobmap Online](/Visualization/MobmapWeb)
***
#### Visualization - Mobmap Win App
* An windows application tool for visualization of movement/trajectory data such as GPS/CDR. It supports larger dataset compare to Mobmap Online.
* See the link: [Mobmap Native Win ](/Visualization/MobMapNativeWin)
***
#### Infrastructure Updates
* A set of tools for creating/extracting infrastructure data files/database from OSM (Open Street Map) such as PoI data for reallocation, Road Network Data for route interpolation, Voronoi of Cell Tower 
* See the link: [Infrastructure Updates](/InfrastructureUpdates)
***


## Authors
* Ryosuke Shibasaki
* Hiroshi KANASUGI
* Apichon Witayangkurn
* Ayumi Arai
* Satoshi Ueyama


## License
This software is licensed under the MIT License.
http://opensource.org/licenses/mit-license.php

Copyright (c) 2020 Spatial Data Commons
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Acknowledgments

* [Spatial Data Commons](http://sdc.csis.u-tokyo.ac.jp/), CSIS, The University of Tokyo
* [Shibasaki Lab](https://shiba.iis.u-tokyo.ac.jp), The University of Tokyo
* [Center for Spatial Information Science](http://www.csis.u-tokyo.ac.jp/en/), The University of Tokyo

