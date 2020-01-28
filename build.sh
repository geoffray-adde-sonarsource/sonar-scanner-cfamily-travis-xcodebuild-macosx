#!/bin/bash

# use only one of SonarQube or SonarCloud

# Configuration for SonarQube
SONAR_URL="http://localhost:9000" # URL of the SonarQube server
SONAR_TOKEN=f5f56032a938d29cf76d78de33991eb8c273a0ea # access token from SonarQube projet creation page -Dsonar.login=XXXX
SONAR_PROJECT_KEY=sonar_scanner_example # project name from SonarQube projet creation page -Dsonar.projectKey=XXXX
SONAR_PROJECT_NAME=sonar_scanner_example # project name from SonarName projet creation page -Dsonar.projectName=XXXX

# Configuration for SonarCloud
#SONAR_TOKEN= # access token from SonarCloud projet creation page -Dsonar.login=XXXX
#SONAR_PROJECT_KEY= # project name from SonarCloud projet creation page -Dsonar.projectKey=XXXX
#SONAR_ORGANIZATION= # organization name from SonarCloud projet creation page -Dsonar.organization=ZZZZ

# Set default to SONAR_URL in not provided
SONAR_URL=${SONAR_URL:-https://sonarcloud.io}

# Download build-wrapper
rm -rf build-wrapper-macosx-x86.zip build-wrapper-macosx-x86
curl "${SONAR_URL}/static/cpp/build-wrapper-macosx-x86.zip" --output build-wrapper-macosx-x86.zip
unzip build-wrapper-macosx-x86.zip

# Download sonar-scanner
rm -rf sonar-scanner
curl 'https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.2.0.1873-macosx.zip' --output sonar-scanner-cli-4.2.0.1873-macosx.zip
unzip sonar-scanner-cli-4.2.0.1873-macosx.zip
mv sonar-scanner-4.2.0.1873-macosx sonar-scanner

# Setup the build system
xcodebuild -project sonar_scanner_example.xcodeproj clean

# Build inside the build-wrapper
build-wrapper-macosx-x86/build-wrapper-macosx-x86 --out-dir build_wrapper_output_directory xcodebuild -project sonar_scanner_example.xcodeproj -configuration Release

# Run sonar scanner (here, arguments are passed through the command line but most of them can be written in the sonar-project.properties file)
[ -n "$SONAR_TOKEN" ] && SONAR_TOKEN_CMD_ARG="-Dsonar.login=${SONAR_TOKEN}"
[ -n "$SONAR_ORGANIZATION" ] && SONAR_ORGANIZATION_CMD_ARG="-Dsonar.organization=${SONAR_ORGANIZATION}"
[ -n "$SONAR_PROJECT_NAME" ] && SONAR_PROJECT_NAME_CMD_ARG="-Dsonar.projectName=${SONAR_PROJECT_NAME}"
SONAR_OTHER_ARGS="-Dsonar.projectVersion=1.0 -Dsonar.sources=sonar_scanner_example -Dsonar.cfamily.build-wrapper-output=build_wrapper_output_directory -Dsonar.sourceEncoding=UTF-8"
sonar-scanner/bin/sonar-scanner -Dsonar.host.url="${SONAR_URL}" -Dsonar.projectKey=${SONAR_PROJECT_KEY} ${SONAR_OTHER_ARGS} ${SONAR_PROJECT_NAME_CMD_ARG} ${SONAR_TOKEN_CMD_ARG} ${SONAR_ORGANIZATION_CMD_ARG}
