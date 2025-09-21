#!/bin/bash

echo "Starting Flutter Product Manager App..."
echo

echo "Checking Flutter installation..."
flutter --version
echo

echo "Getting dependencies..."
flutter pub get
echo

echo "Running the app..."
flutter run
echo

read -p "Press any key to continue..."
