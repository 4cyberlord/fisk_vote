# Important: Opening the iOS Project in Xcode

## ⚠️ CRITICAL: Always Open the Workspace, Not the Project File

When working with this Flutter iOS project, you **MUST** open:

```
Runner.xcworkspace
```

**NOT** `Runner.xcodeproj`

## Why?

This project uses CocoaPods for dependency management. CocoaPods creates a workspace (`.xcworkspace`) that includes:
- Your Runner project
- The Pods project (containing all dependencies like cloud_firestore, Firebase, etc.)

If you open `Runner.xcodeproj` directly, Xcode cannot find the CocoaPods modules, resulting in errors like:
- "Module 'cloud_firestore' not found"
- "Module 'firebase_core' not found"
- And other similar module errors

## How to Open Correctly

1. In Finder, navigate to: `mobile_app/ios/`
2. Double-click `Runner.xcworkspace` (the blue workspace icon)
3. Or from terminal: `open ios/Runner.xcworkspace`

## If You See Module Errors

If you're seeing module errors in Xcode:

1. Close Xcode completely
2. Make sure you opened `Runner.xcworkspace` (not `.xcodeproj`)
3. Clean the build folder: Product → Clean Build Folder (Shift+Cmd+K)
4. Rebuild: Product → Build (Cmd+B)

## Reinstalling Pods (if needed)

If issues persist, reinstall CocoaPods dependencies:

```bash
cd mobile_app/ios
pod install
```

Then reopen `Runner.xcworkspace`.

