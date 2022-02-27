import 'package:flutter/material.dart';
import 'package:now8/screens/common.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreenBody extends StatelessWidget {
  const WelcomeScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(40.0),
        child: ListView(children: [
          SelectableText(AppLocalizations.of(context)!.welcomeToAppName,
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center),
          Container(
              margin: const EdgeInsets.only(top: 40),
              child: SelectableText(
                AppLocalizations.of(context)!.appSummary,
                style: Theme.of(context).textTheme.bodyText1,
              )),
          Card(
              margin: const EdgeInsets.only(top: 40.0),
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          AppLocalizations.of(context)!.features,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SelectableText(
                              AppLocalizations.of(context)!.featureList,
                              style: Theme.of(context).textTheme.bodyText1,
                            ))
                      ]))),
        ]));
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      body: const WelcomeScreenBody(),
      appBarTitle: AppLocalizations.of(context)!.titleShort,
    );
  }
}
