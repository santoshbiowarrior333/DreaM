#!/usr/bin/awk -f

# Function to print the record
function print_record(output_file, is_duplicate) {
  printf("%s\n%s\n%s\n%s\n", header, record[1], record[2], record[3]) > output_file;
}

# Main AWK script
BEGIN {
  FS = "\n";   # Set the field separator to newline
  RS = "\n";   # Set the record separator to newline
  
  # Initialize the line counter
  line_count = 0;

  # Variable to store the duplicate file name
  duplicate_file = "";
}

{
  line_count++;

  if (line_count == 1) {
    # Store the header line
    header = $0;
  } else if (line_count == 2) {
    # Store the first line of sequence
    record[1] = $0;
  } else if (line_count == 3) {
    # Store the second line of sequence
    record[2] = $0;
  } else if (line_count == 4) {
    # Store the quality line
    record[3] = $0;

    # Extract the base name from the input file
    split(FILENAME, file_parts, "/");
    split(file_parts[length(file_parts)], base_name_parts, ".");
    base_name = base_name_parts[1];

    # Check if the length and sequence are unique
    key = length(record[1]) "|" record[1];
    output_file = seen[key] ? base_name "_duplicate.fastq" : base_name "_DreaM.fastq";
    seen[key]++;

    # Open the duplicate file if not opened yet
    if (is_duplicate && duplicate_file == "") {
      duplicate_file = base_name "_duplicate.fastq";
      print_record(duplicate_file, is_duplicate);
    }

    # Print the record to the appropriate file
    print_record(output_file, is_duplicate);

    # Reset line count for the next record
    line_count = 0;
  }
}

END {
  # Close the output files
  close(duplicate_file);
}
