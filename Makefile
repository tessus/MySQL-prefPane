.PHONY: MySQL.prefPane debug clean

MySQL.prefPane:
	xcodebuild -project MySQL.prefPane.xcodeproj -configuration "Release" $(XC_OPTIONS) build

debug:
	xcodebuild -project MySQL.prefPane.xcodeproj -configuration "Debug" $(XC_OPTIONS) build

clean:
	@rm -rf ./build
