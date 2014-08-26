#!/bin/sh


# remove everything generated by this script
function cleanup
{
rm -rf Build
}


cd "$SOURCE_ROOT"

# clean
if [ -n $1 ] && [ "$1" == "clean" ];
then
cleanup
echo "Cleaning Completed"
exit 0
fi


# clean at first
cleanup


#==================== build AWSiOSSDKCognitoSync framework ====================#

xcodebuild -configuration Release -project "AWSiOSSDKCognitoSync.xcodeproj" -target "AWSiOSSDKCognitoSync" -sdk iphoneos clean build
xcodebuild -configuration Release64 -project "AWSiOSSDKCognitoSync.xcodeproj" -target "AWSiOSSDKCognitoSync" -sdk iphoneos clean build

xcodebuild -configuration Debug -project "AWSiOSSDKCognitoSync.xcodeproj" -target "AWSiOSSDKCognitoSync" -sdk iphonesimulator clean build
xcodebuild -configuration Debug64 -project "AWSiOSSDKCognitoSync.xcodeproj" -target "AWSiOSSDKCognitoSync" -sdk iphonesimulator clean build


FRAMEWORK_NAME="AWSCognitoSync"
FRAMEWORK_VERSION=A

# build path
FRAMEWORK_BUILD_PATH="Build/framework"


echo "Framework: Cleaning framework..."
if [ -d "$FRAMEWORK_BUILD_PATH" ]
then
rm -rf "$FRAMEWORK_BUILD_PATH/$FRAMEWORK_NAME.framework"
fi


# This is the full name of the framework
FRAMEWORK_DIR=$FRAMEWORK_BUILD_PATH/$FRAMEWORK_NAME.framework

rm -rf $FRAMEWORK_DIR

echo "Framework: Setting up directories..."
mkdir -p $FRAMEWORK_DIR
mkdir -p $FRAMEWORK_DIR/Versions
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION/Resources
mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION/Headers

echo "Framework: Creating symlinks..."
ln -s $FRAMEWORK_VERSION $FRAMEWORK_DIR/Versions/Current
ln -s Versions/Current/Headers $FRAMEWORK_DIR/Headers
ln -s Versions/Current/Resources $FRAMEWORK_DIR/Resources
ln -s Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_DIR/$FRAMEWORK_NAME


# The trick for creating a fully usable library is
# to use lipo to glue the different library
# versions together into one file. When an
# application is linked to this library, the
# linker will extract the appropriate platform
# version and use that.
# The library file is given the same name as the
# framework with no .a extension.
echo "Framework: Creating library..."
lipo -create "Build/Debug-iphonesimulator/lib${PROJECT}.a" "Build/Debug64-iphonesimulator/lib${PROJECT}.a" "Build/Release-iphoneos/lib${PROJECT}.a" "Build/Release64-iphoneos/lib${PROJECT}.a" -o "$FRAMEWORK_DIR/Versions/Current/$FRAMEWORK_NAME"


# Now copy headerfile
echo "Framework: Copying assets into current version..."
cp -a Cognito/*.h $FRAMEWORK_DIR/Headers/
cp -a Cognito/Internal/*.h $FRAMEWORK_DIR/Headers/
cp -a Cognito/Reachability/*.h $FRAMEWORK_DIR/Headers/
cp -a CognitoSyncService/*.h $FRAMEWORK_DIR/Headers/


# remove internal header files
rm $FRAMEWORK_DIR/Headers/AWSCognitoConflict_Internal.h
rm $FRAMEWORK_DIR/Headers/AWSCognitoDataset_Internal.h
rm $FRAMEWORK_DIR/Headers/AWSCognitoRecord_Internal.h

# correct the way to import headers
cd $FRAMEWORK_DIR/Headers
"$SOURCE_ROOT"/Scripts/CognitoHeader.sh
