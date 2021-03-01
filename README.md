# Territorial control
Finding which villages in Afghanistan are controlled by Taliban/IS.




## 1. Extracting tables from ANQAR method reports:

There are two types of tables in each method report: (a) a table with all replaced villages + the reason for replacement (b) a table with villages where intercept interviews were used. We export both.

(example of a and b)

If the method file is a .pdf:
	Both tables are recognized and extracted with python library [Camelot](https://camelot-py.readthedocs.io/en/master/) in `code > 1_extract_tables_from_pdfs.py`. Since the configuration of tables is not constant, I tuned the settings a bit for each table.

If the method file is .doc:
	I just copied the tables and saved them as separate files.


The output is in `data > Intercept_interviews` and `data > Replaced_villages`.


## 2. Cleaning the tables in replaced_villages:

Extraction is not perfect. While I found no mistakes in text recognition, some of the table structures were distorted so that the text moved to neighboring cells, etc. I compare each table structure to its structure in the corresponding PDF and restore it if it was moved. This is done in `code > 2_clean_tables.R` .
Corrected tables are then saved to `replaced_villages_cleaned`.
Tables extracted from .doc files don't require this. Neither do files in `Intercept_interviews`.


## 3. Matching villages to districts

Some tables specify the district where a village belongs, some don't, so they need to be assigned to districts. 2,807 missing districts.
There are two approaches to this:

(a) Match by village names

... + a lot of stuff to describe here, Mtruk, checking after Mturk, etc.


## n. Extracting village/district status from maps

PDF method files feature maps of village/district statuses, marked by colors. So that can be used too.

I copied a map from each file and georeferenced it in QGIS. I saved them as rasters in `data > maps > rasters`. Then by overlaying them with a shapefile of Afghan districts I extracted the color value for each of the districts. There were a few very small districts (n?) that confused the algorithm, because there were almost no pixels, but they also confused humans, so that's the best it gets.




