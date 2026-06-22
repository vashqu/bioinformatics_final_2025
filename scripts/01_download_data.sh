#!/bin/bash

FTP_BASE_PATH="ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/data"
LOCAL_BASE_PATH="./data"

START_SAMPLE=149
END_SAMPLE=178

mkdir -p "$LOCAL_BASE_PATH"

for i in $(seq -w $START_SAMPLE $END_SAMPLE); do
	SAMPLE="HG00${i}"
	REMOTE_PATH="${FTP_BASE_PATH}/${SAMPLE}/exome_alignment/"
	LOCAL_PATH="${LOCAL_BASE_PATH}/${SAMPLE}/exome_alignment/"

	mkdir -p "$LOCAL_PATH"

	if curl --silent --head --fail "${REMOTE_PATH}" > /dev/null; then
		echo "Processing ${SAMPLE}..."

		FILES=$(curl -s "${REMOTE_PATH}" | grep "chrom11")

		for FILE in $FILES; do
		
		wget -q --show-progress --no-parent --cut-dirs=6 -P "$LOCAL_PATH" "${REMOTE_PATH}${FILE}"
		done
	else
		echo "Directory ${REMOTE_PATH} does not exist,skipping"
	fi
done

echo "Completed"
