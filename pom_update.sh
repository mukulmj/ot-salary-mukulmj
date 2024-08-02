#!/bin/bash

# Function to get the version from the pom.xml file
get_version_from_pom() {
    version=$(xmllint --xpath "//*[local-name()='project']/*[local-name()='version']/text()" pom.xml)
    echo "$version"
}

# Function to check if a tag exists in the git repo
tag_exists() {
    git fetch --tags
    if git rev-parse "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to increment the version
increment_version() {
    local version=$1
    local IFS='.'
    local parts=($version)
    local last_index=$((${#parts[@]} - 1))
    parts[$last_index]=$((${parts[$last_index]} + 1))
    echo "${parts[*]}" | tr ' ' '.'
}

# Main script
main() {
    current_version=$(get_version_from_pom)

    if tag_exists "$current_version"; then
        new_version=$(increment_version "$current_version")
        mvn versions:set -DnewVersion="$new_version" > /dev/null 2>&1
        mvn versions:commit > /dev/null 2>&1
        git add pom.xml
        git commit -m "Update version to $new_version"
        git tag "$new_version"
        echo "Version updated to $new_version and tagged locally."
    else
        git tag "$current_version"
        echo "Tag $current_version created locally."
    fi
}

main "$@"
