#!/bin/bash

# Author: Abhishek Gupta

metadata_header="Metadata-Flavor: Google"
metadata_url="http://metadata.google.internal/computeMetadata/v1/instance"
check_packages()
{
    command -v curl > /dev/null 2>&1
    if [ $? -ne 0 ]; then 
        echo "Curl command not installed"
        exit
    fi
    command -v jq > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "jq command not installed"
        exit
    fi

}

get_all_metadata()
{
    echo "###########Metadata JSON Output starts here#############"
    curl -s -H "${metadata_header}" "${metadata_url}/?recursive=true" | jq .
    echo "###########Metadata JSON Output ends here#############\n"
}

get_specific_metadata()
{
    echo "Below are the metadata keys:"
    curl -s -H "${metadata_header}" ${metadata_url}/
    echo "Please select a key to get its value:"
    read key
    value=$(curl -s -H "${metadata_header}" ${metadata_url}/${key})
    echo "Value of $key is $value"
}

check_packages
get_all_metadata
get_specific_metadata