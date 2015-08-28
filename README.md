# down-ionic

## App id

In config.xml:

Staging:

<widget id="linfootco.Down.dev" version="2.0.0" xmlns="http://www.w3.org/ns/widgets" xmlns:cdv="http://cordova.apache.org/ns/1.0">

Prod:

<widget id="linfootco.Down" version="2.0.0" xmlns="http://www.w3.org/ns/widgets" xmlns:cdv="http://cordova.apache.org/ns/1.0">



## Location Services

Add to iOS Info.plist to be able to request location:

<key>NSLocationWhenInUseUsageDescription</key>
<string>Down makes it easy to do fun stuff with your nearby friends.</string>

https://www.dropbox.com/s/6cokz3hb2uooqmp/Screenshot%202015-08-11%2000.14.48.png?dl=0
TODO: Create our own Cordova plugin to set this ala http://stackoverflow.com/questions/22769111/add-entry-to-ios-plist-file-via-cordova-config-xml


## Google Maps 

Add to iOS Info.plist to open map links in Google Maps:

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>comgooglemaps</string>
</array>

See https://github.com/ohh2ahh/AppAvailability#important-ios-9-url-scheme-whitelist for more info.


## Branch

Add to iOS Info.plist to allow deep linking with Branch:

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Production -->
            <string>down</string>
            <string>fb1466791860252976</string>

            <!-- Staging -->
            <string>down.dev</string>
            <string>fb864552050271610</string>
        </array>
    </dict>
</array>


## Config

Change "linfootco.Down.dev" to "linfootco.Down" as the `widget` element id.


## Facebook

In package.json, the com.phonegap.plugins.facebookconnect variables go from:

Staging:
        "APP_ID": "864552050271610",
        "APP_NAME": "DownDev"

Prod:
        "APP_ID": "1466791860252976",
        "APP_NAME": "Down"
