# Territorial control
Finding which villages in Afghanistan are controlled by Taliban/IS.




## 1. Extracting tables from ANQAR method reports:

There are two types of tables in each method report: (a) a table with all replaced villages + a reason for replacement (b) a table with villages where intercept interviews were used. We export both.

If the method file is a .pdf:
	Both tables are recognized and extracted with python library [Camelot](https://camelot-py.readthedocs.io/en/master/) in code/1_extract_tables_from_pdfs.py. Since the style of tables differs a lot, I tuned the settings a bit for each table.

If the method file is .doc:
	The tables were simply copied and saved as csv files.


The output is in data/intercept_interviews and data/replaced_villages. Each wave is a separate csv file.


## 2. Cleaning tables in replaced_villages:

Extraction from pdf is not perfect. While I found no mistakes in text recognition, some of the table structures were distorted so that the text moved to neighboring cells, etc. I compare each table's structure to its structure in the corresponding PDF and restore it if it was moved. This is done manually or with assistance of code/2_clean_tables.R.
Tables extracted from .doc files don't require this. Neither do files in intercept_interviews.
Then the tables are merged and transformed into two csv files: Extracted_tables_full/Districts.csv for district-level rows, and Extracted_tables_full/Villages.csv for village-level rows.


## 3. Matching villages to districts

Next, in Extracted_tables_full/Villages.csv some villages specify the district, some don't. We need to match all villages to districts.

There were 2,805 missing districts out of 8,791 observations.
There are two approaches to this:

(a) Some villages don't have a district, because they were assigned to a wrong province/district. Those problems are described in a special column. That also includes the actual district/province, so I took that and assigned it to a village. This diminished the number of missing districts from 2805 to 2793.

(b) Match by village names + village province in other files:
Take village name and province, find the same combination in another tables. Here I used the intercept interviews, where a new village is sampled from the same district; settlement shape file, where province-village point to a district; and from other waves, where province-village point to a district. Here I'm only taking unique combinations of village-district-provinces, to minimize the risk of making a wrong assignment because of border changes.
If there is a match, assign it to that village. NAs are down to 2049 after this step.

(c) We hired people through Mturk to code the villages, but the results were not consistent enough. Checking after them showed that they made too many mistakes.

Next I merged the villages that we were able to confirm into the main file.

A possible way to proceed here is to find which villages were chosen as substitutes during adjacent waves, because a substitute should belong to the same district. So that would allow finding the district.


## 4. Extracting village/district status from maps

PDF method files feature maps of village/district statuses, marked by colors. So that can be useful too, although on a less granular level.

I copied a map from each file and georeferenced it in QGIS. I saved them as rasters in `data/maps/rasters`. Then by overlaying them with a shapefile of Afghan districts I extracted the color value for each of the districts. There were a few very small districts that confused the algorithm, because there were almost no pixels to read the color from, but they also confused humans, so that's the best it gets.

Results of this procedure are in `data/maps/district_status`.

## Notes

Spelling of localities in PDF may differ from the spelling in other data sets.


