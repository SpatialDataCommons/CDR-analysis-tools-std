# CDR Data Analysis Package (Standard Version)
This is a set of software/tools for analysis of CDR (Call Detail Record) Data including anonymization, pre-processing, interpolation and visualization. 

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
|         - Render Trajectory with [Mobmap Web](https://shiba.iis.u-tokyo.ac.jp/member/ueyama/mm/)
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
* A tool for Anonymizing identifiable value in Data such as IMEI,IMSI, Mobile No.
* See the link: [Anonymization Tool](/Anonymization)
___
#### Visualization - Mobmap Online 
* An online tool for visualization and analysis of movement/trajectory data such as GPS/CDR. with its functionally, it supports color labeling, various maker style and data filter.
* See the link: [Mobmap Online](/Visualization/MobmapWeb)
***
#### Visualization - Mobmap Win App
* An windows application tool for visualization of movement/trajectory data such as GPS/CDR. It supports larger dataset compare to Mobmap Online.
* See the link: [Mobmap Native Win ](/Visualization/MobMapNativeWin)
* *Under development*
***



## Authors
* Ryosuke Shibasaki
* Hiroshi KANASUGI
* Apichon Witayangkurn
* Ayumi Arai
* Satoshi Ueyama


## License

Free to use and distribute with acknowledgement.

## Acknowledgments

* [Shibasaki Lab](https://shiba.iis.u-tokyo.ac.jp), The University of Tokyo
* [Center for Spatial Information Science](http://www.csis.u-tokyo.ac.jp/en/), The University of Tokyo

