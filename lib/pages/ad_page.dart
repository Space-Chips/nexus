import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nexus/advertisement/ad_helper.dart';
import 'package:nexus/auth/auth.dart';

class AdPage extends StatefulWidget {
  const AdPage({super.key});

  @override
  State<AdPage> createState() => _AdPageState();
}

class _AdPageState extends State<AdPage> {
  late BannerAd _bannerAd;
  late BannerAd _bannerAd2;
  late BannerAd _bannerAd3;
  late BannerAd _bannerAd4;
  late BannerAd _bannerAd5;
  late BannerAd _bannerAd6;
  late BannerAd _bannerAd7;
  late BannerAd _bannerAd8;

  bool _isAdLoaded = false;
  bool _isAd2Loaded = false;
  bool _isAd3Loaded = false;
  bool _isAd4Loaded = false;
  bool _isAd5Loaded = false;
  bool _isAd6Loaded = false;
  bool _isAd7Loaded = false;
  bool _isAd8Loaded = false;

  @override
  void initState() {
    super.initState();
    _initBannerAd();
    _initBannerAd2();
    _initBannerAd3();
    _initBannerAd4();
    _initBannerAd5();
    _initBannerAd6();
    _initBannerAd7();
    _initBannerAd8();
    // Start a timer to navigate to AuthPage after 3 seconds
    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const AuthPage()));
    });
  }

  @override
  void dispose() {
    _initBannerAd();
    _initBannerAd2();
    _initBannerAd3();
    _initBannerAd4();
    _initBannerAd5();
    _initBannerAd6();
    _initBannerAd7();
    _initBannerAd8();
    super.dispose();
  }

  _initBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {},
      ),
      request: const AdRequest(),
    );
    _bannerAd.load();
  }

  _initBannerAd2() {
    _bannerAd2 = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId2,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAd2Loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {},
      ),
      request: const AdRequest(),
    );
    _bannerAd2.load();
  }

  _initBannerAd3() {
    _bannerAd3 = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId3,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAd3Loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {},
      ),
      request: const AdRequest(),
    );
    _bannerAd3.load();
  }

  _initBannerAd4() {
    _bannerAd4 = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId4,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {});
        },
        onAdFailedToLoad: (ad, error) {},
      ),
      request: const AdRequest(),
    );
    _bannerAd4.load();
  }

  _initBannerAd5() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId5,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {},
      ),
      request: const AdRequest(),
    );
    _bannerAd.load();
  }

  _initBannerAd6() {
    _bannerAd2 = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId6,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAd2Loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {},
      ),
      request: const AdRequest(),
    );
    _bannerAd2.load();
  }

  _initBannerAd7() {
    _bannerAd3 = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId7,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAd3Loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {},
      ),
      request: const AdRequest(),
    );
    _bannerAd3.load();
  }

  _initBannerAd8() {
    _bannerAd4 = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId8,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {});
        },
        onAdFailedToLoad: (ad, error) {},
      ),
      request: const AdRequest(),
    );
    _bannerAd4.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text("A D  P A G E"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Column(
                      children: <Widget>[
                        Text(
                          "Nous tenons à vous présenter nos excuses pour les annonces publicitaires...",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _isAdLoaded
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 5.0),
                                      child: SizedBox(
                                        height:
                                            _bannerAd.size.height.toDouble(),
                                        width: _bannerAd.size.width.toDouble(),
                                        child: ClipRRect(
                                          // Round corners of the ad widget
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Adjust the radius as needed
                                          child: AdWidget(ad: _bannerAd),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              _isAd2Loaded
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 5.0),
                                      child: SizedBox(
                                        height:
                                            _bannerAd2.size.height.toDouble(),
                                        width: _bannerAd2.size.width.toDouble(),
                                        child: ClipRRect(
                                          // Round corners of the ad widget
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Adjust the radius as needed
                                          child: AdWidget(ad: _bannerAd2),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              _isAd3Loaded
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 5.0),
                                      child: SizedBox(
                                        height:
                                            _bannerAd3.size.height.toDouble(),
                                        width: _bannerAd3.size.width.toDouble(),
                                        child: ClipRRect(
                                          // Round corners of the ad widget
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Adjust the radius as needed
                                          child: AdWidget(ad: _bannerAd3),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              _isAd4Loaded
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 5.0),
                                      child: SizedBox(
                                        height:
                                            _bannerAd4.size.height.toDouble(),
                                        width: _bannerAd4.size.width.toDouble(),
                                        child: ClipRRect(
                                          // Round corners of the ad widget
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Adjust the radius as needed
                                          child: AdWidget(ad: _bannerAd4),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              if (!_isAdLoaded &&
                                  !_isAd2Loaded &&
                                  !_isAd3Loaded &&
                                  !_isAd4Loaded &&
                                  !_isAd5Loaded &&
                                  !_isAd6Loaded &&
                                  !_isAd7Loaded &&
                                  !_isAd8Loaded)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
