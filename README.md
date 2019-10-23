# CDR Data Analysis Package (Standard Version)
This is a set of software/tools for analysis of CDR (Call Detail Record) Data including anonymization, pre-processing, interpolation and visualization.

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
|           - Extracting stay points
|           - Extract tripsegment
|           - Relocation PoI
|           - Route Interpolation with transpotation network
│
├─Visualization:
|       A set of tools for drawing trajectory data on map and generating movie data 
|          - Render Trajectory with [Mobmap Web](https://shiba.iis.u-tokyo.ac.jp/member/ueyama/mm/)
|          - Render Trajectory with Mobmap App (Large Dataset, standalone application)
|          - Polygon-based aggregation with time-series (under development)
│
├─InfrastructureUpdates:
|       A set of tools for creating infrastructure data files/database such as PoI data, Road Network Data, Voronoi of Cell Tower


```


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* [Shibasaki Lab](https://shiba.iis.u-tokyo.ac.jp), The University of Tokyo
* [Center for Spatial Information Science](http://www.csis.u-tokyo.ac.jp/en/), The University of Tokyo

