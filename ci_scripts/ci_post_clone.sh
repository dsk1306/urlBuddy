#!/bin/sh

cd $CI_PROJECT_FILE_PATH/URLShortener/Utilities/
touch Secrets.swift

echo import Foundation >> Secrets.swift
echo 'enum Secrets {' >> Secrets.swift
echo 'static let bugsnagApiKey = "$BUGSNAG_API"' >> Secrets.swift
echo '}' >> Secrets.swift
