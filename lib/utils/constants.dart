class AppConstants {
  static const String bannerAdScript = '''
    <html>
    <head><style>body{margin:0;padding:0;background:transparent;}</style></head>
    <body>
    <script>
      atOptions = {
        'key' : '099572759d9a7ecf9777eb667fd3413e',
        'format' : 'iframe',
        'height' : 50,
        'width' : 320,
        'params' : {}
      };
    </script>
    <script src="https://www.highperformanceformat.com/099572759d9a7ecf9777eb667fd3413e/invoke.js"></script>
    </body></html>
  ''';

  static const String nativeBannerScript = '''
    <html>
    <head><style>body{margin:0;padding:0;background:transparent;}</style></head>
    <body>
    <script async="async" data-cfasync="false" src="https://pl30088587.effectivecpmnetwork.com/4272c1af95821fd9c30bc4a51923a88d/invoke.js"></script>
    <div id="container-4272c1af95821fd9c30bc4a51923a88d"></div>
    </body></html>
  ''';

  static const String socialBarScript = '''
    <html>
    <head><style>body{margin:0;padding:0;background:transparent;}</style></head>
    <body>
    <script src="https://pl30088586.effectivecpmnetwork.com/b7/0a/e7/b70ae71c490aa40ea864fc806c247edd.js"></script>
    </body></html>
  ''';

  static const String popunderScript = '''
    <html>
    <head><style>body{margin:0;padding:0;}</style></head>
    <body>
    <script src="https://pl30088585.effectivecpmnetwork.com/b0/ff/c2/b0ffc28a2aefb9f8745e8054cf4a0f7e.js"></script>
    <p style="color:#aaa;font-size:12px;text-align:center;padding:20px;">Ad loading...</p>
    </body></html>
  ''';

  static const String rewardAdScript = '''
    <html>
    <head><style>body{margin:0;padding:0;}</style></head>
    <body>
    <script src="https://pl30088585.effectivecpmnetwork.com/b0/ff/c2/b0ffc28a2aefb9f8745e8054cf4a0f7e.js"></script>
    <div style="display:flex;justify-content:center;align-items:center;height:100vh;flex-direction:column;">
      <p style="font-size:16px;color:#555;text-align:center;padding:24px;">
        Watch ad to earn 2 coins. Please wait...
      </p>
    </div>
    </body></html>
  ''';

  static const int rewardAdCoins = 2;
  static const int quizCorrectCoins = 1;
  static const int minWithdrawCoins = 1000;
  static const double coinsPerRupee = 10.0;
  static const String adminEmail = 'admin@goldreward.com';
  static const String usersCollection = 'Users';
  static const String rewardHistoryCollection = 'RewardHistory';
  static const String quizHistoryCollection = 'QuizHistory';
  static const String withdrawHistoryCollection = 'WithdrawHistory';
  static const String adminCollection = 'Admin';
  static const String settingsCollection = 'Settings';
  static const String themeKey = 'dark_mode';

  static double coinsToRupees(int coins) => coins / coinsPerRupee;
}
