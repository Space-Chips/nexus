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
  bool _isAdLoaded = false;
  bool _isAd2Loaded = false;

  @override
  void initState() {
    super.initState();
    _initBannerAd();
    _initBannerAd2();
    // Start a timer to navigate to AuthPage after 3 seconds
    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const AuthPage()));
    });
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
                            borderRadius: BorderRadius.circular(4),
                          ),
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _isAdLoaded
                                  ? SizedBox(
                                      height: _bannerAd.size.height.toDouble(),
                                      width: _bannerAd.size.width.toDouble(),
                                      child: AdWidget(ad: _bannerAd),
                                    )
                                  : const SizedBox(),
                              _isAd2Loaded
                                  ? SizedBox(
                                      height: _bannerAd2.size.height.toDouble(),
                                      width: _bannerAd2.size.width.toDouble(),
                                      child: AdWidget(ad: _bannerAd2),
                                    )
                                  : const SizedBox(),
                              if (!_isAdLoaded && !_isAd2Loaded)
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
