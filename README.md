# CustomTools
## Data Creator
The Data Creator tool creates configuration data by directly calling stored procedures within the database layer. The tool allows user to build significant amounts of test data in a quick and repeatable way.
## File Creator
The File Creator tool allows user to create test files for testing import functions within the system. The tool supports delimited, fixed width, and modified EDI (834, 820, 837) file types.
## File Validator
The File Validator tool is used after a file is imported. The utility is used to compare recently imported data in the database to the source data in the file. Each data element, in the file, is compared to the data in the database and differences are reported.
## Data Deleter Utility
The Data Deleter tool is used to remove previously imported data in the target system allowing the file import to be retested.
## API Automation
The API Automation tool is used to store API request objects and submit them to the appropriate microservice endpoint. The response can then be compared to the expected result with differences being reported. 
