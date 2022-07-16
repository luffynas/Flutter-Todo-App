
VERSION = $(shell cat ./VERSION)
BUILD_NUMBER = $(shell cat ./BUILDNUMBER)
BUILD_NUMBER_FILE=BUILDNUMBER

incrementbuild: 
	@if ! test -f $(BUILD_NUMBER_FILE); then echo 0 > $(BUILD_NUMBER_FILE); fi
	@@echo $$(($(BUILD_NUMBER)+1)) > $(BUILD_NUMBER_FILE)

incrementbuild-live: 
	@if ! test -f $(BUILD_NUMBER_LIVE_FILE); then echo 0 > $(BUILD_NUMBER_LIVE_FILE); fi
	@@echo $$(($(BUILD_NUMBER_LIVE)+1)) > $(BUILD_NUMBER_LIVE_FILE)

release-ios:
	make incrementbuild
	flutter clean
	flutter build ios --release  --build-name=$(VERSION) --build-number=$(BUILD_NUMBER)
	cd ios/ && bundle install && bundle exec fastlane beta --verbose

release-dev:
	make incrementbuild
	# fvm flutter clean
	fvm flutter build apk --release --build-name=$(VERSION) --build-number=$(BUILD_NUMBER)
	firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk  \
		--app 1:494568612584:android:24db9236ad7b752c1e5f5d  \
		--groups "dev" \
		--release-notes-file "changelog.txt" 

release-live-aab:
	make incrementbuild
	fvm flutter clean
	fvm flutter build appbundle --release --build-name=$(VERSION) --build-number=$(BUILD_NUMBER)
	firebase appdistribution:distribute build/app/outputs/bundle/liveRelease/app-release.aab  \
		--app 1:494568612584:android:24db9236ad7b752c1e5f5d  \
		--groups "dev" \
		--release-notes-file "changelog.txt" 

test-live-aab:
	fvm flutter clean
	fvm flutter build appbundle --release --build-name=$(VERSION) --build-number=$(BUILD_NUMBER) --obfuscate --split-debug-info=./mobile_android_live
