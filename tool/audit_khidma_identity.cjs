// Run from any directory: node tool/audit_khidma_identity.cjs [legacy-source]
// Checks the actual native/Firebase identity and copied assets against the live
// source. Does not print signing passwords, tokens, or private-key material.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const legacy = process.argv[2] || 'F:/Codebases/khidma_plus/khidma_user';
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
const hash = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
let checks = 0;
function check(name, action) { action(); checks++; console.log(`PASS ${name}`); }
function equalAsset(source, target = source) {
  assert.equal(hash(path.join(root, target)), hash(path.join(legacy, source)), target);
}
function plistValue(source, key) {
  return source.match(new RegExp(`<key>${key}</key>\\s*<string>([^<]+)</string>`))?.[1];
}
const gradle = read('android/app/build.gradle');
const manifest = read('android/app/src/main/AndroidManifest.xml');
const options = read('lib/firebase_options.dart');
const ios = read('ios/Runner/Info.plist');
const pbx = read('ios/Runner.xcodeproj/project.pbxproj');
const google = JSON.parse(read('android/app/google-services.json'));
const registration = google.client.find(c => c.client_info.android_client_info.package_name === 'com.services.khadamat');

function paddedAsset(file) {
  const manifest = JSON.parse(read('tool/icon-padding-manifest.json'));
  assert.equal(hash(path.join(root, file)), manifest.files[file], file);
  assert.equal(hash(path.join(root, manifest.source)), manifest.sourceSha256);
}
check('Android app ID and Kotlin entrypoint', () => {
  assert.match(gradle, /namespace "com\.services\.khadamat"/);
  assert.match(gradle, /applicationId "com\.services\.khadamat"/);
  assert.match(read('android/app/src/main/kotlin/com/services/khadamat/MainActivity.kt'), /package com\.services\.khadamat/);
  for(const scheme of ['tel','mailto','sms','https','http']) {
    assert.ok(manifest.includes(`android:scheme="${scheme}"`),scheme);
    assert.ok(ios.includes(`<string>${scheme}</string>`),scheme);
  }
});
check('iOS bundle ID, Apple team and display name', () => {
  assert.equal((pbx.match(/PRODUCT_BUNDLE_IDENTIFIER = com\.khidmaplus;/g) || []).length, 3);
  assert.equal((pbx.match(/DEVELOPMENT_TEAM = KD9Z8QMD3Y;/g) || []).length, 3);
  assert.equal((pbx.match(/INFOPLIST_KEY_CFBundleDisplayName = "Khidma Plus";/g) || []).length, 3);
  assert.equal(plistValue(ios, 'CFBundleDisplayName'), 'Khidma Plus');
  assert.match(manifest, /android:label="Khidma Plus"/);
});
check('Android Firebase registration matches actual application ID', () => {
  assert.ok(registration);
  assert.ok(options.includes(`appId: '${registration.client_info.mobilesdk_app_id}'`));
  assert.ok(options.includes(`apiKey: '${registration.api_key[0].current_key}'`));
  assert.ok(options.includes(`projectId: '${google.project_info.project_id}'`));
  assert.ok(registration.oauth_client.some(c => c.client_type === 3), 'Google sign-in web client missing');
});
check('iOS Firebase and Google sign-in agree', () => {
  const config = read('ios/Runner/GoogleService-Info.plist');
  assert.equal(plistValue(config, 'BUNDLE_ID'), 'com.khidmaplus');
  assert.ok(options.includes(`appId: '${plistValue(config, 'GOOGLE_APP_ID')}'`));
  assert.ok(ios.includes(plistValue(config, 'REVERSED_CLIENT_ID')));
  assert.equal(plistValue(ios, 'GIDClientID'), plistValue(config, 'CLIENT_ID'));
  assert.equal((pbx.match(/GoogleService-Info\.plist in Resources \*\//g) || []).length, 2);
});
check('Original Firebase files and upload signing material preserved', () => {
  for (const file of ['android/app/google-services.json', 'ios/Runner/GoogleService-Info.plist', 'android/key.properties', 'android/app/khidma-plus-keystore.jks', 'upload_certificate.pem']) equalAsset(file);
  assert.match(gradle, /signingConfig signingConfigs\.release/);
  assert.doesNotMatch(gradle, /signingConfig signingConfigs\.debug/);
});
check('Padded Android launcher icons at all densities', () => {
  for (const density of ['mdpi','hdpi','xhdpi','xxhdpi','xxxhdpi']) paddedAsset(`android/app/src/main/res/mipmap-${density}/ic_launcher.png`);
  equalAsset('assets/images/app_icon.png', 'assets/images/branding/app_icon.png');
  equalAsset('assets/images/app_icon.png', 'android/app/src/main/res/drawable-nodpi/khidma_launcher_artwork.png');
  assert.match(read('android/app/src/main/res/drawable/khidma_launcher_foreground.xml'), /@drawable\/khidma_launcher_artwork/);
  assert.match(read('android/app/src/main/res/values-night-v31/styles.xml'), /windowSplashScreenAnimatedIcon/);
  assert.match(manifest, /default_notification_color/);
  equalAsset('assets/images/appLogo.png', 'assets/images/branding/app_logo.png');
  equalAsset('assets/images/playstore_icon.png', 'assets/images/branding/playstore_icon.png');
  assert.doesNotMatch(read('lib/app/appAssets.dart'), /_brandingAssetsPath\/[^"\n]*\.svg/);
});
check('Padded iOS launcher icons and preserved native launch artwork', () => {
  const dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  equalAsset(`${dir}/Contents.json`);
  const config = JSON.parse(read(`${dir}/Contents.json`));
  for (const image of config.images) if (image.filename) paddedAsset(`${dir}/${image.filename}`);
  const assigned=new Set(config.images.map(image=>image.filename));
  assert.ok(fs.readdirSync(path.join(root,dir)).filter(name=>name.endsWith('.png')).every(name=>assigned.has(name)), 'Unassigned old iOS icon remains');
});
check('Original splash and onboarding artwork reused', () => {
  equalAsset('assets/images/splashBg.png', 'assets/images/branding/splash_background.png');
  equalAsset('assets/images/ob-1.png', 'assets/images/image_a.png');
  equalAsset('assets/images/onboarding3.png', 'assets/images/image_b.png');
  equalAsset('assets/images/postPage.png', 'assets/images/image_c.png');
  equalAsset('assets/images/becomeProvider.png', 'assets/images/dr_become_provider.png');
  equalAsset('ios/Runner/Base.lproj/LaunchScreen.storyboard');
});
check('Every declared AppAssets path exists', () => {
  function exact(value) {
    let actual=root;
    for (const segment of value.split('/').filter(Boolean)) {
      assert.ok(fs.readdirSync(actual).includes(segment), `Missing asset or wrong case: ${value}`);
      actual=path.join(actual,segment);
    }
  }
  const constants = new Map();
  for (const match of read('lib/app/appAssets.dart').matchAll(/^\s*static const String\s+(\w+)\s*=\s*"([^"]*)";/gm)) {
    const value = match[2].replace(/\$(\w+)/g, (_, name) => {
      assert.ok(constants.has(name), `Unresolved asset root ${name}`);
      return constants.get(name);
    });
    constants.set(match[1], value);
    exact(value);
  }
  assert.ok(constants.size > 100, 'Asset inventory was not fully parsed');
  function literals(dir) {
    for(const item of fs.readdirSync(path.join(root,dir),{withFileTypes:true})) {
      const relative=path.join(dir,item.name);
      if(item.isDirectory()) { literals(relative); continue; }
      if(!relative.endsWith('.dart')) continue;
      const source=read(relative).split(/\r?\n/).filter(line=>!line.trim().startsWith('//')).join('\n');
      for(const match of source.matchAll(/['"](assets\/[^'"\n]+)['"]/g)) if(!match[1].includes('$')) exact(match[1]);
    }
  }
  literals('lib');
});
check('Latest customer notification sounds and iOS push environments', () => {
  equalAsset('android/app/src/main/res/raw/notification_sound.mp3');
  equalAsset('ios/Runner/notification_sound.aiff');
  assert.match(read('lib/utils/notification/awesomeNotification.dart'), /resource:\/\/raw\/notification_sound/);
  assert.match(read('lib/utils/notification/awesomeNotification.dart'), /notification_sound\.aiff/);
  assert.match(read('android/app/src/main/res/raw/keep.xml'), /@raw\/notification_sound/);
  assert.match(manifest, /FLUTTER_NOTIFICATION_CLICK/);
  assert.match(pbx, /notification_sound\.aiff in Resources/);
  assert.match(read('ios/Runner/Runner.entitlements'), /\$\(KHIDMA_APS_ENVIRONMENT\)/);
  assert.equal((pbx.match(/KHIDMA_APS_ENVIRONMENT = development;/g)||[]).length,1);
  assert.equal((pbx.match(/KHIDMA_APS_ENVIRONMENT = production;/g)||[]).length,2);
});
check('Khidma notification icon and legacy channel are wired', () => {
  assert.match(manifest, /@drawable\/ic_stat_khidma/);
  assert.match(manifest, /high_importance_channel/);
  assert.match(read('lib/utils/notification/awesomeNotification.dart'), /resource:\/\/drawable\/ic_stat_khidma/);
  assert.match(read('lib/utils/notification/awesomeNotification.dart'), /high_importance_channel/);
  assert.match(read('android/app/src/main/res/drawable/ic_stat_khidma.xml'), /<vector/);
});
check('Brand colour, font, and store destinations', () => {
  assert.match(read('lib/theme/kigen/kigen_primitives.dart'), /primary500: Color\(0xFF5465FF\)/);
  assert.match(read('lib/app/appTheme.dart'), /GoogleFonts\.outfitTextTheme/);
  assert.match(read('lib/ui/widgets/customText.dart'), /GoogleFonts\.outfit/);
  assert.match(read('lib/utils/constant.dart'), /details\?id=com\.services\.khadamat/);
  assert.match(read('lib/utils/constant.dart'), /id6755617892/);
});
check('Template branding and insecure TLS override removed from runtime configuration', () => {
  for (const source of [manifest, ios, pbx, read('lib/utils/constant.dart')]) {
    assert.doesNotMatch(source, /wrteam\.edemand|edemandweb\.wrteam|ADD_YOUR_|PLACE_YOUR_|811828125363/);
  }
  assert.doesNotMatch(read('lib/app/app.dart'), /badCertificateCallback|MyHttpOverrides/);
  assert.match(read('lib/utils/constant.dart'), /showCompanyLogoOnSplash = false/);
});
check('Upgrade version increases over both supplied projects', () => {
  const version = text => text.match(/^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)/m).slice(1).map(Number);
  const current = version(read('pubspec.yaml'));
  const previous = version(fs.readFileSync(path.join(legacy,'pubspec.yaml'),'utf8'));
  assert.ok(current[0] > previous[0] || current[0] === previous[0] && current[1] > previous[1]);
  assert.ok(current[3] > Math.max(previous[3], 70));
});
console.log(`\n${checks} audit groups passed. This does not replace a build or device/backend testing.`);
