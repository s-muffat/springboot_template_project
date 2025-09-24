#!/bin/bash

# Spring Boot Template to Project Converter
# This script converts the template project to a real project with custom naming

set -e

echo "=== Spring Boot Template to Project Converter ==="
echo ""

# Function to validate Java package name format
validate_group_id() {
    local group_id="$1"
    if [[ ! "$group_id" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)*$ ]]; then
        echo "Error: Invalid groupId format. Use lowercase letters and dots (e.g., com.mycompany)"
        return 1
    fi
    return 0
}

# Function to validate artifact ID
validate_artifact_id() {
    local artifact_id="$1"
    if [[ ! "$artifact_id" =~ ^[a-z][a-z0-9-]*[a-z0-9]$ ]]; then
        echo "Error: Invalid artifactId format. Use lowercase letters, numbers, and hyphens (e.g., my-awesome-app)"
        return 1
    fi
    return 0
}

# Get user input
echo "Please provide the following information for your new project:"
echo ""

while true; do
    read -p "Enter new groupId (e.g., com.mycompany): " NEW_GROUP_ID
    if validate_group_id "$NEW_GROUP_ID"; then
        break
    fi
done

while true; do
    read -p "Enter new artifactId (e.g., my-awesome-app): " NEW_ARTIFACT_ID
    if validate_artifact_id "$NEW_ARTIFACT_ID"; then
        break
    fi
done

read -p "Enter application name (e.g., MyAwesomeApp): " NEW_APP_NAME

# Convert groupId to directory path
NEW_PACKAGE_PATH=$(echo "$NEW_GROUP_ID" | tr '.' '/')

# Current template values
CURRENT_GROUP_ID="com.example"
CURRENT_ARTIFACT_ID="spring-boot-template"
CURRENT_APP_NAME="TemplateApplication"
CURRENT_PACKAGE_PATH="com/example/template"
CURRENT_PACKAGE="com.example.template"
NEW_PACKAGE="$NEW_GROUP_ID"

echo ""
echo "=== Conversion Summary ==="
echo "Current groupId: $CURRENT_GROUP_ID"
echo "New groupId: $NEW_GROUP_ID"
echo "Current artifactId: $CURRENT_ARTIFACT_ID"
echo "New artifactId: $NEW_ARTIFACT_ID"
echo "Current app name: $CURRENT_APP_NAME"
echo "New app name: ${NEW_APP_NAME}"
echo "Current package: $CURRENT_PACKAGE"
echo "New package: $NEW_PACKAGE"
echo ""

read -p "Proceed with conversion? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Conversion cancelled."
    exit 0
fi

echo ""
echo "=== Starting Conversion ==="

# 1. Update pom.xml
echo "Updating pom.xml..."
sed -i.bak "s|<groupId>$CURRENT_GROUP_ID</groupId>|<groupId>$NEW_GROUP_ID</groupId>|g" pom.xml
sed -i.bak "s|<artifactId>$CURRENT_ARTIFACT_ID</artifactId>|<artifactId>$NEW_ARTIFACT_ID</artifactId>|g" pom.xml
sed -i.bak "s|<name>$CURRENT_ARTIFACT_ID</name>|<name>$NEW_ARTIFACT_ID</name>|g" pom.xml
sed -i.bak "s|<description>Spring Boot Template Application</description>|<description>$NEW_APP_NAME Spring Boot Application</description>|g" pom.xml

# 2. Create new package directory structure
echo "Creating new package directories..."
mkdir -p "src/main/java/$NEW_PACKAGE_PATH"
mkdir -p "src/test/java/$NEW_PACKAGE_PATH"

# 3. Update Java files and move them
echo "Updating and moving Java files..."

# Update main application file
sed "s|package $CURRENT_PACKAGE;|package $NEW_PACKAGE;|g" "src/main/java/$CURRENT_PACKAGE_PATH/TemplateApplication.java" | \
sed "s|class TemplateApplication|class ${NEW_APP_NAME}|g" | \
sed "s|${CURRENT_APP_NAME}.class|${NEW_APP_NAME}.class|g" > "src/main/java/$NEW_PACKAGE_PATH/${NEW_APP_NAME}.java"

# Update test file
sed "s|package $CURRENT_PACKAGE;|package $NEW_PACKAGE;|g" "src/test/java/$CURRENT_PACKAGE_PATH/TemplateApplicationTests.java" | \
sed "s|class TemplateApplicationTests|class ${NEW_APP_NAME}Tests|g" > "src/test/java/$NEW_PACKAGE_PATH/${NEW_APP_NAME}Tests.java"

# 4. Remove old package directories
echo "Removing old package directories..."
rm -rf "src/main/java/com/example"
rm -rf "src/test/java/com/example"

# 5. Update any other files that might reference the old package
echo "Updating configuration files..."
if [ -f "src/main/resources/application.properties" ]; then
    sed -i.bak "s|$CURRENT_PACKAGE|$NEW_PACKAGE|g" src/main/resources/application.properties
    sed -i.bak "s|spring.application.name=$CURRENT_ARTIFACT_ID|spring.application.name=$NEW_ARTIFACT_ID|g" src/main/resources/application.properties
fi

if [ -f "src/main/resources/application.yml" ]; then
    sed -i.bak "s|$CURRENT_PACKAGE|$NEW_PACKAGE|g" src/main/resources/application.yml
    sed -i.bak "s|name: $CURRENT_ARTIFACT_ID|name: $NEW_ARTIFACT_ID|g" src/main/resources/application.yml
fi

# 6. Clean up backup files
echo "Cleaning up backup files..."
find . -name "*.bak" -delete

# 7. Update .idea project files if they exist (IntelliJ)
if [ -d ".idea" ]; then
    echo "Updating IntelliJ project files..."
    find .idea -name "*.xml" -exec sed -i.bak "s|$CURRENT_ARTIFACT_ID|$NEW_ARTIFACT_ID|g" {} \; 2>/dev/null || true
    find .idea -name "*.bak" -delete 2>/dev/null || true
fi

echo ""
echo "=== Conversion Complete! ==="
echo ""
echo "Summary of changes:"
echo "✓ Updated pom.xml with new groupId, artifactId, and description"
echo "✓ Created new package structure: $NEW_PACKAGE_PATH"
echo "✓ Moved and renamed main class: ${NEW_APP_NAME}.java"
echo "✓ Moved and renamed test class: ${NEW_APP_NAME}Tests.java"
echo "✓ Updated package declarations in all Java files"
echo "✓ Cleaned up old package directories"
echo "✓ Updated configuration files (including spring.application.name)"
echo ""
echo "Your project is now ready! You can build it with:"
echo "  mvn clean compile"
echo "  mvn spring-boot:run"
echo ""
echo "Consider updating:"
echo "- README.md with your project information"
echo "- Add your project-specific dependencies to pom.xml"
echo "- Update application.properties with your configuration"