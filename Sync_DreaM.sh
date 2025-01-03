#!/bin/bash

#SBATCH --job-name=process_fastq
#SBATCH --cpus-per-task=32
#SBATCH --ntasks=1
#SBATCH --output=process_fastq_%j.log

# Function to check if a file has been processed
is_processed() {
  local file=$1
  [ -e "$file" ]
}

# Process files with "DreaM" in the name
for FILE in *_DreaM.fastq; do
  # Skip if file does not have _1_DreaM or _2_DreaM in its name
  if [[ ! "$FILE" =~ _[12]_DreaM.fastq$ ]]; then
    continue
  fi

  # Derive the pair filename
  if [[ "$FILE" =~ _1_DreaM.fastq$ ]]; then
    PAIR_FILE="${FILE/_1_DreaM.fastq/_2_DreaM.fastq}"
  else
    PAIR_FILE="${FILE/_2_DreaM.fastq/_1_DreaM.fastq}"
  fi

  # Check if pair file exists
  if [ ! -f "$PAIR_FILE" ]; then
    echo "Skipping $FILE as its pair $PAIR_FILE does not exist"
    continue
  fi

  # Derive base names
  FILE_BASENAME=$(basename "$FILE" .fastq)
  PAIR_BASENAME=$(basename "$PAIR_FILE" .fastq)
  SYNCED_FILE="synced_${FILE_BASENAME}.fastq"
  SYNCED_PAIR_FILE="synced_${PAIR_BASENAME}.fastq"

  # Check if files are already processed
  if is_processed "$SYNCED_FILE" && is_processed "$SYNCED_PAIR_FILE"; then
    echo "Skipping $FILE and $PAIR_FILE as they are already processed"
    continue
  fi

  # Process the files
  echo "Processing $FILE and $PAIR_FILE..."

  # Create intermediate header ID files
  FILE_IDS="${FILE_BASENAME}_ids.txt"
  PAIR_IDS="${PAIR_BASENAME}_ids.txt"

  # Extract the read IDs from the files
  echo "Extracting read IDs from $FILE..."
  awk 'NR%4==1' "$FILE" > "$FILE_IDS"
  echo "Read IDs saved to $FILE_IDS"

  echo "Extracting read IDs from $PAIR_FILE..."
  awk 'NR%4==1' "$PAIR_FILE" > "$PAIR_IDS"
  echo "Read IDs saved to $PAIR_IDS"

  # Generate the synchronized pair file using the read IDs from the original file
  echo "Generating synchronized pair file: $SYNCED_PAIR_FILE"
  awk 'NR==FNR{ids[$1]; next} /^@/ && ($1 in ids) {print; getline; print; getline; print; getline; print}' "$FILE_IDS" "$PAIR_FILE" > "$SYNCED_PAIR_FILE"
  echo "Synchronized pair file generated: $SYNCED_PAIR_FILE"

  # Generate the synchronized file using the read IDs from the pair file
  echo "Generating synchronized file: $SYNCED_FILE"
  awk 'NR==FNR{ids[$1]; next} /^@/ && ($1 in ids) {print; getline; print; getline; print; getline; print}' "$PAIR_IDS" "$FILE" > "$SYNCED_FILE"
  echo "Synchronized file generated: $SYNCED_FILE"

  # Clean up the intermediate read ID files
  rm "$FILE_IDS" "$PAIR_IDS"
  echo "Intermediate files $FILE_IDS and $PAIR_IDS have been removed"

  echo "Synchronized FASTQ files have been generated:"
  echo " - Synced file: $SYNCED_FILE"
  echo " - Synced pair file: $SYNCED_PAIR_FILE"
done

echo "Processing complete."
