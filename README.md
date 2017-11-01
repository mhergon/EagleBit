<p align="center" >
<img src="https://raw.github.com/mhergon/EagleBit/assets/eaglebit_logo.png" alt="EagleBit" title="Logo" height=300>
</p>

![cocoapods](https://img.shields.io/cocoapods/at/EagleBit.svg)
![cocoapods](https://img.shields.io/cocoapods/v/EagleBit.svg?style=flat)
![carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)
![issues](https://img.shields.io/github/issues/mhergon/EagleBit.svg)
![stars](https://img.shields.io/github/stars/mhergon/EagleBit.svg)
![license](https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg)

EagleBit is the most efficient way to get locations indefinitely without without sacrificing battery life.
Is able to stop location updates when is not necessary and restart when the user moves again.

## Capabilities

### Current features
- Very low battery consumption **(around 20%)**.
- Stop/restart location updates automatically.
- No config needed, defaults values are the best.

### Next steps
- Add CoreML to detect activity types and situations to reduce battery consumption.
- Add checks to prevent simulate location changes via Xcode or similar.
- Many more features

## How To Get Started

### Installation with CocoaPods

```ruby
platform :ios, '10.0'
pod "EagleBit"
```

### Installation with Carthage

Add to `mhergon/EagleBit` project to your `Cartfile`
```ruby
github "mhergon/EagleBit"
```

Drag `EagleBit.framework` from Carthage/Build/ to the “Linked Frameworks and Libraries” section of your Xcode project’s “General” settings.

Only on **iOS/tvOS/watchOS**: On your application targets "Build Phases" settings tab, click the "+" icon and choose "New Run Script Phase". Create a Run Script with the following contents:
```ruby
/usr/local/bin/carthage copy-frameworks
```
and add the paths to the frameworks you want to use under "Input Files", e.g.:
```ruby
$(SRCROOT)/Carthage/Build/iOS/EagleBit.framework
```

### Manually installation

[Download](https://github.com/mhergon/EagleBit/raw/master/EagleBit.swift) (right-click) and add to your project.

### Requirements

| Version | Language | Minimum iOS Target |
|:--------------------:|:---------------------------:|:---------------------------:|
|          1.0         |            Swift 4.x            |            iOS 10            |

### Usage

First, import module:
```swift
import EagleBit
```

Authorize app to get location updates:
```swift
Eagle.authorize(level: .always) { (status) in
    
    // Location updates authorize status
    
}
```

Start location updates:
```swift
Eagle.fly { (location, error) in
    
    /// Use location as you want!
    
}
```

If you want stop location updates manually, use:
```swift
Eagle.land()
```

### Available options

You can set `distanceFilter` and `showsBackgroundLocationIndicator` (only iOS 11+) like this:
```swift
Eagle.distanceFilter = 10.0 // Meters
Eagle.showsBackgroundLocationIndicator = false // Hide blue bar on iOS 11
```



## Contact

- [Linkedin][1]
- [Twitter][2] (@mhergon)

[1]: https://es.linkedin.com/in/marchervera
[2]: http://twitter.com/mhergon "Marc Hervera"

## License

Licensed under Apache License v2.0.
<br>
Copyright 2017 Marc Hervera.
