# core

アプリ全体で共有するerrors、logging、theme、utilsを置きます。

プラットフォーム固有APIやマインドマップのドメインルールはここに置きません。

## logging

`print()`は使いません。`AppLogger`と`createAppLogger(suppressDebug:)`を使います。Releaseでは`main`から`configureAppLogging(suppressDebug: kReleaseMode)`を呼び、Debug Logを落とします。

この層は`dart:developer`に依存してよいですが、Domainはここをimportしません。
