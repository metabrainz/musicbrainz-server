# Database Schema Diagrams

Diagrams for the database schemas are:
- defined in JSON format under the subdirectory `source/`,
- extracted from SQL tables defined under '../../admin/sql/`,
- generated in DOT format under the subdirectory `graphs/`,
- drawn in SVG format under the subdirectory `images/`.

## Prerequisites

Make sure that both `dot` and `scour` programs are available
(additionally to `make`). If not, install these as follows:

```bash
apt-get install graphviz scour
```

## Generate SVG images

Simply type the following command to generate SVG images:

```bash
make
```

## Manually edit SVG images

To workaround a bug in the current `dot` implementationt which can
make some curved lines to unnecessarily overlap, you can edit SVG
images with Inkscape to manually adjust Bezier curves using the tool
“Edit paths by nodes” which is very easy to use. For help:

- Article: “[How to Use the Bézier Curve Tool in Inkscape](https://designbundles.net/design-school/how-to-use-the-bezier-curve-tool-in-inkscape)”
- Video: “[Inkscape Bezier Tutorial 1](https://www.youtube.com/watch?v=AAgWhnf_p3k)”

As this step will also make unnecessary formatting changes to the SVG,
you can normalize it again with the following command:

```bash
make normalized
```
